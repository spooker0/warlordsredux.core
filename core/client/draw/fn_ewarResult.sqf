#include "includes.inc"

private _filmGrain = -1;

private _initFilmGrain = {
    _filmGrain = ppEffectCreate ["filmGrain", 2000];
    _filmGrain ppEffectAdjust [1, 0.5];
    _filmGrain ppEffectEnable false;
    _filmGrain ppEffectForceInNVG true;
    _filmGrain ppEffectCommit 0;
};

private _shouldDisableJamEffect = {
    if (isNull _asset) exitWith { true };
    if (WL_ISDOWN(player)) exitWith { true };
    if (_asset distance player < WL_JAMMER_HARDLINE_RANGE) exitWith { true };
    if (_asset == player) exitWith { true };
    if !([_asset] call WL2_fnc_isDrone) exitWith { true };

    private _friendlySignalVar = format ["WL2_ewarSignal_%1", BIS_WL_playerSide];
    private _friendlySignal = missionNamespace getVariable [_friendlySignalVar, 500];
    if (_friendlySignal > 350) exitWith { true };

    false
};

call _initFilmGrain;

while { !BIS_WL_missionEnd } do {
    uiSleep 2;

    private _asset = cameraOn;
    private _eligibleDrones = missionNamespace getVariable ["WL2_eligibleDrones", []];

    private _reportDrones = _eligibleDrones select {
        alive _x;
    } select {
        !(_x isKindOf "StaticWeapon")
    };
    [_reportDrones, 10] remoteExec ["WL2_fnc_reportTargets", BIS_WL_enemySide];

    if (call _shouldDisableJamEffect) then {
        _filmGrain ppEffectEnable false;
        _asset disableTIEquipment false;
        continue;
    };

    if (_filmGrain == -1 || !(ppEffectCommitted _filmGrain)) then {
        call _initFilmGrain;
    };
    _filmGrain ppEffectEnable true;
    _asset disableTIEquipment true;

    _filmGrain ppEffectAdjust [1, 0.5];
    _filmGrain ppEffectCommit 0;
};