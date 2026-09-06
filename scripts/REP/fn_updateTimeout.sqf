#include "includes.inc"
params ["_display", ["_normalize", false]];
if (isNull _display) exitWith { [REP_DEFAULT_DURATION, REP_DEFAULT_REASON] };

private _durationControl = _display displayCtrl REP_DURATION_IDC;
private _reasonControl = _display displayCtrl REP_REASON_IDC;
private _sliderControl = _display displayCtrl REP_SLIDER_IDC;
private _submitButton = _display displayCtrl REP_SUBMIT_IDC;

private _durationText = trim ctrlText _durationControl;
private _duration = parseNumber _durationText;
if (!finite _duration || _duration <= 0) then {
    _duration = REP_DEFAULT_DURATION;
};

private _playerUid = getPlayerUID player;
private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
if (!_isAdmin) then {
    _duration = _duration min REP_MAX_DURATION;
};

private _reason = trim ctrlText _reasonControl;
if (_reason == "") then {
    _reason = REP_DEFAULT_REASON;
};

if (_normalize) then {
    _durationControl ctrlSetText str _duration;
    _sliderControl sliderSetPosition _duration;
};

private _playerName = _display getVariable ["REP_selectedName", ""];
private _caption = format ["Timeout %1 for %2 minutes", _playerName, _duration];
private _captionText = text _caption;
_captionText setAttributes ["color", "#080809", "font", "RobotoCondensed", "align", "left", "shadow", "false"];

_submitButton ctrlSetStructuredText composeText [_captionText];
_submitButton ctrlSetTooltip _caption;

[_duration, _reason]
