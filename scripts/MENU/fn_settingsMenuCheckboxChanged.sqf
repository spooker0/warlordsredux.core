#include "includes.inc"
params ["_control", "_checked"];
if (isNull _control) exitWith {};

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _settingId = _control getVariable ["WL2_settingId", ""];
if (_settingId == "") exitWith {};

playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

private _settingsMap = _display getVariable ["WL2_settingsMap", createHashMap];
private _newValue = _checked > 0;
_settingsMap set [_settingId, _newValue];
_display setVariable ["WL2_settingsDirty", true];

private _labelControl = (ctrlParentControlsGroup _control) controlsGroupCtrl SETTINGS_CHECKBOX_LABEL_ID;
private _labelText = _labelControl getVariable ["WL2_labelText", ""];
private _defaultValue = _control getVariable ["WL2_defaultValue", false];

private _newLabelText = if (_newValue != _defaultValue) then {
    format ["<t color='#cc6666'>%1*</t>", _labelText];
} else {
    _labelText;
};
_labelControl ctrlSetStructuredText parseText format ["%1", _newLabelText];