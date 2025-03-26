params ["_projectile"];

if !(_projectile isKindOf "MissileCore") exitWith {};

private _missileTarget = missileTarget _projectile;
if (isNull _missileTarget) exitWith {};

private _missileUpdateInitialized = _projectile getVariable ["WL_missileUpdateInitializedRemote", false];
if (_missileUpdateInitialized) exitWith {
    _projectile setVariable ["WL_missileUpdateInitializedRemote", true];
};

private _projectileNotify = [remoteExecutedOwner, clientOwner];
while { alive _projectile } do {
    private _currentState = (missileState _projectile) # 1;
    private _notched = _projectile getVariable ["DIS_notched", false];
    if (_notched) then {
        _projectile setMissileTarget objNull;
        _currentState = "NOTCHED";
    };
    private _missileVarState = _projectile getVariable ["APS_missileState", "LOCKED"];
    if (_currentState != _missileVarState) then {
        _projectile setVariable ["APS_missileState", _currentState, _projectileNotify];
    };

    sleep 0.001;
};