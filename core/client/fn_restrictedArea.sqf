#include "..\warlords_constants.inc"

private _endEffect = {
    "Restrict" cutText ["", "PLAIN"];
    player setVariable ["WL_zoneRestrictKillTime", -1];
    sleep 2;
};

private _side = BIS_WL_playerSide;

while { !BIS_WL_missionEnd } do {
    private _pos = getPosASL player;
    private _findCurrentSector = BIS_WL_allSectors select {
        _pos inArea (_x getVariable "objectAreaComplete")
    };

    private _availableSectors = BIS_WL_sectorsArray # 3;
    private _currentSector = objNull;
    {
        if (_x in _availableSectors) then {
            private _revealedBy = _x getVariable ["BIS_WL_revealedBy", []];
            if !(_side in _revealedBy) then {
                _revealedBy pushBackUnique _side;
                _x setVariable ["BIS_WL_revealedBy", _revealedBy, true];
                [_x, _side] remoteExec ["WL2_fnc_sectorRevealHandle", 0];
            };
        } else {
            _currentSector = _x;
        };
    } forEach _findCurrentSector;

    if (isNull _currentSector) then {
        private _buffer = 5000;
        if (_pos # 0 > -WL_MAP_RESTRICTION_BUFFER &&
            _pos # 0 < worldSize + WL_MAP_RESTRICTION_BUFFER &&
            _pos # 1 > -WL_MAP_RESTRICTION_BUFFER &&
            _pos # 1 < worldSize + WL_MAP_RESTRICTION_BUFFER) then {
            call _endEffect;
            continue;
        };
    } else {
        private _isCarrierSector = _currentSector getVariable ["WL2_isAircraftCarrier", false];

        private _altOk = if (_isCarrierSector) then {
            private _heightASL = getPosASL player # 2;
            _heightASL < 20 || _heightASL > 75;
        } else {
            getPosATL player # 2 > 50;
        };

        if (_altOk) then {
            call _endEffect;
            continue;
        };

        private _speed = speed player;
        private _speedOk = _speed > 75;
        if (_speedOk) then {
            call _endEffect;
            continue;
        };
    };

    if (player getVariable ["WL_zoneRestrictKillTime", -1] == -1) then {
        player setVariable ["WL_zoneRestrictKillTime", serverTime + 80];
    };

    private _restrictDisplay = uiNamespace getVariable ["RscWLZoneRestrictionDisplay", displayNull];
    if (isNull _restrictDisplay) then {
        "Restrict" cutRsc ["RscWLZoneRestrictionDisplay", "PLAIN", -1, true, true];
    };

    private _restrictTimer = _restrictDisplay displayCtrl 9000;
    private _timeRemaining = (player getVariable "WL_zoneRestrictKillTime") - serverTime;
    _restrictTimer ctrlSetText format ["%1", round _timeRemaining];

    if (_timeRemaining < 0) then {
        (vehicle player) setDamage 1;
        player setDamage 1;
        call _endEffect;
    };

    sleep 0.3;
};