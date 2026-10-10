#include "includes.inc"
params ["_projectile"];

if !(_projectile isKindOf "MissileCore") exitWith {};

private _missileUpdateInitialized = _projectile getVariable ["WL_missileUpdateInitializedRemote", false];
if (_missileUpdateInitialized) exitWith {
    _projectile setVariable ["WL_missileUpdateInitializedRemote", true];
};

private _projectileNotify = [remoteExecutedOwner, clientOwner];
while { alive _projectile } do {
    private _missileDefeated = _projectile getVariable ["DIS_missileDefeated", false];
    if (_missileDefeated) then {
        break;
    };

    private _missileStateOverride = _projectile getVariable ["WL2_missileStateOverride", ""];
    if (_missileStateOverride != "") then {
        uiSleep 0.1;
        continue;
    };

    private _currentState = (missileState _projectile) # 1;
    if (_currentState == "LOST") then {
        _currentState = "SEARCH";
    };

    private _missileVarState = _projectile getVariable ["APS_missileState", "LOCKED"];
    if (_currentState != _missileVarState) then {
        _projectile setVariable ["APS_missileState", _currentState, _projectileNotify];
    };

    uiSleep 0.001;
};