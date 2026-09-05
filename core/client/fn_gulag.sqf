#include "includes.inc"
params ["_timeout", "_reason"];

0 fadeEnvironment 0;
disableUserInput true;

private _dialog = createDialog ["RscWLGulag", true];
_dialog displayAddEventHandler ["KeyDown", {
    params ["_control", "_key"];
    _key == 1
}];

private _backgroundLabel = _dialog displayCtrl 100;

while { serverTime < _timeout && !(isNull _dialog) } do {
    private _timeLeft = [(_timeout - serverTime) max 0, "HH:MM:SS"] call BIS_fnc_secondsToString;
    _backgroundLabel ctrlSetText format ["You have been timed out.\nReason: %1\nTimeout: %2", _reason, _timeLeft];
    uiSleep 0.2;
};

closeDialog 0;
disableUserInput false;
0 fadeEnvironment 1;