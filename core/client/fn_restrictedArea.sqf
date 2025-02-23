private _soundId = -1;

private _endEffect = {
    "Restrict" cutText ["", "PLAIN"];
    player setVariable ["WL_zoneRestrictKillTime", -1];
    if (_soundId != -1) then {
        stopSound _soundId;
        _soundId = -1;
    };
};

while { !BIS_WL_missionEnd } do {
    sleep 0.5;

    private _findCurrentSector = (BIS_WL_allSectors - (BIS_WL_sectorsArray # 3)) select {
        player inArea (_x getVariable "objectAreaComplete")
    };

    if (count _findCurrentSector == 0) then {
        call _endEffect;
        continue;
    };

    private _currentSector = _findCurrentSector # 0;
    private _isCarrierSector = count (_currentSector getVariable ["WL_aircraftCarrier", []]) > 0;

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

    if (player getVariable ["WL_zoneRestrictKillTime", -1] == -1) then {
        player setVariable ["WL_zoneRestrictKillTime", serverTime + 80];
    };

    if (_soundId == -1 || count (soundParams _soundId) == 0) then {
        _soundId = playSoundUI ["air_raid", 3];
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
};