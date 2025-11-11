#include "includes.inc"
{
	missionNamespace setVariable [format ["BIS_WL_currentTarget_%1", _x], objNull, true];

	[_x, _forEachIndex] spawn {
		params ["_side", "_sideIndex"];
		private _votingResetVar = format ["BIS_WL_resetTargetSelection_server_%1", _side];
		private _waitVar = format ["WL2_waitsInRow_%1", _side];

		private _calculateMostVotedSector = {
			private _allPlayers = call BIS_fnc_listPlayers;
			private _warlords = _allPlayers select {side group _x == _side};
			private _players = _warlords select {isPlayer _x};

			private _votesByPlayers = createHashMap;
			{
				private _player = _x;
				private _variableName = format ["BIS_WL_targetVote_%1", getPlayerID _player];
				private _vote = missionNamespace getVariable [_variableName, objNull];
				private _voteName = format ["%1", _vote];
				private _availableSectors = if (isNil "BIS_WL_sectorsArrays") then {
					[];
				} else {
					(BIS_WL_sectorsArrays # _sideIndex) # 1;
				};
				if (!(isNull _vote) && (_vote in _availableSectors)) then {
					private _voteCount = 0;
					if (_vote getVariable ["WL2_name", "Sector"] == "Surrender") then {
						private _squadContribution = missionNamespace getVariable ["WL_PlayerSquadContribution", createHashMap];
						private _playerVotes = _squadContribution getOrDefault [getPlayerUID _player, 0];
						_voteCount = round (_playerVotes * 0.2);
					} else {
						private _squadVotingPower = ["getSquadVotingPower", [getPlayerID _x]] call SQD_fnc_server;
						_voteCount = _squadVotingPower + (_votesByPlayers getOrDefault [_voteName, [objNull, 0]] select 1);
					};
					_votesByPlayers set [_voteName, [_vote, _voteCount]];
				};
			} forEach (_players select { !(["isRegularSquadMember", [getPlayerID _x]] call SQD_fnc_server) });

			private _sortedVoteList = (toArray _votesByPlayers) # 1; // discard keys
			_sortedVoteList = [_sortedVoteList, [], { _x # 1  }, "DESCEND"] call BIS_fnc_sortBy;

			private _maxVotedSector = objNull;
			if (count _sortedVoteList > 0) then {
				_firstSector = _sortedVoteList # 0;
				_maxVotedSector = _firstSector # 0; // return sector object

				private _sectorName = _maxVotedSector getVariable ["WL2_name", "Sector"];
				if (_sectorName == "Wait") then {
					private _waitsInRow = missionNamespace getVariable [_waitVar, 0];

					if (_waitsInRow >= 3 && count _sortedVoteList > 1) then {
						private _secondSector = _sortedVoteList # 1;
						_maxVotedSector = _secondSector # 0;
					};
				};
			};

			[_maxVotedSector, _sortedVoteList];
		};

		private _wipeVotes = {
			private _allPlayers = call BIS_fnc_listPlayers;
			private _players = _allPlayers select {side group _x == _side} select {isPlayer _x};
			private _voterVariables = _players apply {format ["BIS_WL_targetVote_%1", getPlayerID _x]};
			{
				missionNamespace setVariable [_x, objNull];
			} forEach _voterVariables;
		};

		while {!BIS_WL_missionEnd} do {
			missionNamespace setVariable [_votingResetVar, false];
			call _wipeVotes;

			_calculation = call _calculateMostVotedSector;

			private _tallyDisplayVar = format ["BIS_WL_sectorVoteTallyDisplay_%1", _side];
			private _tallyValue = _calculation # 1;
			private _tallyPreviousValue = missionNamespace getVariable [_tallyDisplayVar, []];
			if (_tallyPreviousValue isNotEqualTo _tallyValue) then {
				missionNamespace setVariable [_tallyDisplayVar, _tallyValue, true];
			};

			waitUntil {
				uiSleep WL_TIMEOUT_SHORT;
				private _allPlayers = call BIS_fnc_listPlayers;
				_warlords = _allPlayers select {side group _x == _side};
				_players = _warlords select {isPlayer _x};
				_playerVotingVariableNames = _players apply {format ["BIS_WL_targetVote_%1", getPlayerID _x]};

				_votingReset = missionNamespace getVariable [_votingResetVar, false];
				_playerHasVote = _playerVotingVariableNames findIf {!isNull (missionNamespace getVariable [_x, objNull])} != -1;

				// Final condition
				_votingReset || _playerHasVote
			};

			if !(missionNamespace getVariable [_votingResetVar, false]) then {
				_votingEnd = serverTime + WL_DURATION_SECTORVOTE;
				_nextUpdate = serverTime;

				while {serverTime < _votingEnd && {!(missionNamespace getVariable [_votingResetVar, false])}} do {
					private _allPlayers = call BIS_fnc_listPlayers;
					_warlords = _allPlayers select {side group _x == _side};
					_players = _warlords select {isPlayer _x};

					if (serverTime >= _nextUpdate) then {
						_calculation = call _calculateMostVotedSector;

						private _mostVotedVar = format ["BIS_WL_mostVoted_%1", _side];
						private _mostVotedData = [_calculation # 0, _votingEnd];
						private _mostVotedPreviousData = missionNamespace getVariable [_mostVotedVar, [objNull, 0]];
						if (_mostVotedPreviousData isNotEqualTo _mostVotedData) then {
							missionNamespace setVariable [_mostVotedVar, _mostVotedData, true];
						};

						private _tallyDisplayVar = format ["BIS_WL_sectorVoteTallyDisplay_%1", _side];
						private _tallyValue = _calculation # 1;
						private _tallyPreviousValue = missionNamespace getVariable [_tallyDisplayVar, []];
						if (_tallyPreviousValue isNotEqualTo _tallyValue) then {
							missionNamespace setVariable [_tallyDisplayVar, _tallyValue, true];
						};

						_nextUpdate = serverTime + WL_TIMEOUT_STANDARD;
					};

					uiSleep WL_TIMEOUT_SHORT;
				};

				if !(missionNamespace getVariable [_votingResetVar, false]) then {
					_calculation = call _calculateMostVotedSector;
					private _selectedSector = _calculation # 0;

					private _selectedSectorName = _selectedSector getVariable ["WL2_name", "Sector"];
					switch (_selectedSectorName) do {
						case "Wait": {
							private _waitsInRow = missionNamespace getVariable [_waitVar, 0];
							_waitsInRow = _waitsInRow + 1;
							missionNamespace setVariable [_waitVar, _waitsInRow];
						};
						case "Surrender": {
							missionNamespace setVariable ["BIS_WL_missionEnd", true, true];

							private _oppositeTeam = if (_side == west) then { east } else { west };

							[_oppositeTeam] spawn WL2_fnc_calculateEndResults;
							[_oppositeTeam, true] remoteExec ["WL2_fnc_missionEndHandle", 0];
						};
						default {
							missionNamespace setVariable [_waitVar, 0];
							[_side, _selectedSector] call WL2_fnc_selectTarget;
						};
					};

					call _wipeVotes;
					missionNamespace setVariable [format ["BIS_WL_sectorVoteTallyDisplay_%1", _side], [], true];
					missionNamespace setVariable [format ["WL_targetReset_%1", _side], false, true];

					["server", true] call WL2_fnc_updateSectorArrays;

					waitUntil {
						uiSleep WL_TIMEOUT_STANDARD;
						isNull (missionNamespace getVariable [format ["BIS_WL_currentTarget_%1", _side], objNull]) ||
						missionNamespace getVariable [format ["WL_targetReset_%1", _side], false];
					};
				};
			};
		};
	};
} forEach [WEST, EAST];