#include "includes.inc"

private _lastTime = serverTime;
private _fullClientUpdateInterval = serverTime;
while { !BIS_WL_missionEnd } do {
	private _sectorsInPlay = missionNamespace getVariable ["WL2_sectorsInPlay", []];

	private _actualTimeElapsed = serverTime - _lastTime;
	_lastTime = serverTime;

	{
		private _sector = _x;

		private _minCaptureTime = _sector getVariable ["WL2_minCapture", 20];
		private _originalOwner = _sector getVariable ["BIS_WL_owner", independent];

		private _capturingTeam = _sector getVariable ["BIS_WL_capturingTeam", independent];
		private _captureProgress = _sector getVariable ["BIS_WL_captureProgress", 0];

		private _progressMovement = _actualTimeElapsed / _minCaptureTime;

		private _sortedInfo = _sector call WL2_fnc_getCapValues;
		_sector setVariable ["WL_captureDetails", _sortedInfo, true];

		private _topEntry = _sortedInfo # 0;
		private _winner = _topEntry # 0;
		private _winningScore = _topEntry # 1;

		private _secondEntry = _sortedInfo # 1;
		private _secondWinner = _secondEntry # 0;
		private _secondScore = _secondEntry # 1;

		if (_winningScore == _secondScore) then {
			_winner = independent;
			_winningScore = 100;
		};

		// systemChat format ["Winner: %1 (%2), Loser: %3 (%4), Progress: %5", _winner, _winningScore, _secondWinner, _secondScore, _captureProgress];

		if (_winningScore == 0) then {
			_winner = _originalOwner;
		};

		private _scoreGap = _winningScore - _secondScore;
		private _movementMultiplier = linearConversion [1, 20, _scoreGap, 0.1, 1, true];
		private _movement = _progressMovement * _movementMultiplier;

		if (_winner == _capturingTeam) then {
			if (_capturingTeam != _originalOwner) then {
				_captureProgress = _captureProgress + _movement;
			};
		} else {
			if (_captureProgress > 0) then {
				_captureProgress = _captureProgress - _movement * 0.5;
			} else {
				if (_winner != independent) then {
					_captureProgress = 0;
					_capturingTeam = _winner;
				};
			};
		};

		if (_captureProgress < 0) then {
			_captureProgress = 0;
		};

		if (_captureProgress >= 1) then {
			_sector setVariable ["BIS_WL_owner", _capturingTeam, true];
			_sector setVariable ["BIS_WL_capturingTeam", independent, true];
			_sector setVariable ["BIS_WL_captureProgress", 0, true];
			[_sector, _capturingTeam] call WL2_fnc_changeSectorOwnership;
		} else {
			private _lastCaptureProgress = _sector getVariable ["BIS_WL_captureProgress", -1];
			if (_lastCaptureProgress != _captureProgress) then {
				_sector setVariable ["BIS_WL_captureProgress", _captureProgress, true];
			};
			private _lastCaptureTeam = _sector getVariable ["BIS_WL_capturingTeam", independent];
			if (_lastCaptureTeam != _capturingTeam) then {
				_sector setVariable ["BIS_WL_capturingTeam", _capturingTeam, true];
			};
		};

		private _previousOwners = _sector getVariable ["BIS_WL_previousOwners", []];
		if (count _previousOwners > 1) then {
			private _fortificationTime = _sector getVariable ["WL_fortificationTime", -1];
			if (_fortificationTime > 0 && serverTime > _fortificationTime) then {
				_sector setVariable ["WL_fortificationTime", -1, true];

				private _currentOwner = _sector getVariable ["BIS_WL_owner", independent];
				_sector setVariable ["BIS_WL_previousOwners", [_currentOwner], true];
				[_sector, _currentOwner] remoteExec ["WL2_fnc_sectorMarkerUpdate", 0];
				["server", true] call WL2_fnc_updateSectorArrays;
			};
		};
	} forEach _sectorsInPlay;

	sleep 1;
	// systemChat format ["Sector %1 | Owner: %2, Capturing Team: %3, Progress: %4", _sector getVariable ["WL2_name", "Unknown"], _sector getVariable ["BIS_WL_owner", "Unknown"], _sector getVariable ["BIS_WL_capturingTeam", "Unknown"], _sector getVariable ["BIS_WL_captureProgress", 0]];
};