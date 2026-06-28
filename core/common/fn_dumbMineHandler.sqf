#include "includes.inc"
params ["_isServer"];

private _assetData = WL_ASSET_DATA;
private _ownedVehicleVar = if (_isServer) then {
    "BIS_WL_ownedVehicles_server"
} else {
    format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
};

private _lastPlayedVO = 0;
private _lastWarnTime = 0;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

while { !BIS_WL_missionEnd } do {
    uiSleep 0.3;

    private _side = if (_isServer) then {
        independent
    } else {
        BIS_WL_playerSide
    };

    private _enemyUnits = switch (_side) do {
        case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case independent: { BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles };
        default { [] };
    };
    private _enemyMines = _enemyUnits select {
        WL_ISUP(_x)
    } select {
        isNull attachedTo _x;
    } select {
        private _mineData = _x getVariable ["WL2_minefield", []];
        count _mineData > 0
    };

    private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
    private _ownedVehiclesEligible = _ownedVehicles select {
        WL_ISUP(_x)
    } select {
        !(_x isKindOf "Man")
    } select {
        private _unitActualType = WL_ASSET_TYPE(_x);
        WL_ASSET_FIELD(_assetData, _unitActualType, "demolishable", 0) == 0
    } select {
        !(_x isKindOf "ParachuteBase") && !(vehicle _x isKindOf "ParachuteBase")
    } select {
        private _posAGL = _x modelToWorld [0, 0, 0];
        _posAGL # 2 < 10;
    } select {
        isEngineOn _x
    } select {
        abs (speed _x) > 1
    } select {
        !(_x getVariable ["WL2_mineClearer", false])
    } select {
        !(_x getVariable ["WL2_isCollaborator", false])
    };

    if (count _enemyMines == 0 || count _ownedVehiclesEligible == 0) then {
        uiSleep 2;
        continue;
    };

    private _playVO = false;

    private _warningOn = cameraOn in _ownedVehiclesEligible;

    private _warningPositions = [];
    if (_warningOn) then {
        private _warningVelocityBase = velocityModelSpace cameraOn;
        private _mineWarnTime = _settingsMap getOrDefault ["mineWarnTime", 4];

        for "_i" from 1 to _mineWarnTime do {
            private _cameraVelocity = _warningVelocityBase vectorMultiply _i;
            private _warningPosition = cameraOn modelToWorld _cameraVelocity;
            _warningPositions pushBack _warningPosition;
        };
    };

    private _shouldWarn = false;
    {
        private _minefield = _x;

        private _mineData = _minefield getVariable ["WL2_minefield", []];
        private _mineArea = [getPosASL _minefield, _mineData # 0, _mineData # 1, getDir _minefield, _mineData # 2 == 1];

        if (_warningOn && !_shouldWarn) then {
            private _warningPositionsInArea = _warningPositions inAreaArray _mineArea;
            if (count _warningPositionsInArea > 0) then {
                _shouldWarn = true;
            };
        };

        private _vehiclesInThisMinefield = _ownedVehiclesEligible inAreaArray _mineArea;
        if (count _vehiclesInThisMinefield == 0) then {
            continue;
        };

        private _mineOwnerUid = _minefield getVariable ["BIS_WL_ownerAsset", "123"];
        private _mineOwner = if (_mineOwnerUid == "123") then {
            objNull
        } else {
            [_mineOwnerUid] call BIS_fnc_getUnitByUid;
        };

        {
            private _vehicle = _x;

            private _mine = createMine ["SLAMDirectionalMine", getPosASL _vehicle, [], 3];
            [_mine, [_mineOwner, _mineOwner]] remoteExec ["setShotParents", 2];

            private _startTime = serverTime;
            waitUntil {
                uiSleep 0.001;
                private _shotParents = getShotParents _mine;
                (_shotParents # 0) isEqualTo _mineOwner || serverTime - _startTime > 5
            };

            private _vehiclePosition = _vehicle modelToWorld [0, 1, 0];
            _vehiclePosition set [2, 0.3];
            _mine setPosATL _vehiclePosition;
            triggerAmmo _mine;

            _playVO = true;

            missionNamespace setVariable ["WL2_mineExplosion", true, 2];
        } forEach _vehiclesInThisMinefield;
    } forEach _enemyMines;

    if (_isServer) then {
        continue;
    };

    if (_playVO && serverTime - _lastPlayedVO > 10) then {
        playSoundUI ["a3\dubbing_f_epb\b_in\x15_mines\b_in_x15_mines_jam_0.ogg", 5, 1, false, 0.31];
        _lastPlayedVO = serverTime;
    };

    if (_shouldWarn) then {
        private _mineWarnVolume = _settingsMap getOrDefault ["mineWarnVolume", 1.5];
        playSoundUI ["a3\sounds_f\vehicles\air\heli_light_01\warning.wss", _mineWarnVolume];

        if (serverTime - _lastWarnTime > 5) then {
            ["Minefield warning! Check map!"] call WL2_fnc_smoothText;
            _lastWarnTime = serverTime;
        };
    };
};