params ["_target", "_vehicle", "_missile"];

if (isNull _missile) exitWith {};
_missile setVariable ["WL_launcher", _vehicle];
private _incomingMissiles = _target getVariable ["WL_incomingMissiles", []];
private _originalIncomingMissiles = +_incomingMissiles;
_incomingMissiles pushBackUnique _missile;
_incomingMissiles = _incomingMissiles select {
    !(isNull _x) && alive _x;
};
if (_incomingMissiles isEqualTo _originalIncomingMissiles) exitWith {};
_target setVariable ["WL_incomingMissiles", _incomingMissiles];
_target setVariable ["WL_incomingLauncherLastKnown", _vehicle];