#include "includes.inc"
params ["_display", "_cue", "_sound"];
if (isNull _display || { _display getVariable ["INTRO_closed", false] }) exitWith {};

private _played = _display getVariable ["INTRO_soundCues", createHashMap];
if (_cue in _played) exitWith {};
_played set [_cue, true];
_display setVariable ["INTRO_soundCues", _played];
playSoundUI _sound;