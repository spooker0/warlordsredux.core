#include "includes.inc"
params ["_texture"];
private _currentProfile = profileNamespace getVariable ["WL2_HMDSettingProfiles", []];
private _currentProfileIndex = uiNamespace getVariable ["WL2_HMDSettingProfileIndex", 0];
private _profileData = _currentProfile # _currentProfileIndex;

private _dataArray = [
    ["INFANTRY", 0, 20000, 500, true],
    ["VEHICLE", 0, 20000, 5000, true],
    ["AIRCRAFT", 0, 20000, 10000, true],
    ["AIR DEFENSE", 0, 20000, 5000, true],
    ["MISSILE", 0, 20000, 5000, true], 
    ["LASER", 0, 20000, 5000, true]
];

{
    private _profileValue = _profileData getOrDefault [_x select 0, -1];
    if (_profileValue != -1) then {
        _x set [3, _profileValue];
    };
} forEach _dataArray;

_dataArray = [["PROFILE", 0, 4, _currentProfileIndex, false]] + _dataArray;

private _settingsJson = toJSON _dataArray;
_settingsJson = _texture ctrlWebBrowserAction ["ToBase64", _settingsJson];
_texture ctrlWebBrowserAction ["ExecJS", format ["updateData(atob('%1'), %2);", _settingsJson, 0]];