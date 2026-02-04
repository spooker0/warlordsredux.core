#include "includes.inc"
{
	missionNamespace setVariable [format ["BIS_WL_currentTarget_%1", _x], objNull, true];

	[_x, _forEachIndex] spawn {
		params ["_side", "_sideIndex"];
		private _votingResetVar = format ["BIS_WL_resetTargetSelection_server_%1", _side];
		private _waitVar = format ["WL2_waitsInRow_%1", _side];
		private _surrenderVotingVar = format ["WL2_surrenderVoting_%1", _side];
		private _currentTargetVar = format ["BIS_WL_currentTarget_%1", _side];

		private _previousTargetSelection = objNull;

		private _calculateMostVotedSector = {
			private _allPlayers = call BIS_fnc_listPlayers;
			private _players = _allPlayers select { side group _x == _side } select { isPlayer _x };

			private _votesByPlayers = createHashMap;
			private _votingPlayers = _players select {
				private _isRegularSquadMember = ["isRegularSquadMember", [getPlayerID _x]] call SQD_fnc_query;
				!_isRegularSquadMember
			};
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
						private _squadVotingPower = ["getSquadVotingPower", [getPlayerID _x]] call SQD_fnc_query;
						_voteCount = _squadVotingPower + (_votesByPlayers getOrDefault [_voteName, [objNull, 0]] select 1);
					};
					_votesByPlayers set [_voteName, [_vote, _voteCount]];
				};
			} forEach _votingPlayers;

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
			private _players = _allPlayers select { side group _x == _side } select { isPlayer _x };
			{
				private _voteVar = format ["BIS_WL_targetVote_%1", getPlayerID _x];
				missionNamespace setVariable [_voteVar, objNull];
			} forEach _players;
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
				private _playersWithVote = _allPlayers select {
					side group _x == _side
				} select {
					isPlayer _x
				} select {
					private _playerVoteVar = format ["BIS_WL_targetVote_%1", getPlayerID _x];
					!isNull (missionNamespace getVariable [_playerVoteVar, objNull])
				};
				private _votingReset = missionNamespace getVariable [_votingResetVar, false];

				// Final condition
				_votingReset || count _playersWithVote > 0
			};

			if (missionNamespace getVariable [_votingResetVar, false]) then {
				continue;
			};

			private _votingEnd = serverTime + WL_DURATION_SECTORVOTE;
			private _nextUpdate = serverTime;

			while { serverTime < _votingEnd } do {
				if (missionNamespace getVariable [_votingResetVar, false]) then {
					break;
				};

				if (serverTime >= _nextUpdate) then {
					private _calculation = call _calculateMostVotedSector;

					private _voteEndVar = format ["WL2_voteEnd_%1", _side];
					private _voteEndPreviousData = missionNamespace getVariable [_voteEndVar, 0];
					if (_voteEndPreviousData isNotEqualTo _votingEnd) then {
						missionNamespace setVariable [_voteEndVar, _votingEnd, true];
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

			// Finished voting
			if !(missionNamespace getVariable [_votingResetVar, false]) then {
				private _calculation = call _calculateMostVotedSector;
				private _selectedSector = _calculation # 0;

				private _selectedSectorName = _selectedSector getVariable ["WL2_name", "Sector"];
				switch (_selectedSectorName) do {
					case "Wait": {
						private _waitsInRow = missionNamespace getVariable [_waitVar, 0];
						_waitsInRow = _waitsInRow + 1;
						missionNamespace setVariable [_waitVar, _waitsInRow];

						missionNamespace setVariable [_surrenderVotingVar, false];
					};
					case "Surrender": {
						private _isSurrenderVoting = missionNamespace getVariable [_surrenderVotingVar, false];
						if (!_isSurrenderVoting) then {
							missionNamespace setVariable [_surrenderVotingVar, true];
							[] remoteExec ["WL2_fnc_surrenderWarning", _side];
						} else {
							missionNamespace setVariable ["BIS_WL_missionEnd", true, true];
							private _oppositeTeam = if (_side == west) then { east } else { west };
							[_oppositeTeam] spawn WL2_fnc_calculateEndResults;

							[_oppositeTeam, true, true] remoteExec ["WL2_fnc_missionEndHandle", 0];
							[_oppositeTeam, true, false] spawn WL2_fnc_missionEndHandle;
						};
					};
					default {
						missionNamespace setVariable [_waitVar, 0];
						missionNamespace setVariable [_surrenderVotingVar, false];
						[_side, _selectedSector] call WL2_fnc_selectTarget;

						missionNamespace setVariable [format ["BIS_WL_sectorVoteTallyDisplay_%1", _side], [], true];
						missionNamespace setVariable [format ["WL_targetReset_%1", _side], false, true];
					};
				};

				private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
				private _teamPriorityTypeVar = format ["WL2_teamPriorityType_%1", _side];

				private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
				private _teamPriorityType = missionNamespace getVariable [_teamPriorityTypeVar, ""];

				private _shouldAdvancePriority = switch (_teamPriorityType) do {
					case "asset";
					case "fob";
					case "stronghold": {
						if (alive _teamPriority) then {
							private _previousTargetArea = _previousTargetSelection getVariable ["objectAreaComplete", objNull];
							_teamPriority inArea _previousTargetArea
						} else {
							true;
						};
					};
					case "sector": {
						_teamPriority == _previousTargetSelection
					};
					default {
						true
					};
				};

				if (_shouldAdvancePriority) then {
					missionNamespace setVariable [_teamPriorityVar, _selectedSector, true];
					missionNamespace setVariable [_teamPriorityTypeVar, "sector", true];
				};

				_previousTargetSelection = _selectedSector;

				call _wipeVotes;

				["server", true] call WL2_fnc_updateSectorArrays;

				waitUntil {
					uiSleep WL_TIMEOUT_STANDARD;
					isNull (missionNamespace getVariable [_currentTargetVar, objNull]) ||
					missionNamespace getVariable [format ["WL_targetReset_%1", _side], false];
				};
			};
		};
	};
} forEach [west, east];