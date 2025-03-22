params ["_projectile"];

if !(_projectile isKindOf "MissileCore") exitWith {};

private _missileTarget = missileTarget _projectile;
if (isNull _missileTarget) exitWith {};

private _missileUpdateInitialized = _projectile getVariable ["WL_missileUpdateInitialized", false];
if (_missileUpdateInitialized) exitWith {
    _projectile setVariable ["WL_missileUpdateInitialized", true];
};

private _projectileNotify = [remoteExecutedOwner, clientOwner];
while { alive _projectile } do {
    private _currentState = (missileState _projectile) # 1;
    private _missileVarState = _projectile getVariable ["APS_missileState", "LOCKED"];
    if (_currentState != _missileVarState) then {
        _projectile setVariable ["APS_missileState", _currentState, _projectileNotify];
    };

    sleep 0.001;
};