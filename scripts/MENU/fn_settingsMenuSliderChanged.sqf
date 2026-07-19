#include "includes.inc"
params ["_control", "_value"];
if (isNull _control) exitWith {};

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _settingId = _control getVariable ["WL2_settingId", ""];
if (_settingId == "") exitWith {};

private _valueControl = _control getVariable ["WL2_valueControl", controlNull];

if (!isNull _valueControl) then {
    _valueControl ctrlSetText (str _value);
};

private _settingsMap = _display getVariable ["WL2_settingsMap", createHashMap];
_settingsMap set [_settingId, _value];
_display setVariable ["WL2_settingsDirty", true];

private _labelControl = (ctrlParentControlsGroup _control) controlsGroupCtrl SETTINGS_SLIDER_LABEL_ID;
private _labelText = _labelControl getVariable ["WL2_labelText", ""];
private _defaultValue = _control getVariable ["WL2_default", 0];

private _newLabelText = if (_value != _defaultValue) then {
    format ["<t color='#cc6666'>%1* [Default: %2]</t>", _labelText, _defaultValue];
} else {
    _labelText;
};
_labelControl ctrlSetStructuredText parseText format ["%1", _newLabelText];

if (_control getVariable ["WL2_updateViewDistance", false]) then {
    [] call MENU_fnc_updateViewDistance;
};