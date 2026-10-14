#include "includes.inc"
params ["_display", "_cue", "_sound"];
private _closed = _display getVariable ["TUT_closed", true];
if (isNull _display || _closed) exitWith {};

private _played = _display getVariable ["TUT_soundCues", createHashMap];
if (_cue in _played) exitWith {};
_played set [_cue, true];
_display setVariable ["TUT_soundCues", _played];
private _soundId = playSoundUI _sound;
private _sounds = _display getVariable ["TUT_sounds", []];
_sounds pushBack _soundId;
_display setVariable ["TUT_sounds", _sounds];
