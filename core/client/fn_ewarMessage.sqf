#include "includes.inc"
params ["_message", "_isFriendly"];

private _display = uiNamespace getVariable ["WL2_ewarDisplay", displayNull];
if (isNull _display) exitWith {};

private _texture = _display displayCtrl 5501;

if (_message == "reset") exitWith {
    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_fatal.wss", 1];
    closeDialog 0;
};

if (_isFriendly) then {
    playSoundUI ["A3\ui_f\data\sound\RscListbox\soundselect.wss", 1];
    _texture ctrlWebBrowserAction ["ExecJS", format ["reveal(%1);", _message]];
} else {
    playSoundUI ["a3\ui_f_curator\data\sound\cfgsound\error01.wss", 1];
    // private _split = _message splitString ",";
    // if (count _split != 2) exitWith {};
    // private _solvedIndex = _split select 1;
    // _texture ctrlWebBrowserAction ["ExecJS", format ["hint(%1);", _solvedIndex]];
};