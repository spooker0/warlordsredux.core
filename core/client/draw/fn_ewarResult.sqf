#include "includes.inc"

private _filmGrain = -1;

private _initFilmGrain = {
    _filmGrain = ppEffectCreate ["filmGrain", 2000];
    _filmGrain ppEffectAdjust [1, 0.5];
    _filmGrain ppEffectEnable false;
    _filmGrain ppEffectForceInNVG true;
    _filmGrain ppEffectCommit 0;
};

call _initFilmGrain;

while { !BIS_WL_missionEnd } do {
    uiSleep 5;

    private _asset = cameraOn;

    if (isNull _asset) then {
        continue;
    };

    private _friendlySignalVar = format ["WL2_ewarSignal_%1", BIS_WL_playerSide];
    private _friendlySignal = missionNamespace getVariable [_friendlySignalVar, 500];

    private _eligibleDrones = missionNamespace getVariable ["WL2_eligibleDrones", []];

    if (_friendlySignal > 350) then {
        _asset disableTIEquipment false;
        continue;
    };

    private _reportDrones = _eligibleDrones select {
        alive _x;
    } select {
        !(_x isKindOf "StaticWeapon")
    };
    [_reportDrones, 10] remoteExec ["WL2_fnc_reportTargets", BIS_WL_enemySide];

    if (_asset == player) then {
        _filmGrain ppEffectEnable false;
        continue;
    };

    private _isInDrone = [_asset] call WL2_fnc_isDrone;
    if (!_isInDrone) then {
        _filmGrain ppEffectEnable false;
        continue;
    };

    if (_filmGrain == -1 || !(ppEffectCommitted _filmGrain)) then {
        call _initFilmGrain;
    };
    _filmGrain ppEffectEnable true;
    _filmGrain ppEffectAdjust [1, 0.5];
    _filmGrain ppEffectCommit 0;

    _asset disableTIEquipment true;
};