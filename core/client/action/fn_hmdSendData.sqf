#include "includes.inc"
params ["_display"];

private _currentProfile = profileNamespace getVariable ["WL2_HMDSettingProfiles", []];
private _currentProfileIndex = uiNamespace getVariable ["WL2_HMDSettingProfileIndex", 0];
private _profileData = _currentProfile # _currentProfileIndex;

private _dataArray = [
    ["INFANTRY", 500],
    ["INFANTRY NAME", 500],
    ["VEHICLE", 5000],
    ["AIRCRAFT", 10000],
    ["AIR DEFENSE", 5000],
    ["MISSILE", 5000],
    ["LASER", 5000]
];

{
    private _profileValue = _profileData getOrDefault [_x select 0, -1];
    if (_profileValue != -1) then {
        _x set [1, _profileValue];
    };
} forEach _dataArray;

_dataArray = [["PROFILE", _currentProfileIndex]] + _dataArray;

private _selectorIndex = uiNamespace getVariable ["WL2_HMDSettingProfileSelectorIndex", 0];

private _text = "<t align='center' size='1.5'>HMD SETTINGS</t><br/><t size='0.7' align='center'>DISTANCE (M)</t><br/><br/>";
{
    _x params ["_name", "_value"];
    if (_forEachIndex == 0) then {
        _value = _value + 1;
    };
    if (_selectorIndex == _forEachIndex) then {
        _text = format ["%1<t align='left'><t color='#cb0014'>%2</t></t><t align='right'><t color='#cb0014'>%3</t></t><br/>", _text, _name, _value];
    } else {
        _text = format ["%1<t align='left'>%2</t><t align='right'>%3</t><br/>", _text, _name, _value];
    };
} forEach _dataArray;

private _mainControl = _display displayCtrl 7000;
_mainControl ctrlSetStructuredText parseText format ["<t shadow='2'>%1</t>", _text];