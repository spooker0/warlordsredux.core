params ["_side", "_sector"];

if !(_sector getVariable ["BIS_WL_simulated", false]) then {
	_sector setVariable ["BIS_WL_simulated", true];
	_sector spawn WL2_fnc_sectorCaptureHandle;
};

private _prevSector = missionNamespace getVariable format ["BIS_WL_currentTarget_%1", _side];
missionNamespace setVariable [format ["BIS_WL_currentTarget_%1", _side], _sector, true];
missionNamespace setVariable [format ["BIS_WL_sectorSelectedTimestamp_%1", _side], serverTime, true];

private _isHomeBase = _sector in (profileNamespace getVariable "BIS_WL_lastBases");
if (_isHomeBase) then {
	private _previousValue = _sector getVariable ["BIS_WL_baseUnderAttack", false];
	if (!_previousValue) then {
		_sector setVariable ["BIS_WL_baseUnderAttack", true, true];
	};
	["base_vulnerable", _sector getVariable "BIS_WL_originalOwner"] call WL2_fnc_handleRespawnMarkers;
} else {
	private _owner = _sector getVariable ["BIS_WL_owner", sideUnknown];
	private _enemySector = missionNamespace getVariable format ["BIS_WL_currentTarget_%1", ([west, east] select {_x != _side}) # 0];
	if (_owner == resistance && _sector != _enemySector) then {
		private _isCarrierSector = count (_sector getVariable ["WL_aircraftCarrier", []]) > 0;
		if (_isCarrierSector) then {
			[_sector] spawn WL2_fnc_populateCarrierSector;
		} else {
			[_sector, _owner] spawn WL2_fnc_populateSector;
		};
	};

	if (_prevSector in (profileNamespace getVariable "BIS_WL_lastBases")) then {
		private _previousValue = _sector getVariable ["BIS_WL_baseUnderAttack", true];
		if (_previousValue) then {
			_sector setVariable ["BIS_WL_baseUnderAttack", false, true];
		};
		["base_safe", _prevSector getVariable "BIS_WL_originalOwner"] call WL2_fnc_handleRespawnMarkers;
	};
};