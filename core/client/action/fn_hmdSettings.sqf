#include "includes.inc"
private _display = uiNamespace getVariable ["RscWLHmdSettingMenu", displayNull];
if !(isNull _display) then {
    "hmd" cutText ["", "PLAIN"];
};
"hmd" cutRsc ["RscWLHmdSettingMenu", "PLAIN", -1, true, true];
_display = uiNamespace getVariable ["RscWLHmdSettingMenu", displayNull];
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

// init
uiNamespace setVariable ["WL2_HMDSettingProfileIndex", 0];
private _existingProfiles = profileNamespace getVariable ["WL2_HMDSettingProfiles", []];
if (count _existingProfiles != 5) then {
    private _profile1 = createHashMapFromArray [
        ["INFANTRY", 500],
        ["INFANTRY NAME", 250],
        ["VEHICLE", 5000],
        ["AIRCRAFT", 10000],
        ["AIR DEFENSE", 5000],
        ["MISSILE", 5000],
        ["LASER", 5000]
    ];
    private _profile2 = createHashMapFromArray [
        ["INFANTRY", 0],
        ["INFANTRY NAME", 0],
        ["VEHICLE", 4000],
        ["AIRCRAFT", 20000],
        ["AIR DEFENSE", 8000],
        ["MISSILE", 20000],
        ["LASER", 4000]
    ];
    private _profile3 = createHashMapFromArray [
        ["INFANTRY", 4000],
        ["INFANTRY NAME", 4000],
        ["VEHICLE", 4000],
        ["AIRCRAFT", 4000],
        ["AIR DEFENSE", 4000],
        ["MISSILE", 4000],
        ["LASER", 4000]
    ];
    private _profile4 = createHashMapFromArray [
        ["INFANTRY", 20000],
        ["INFANTRY NAME", 20000],
        ["VEHICLE", 20000],
        ["AIRCRAFT", 20000],
        ["AIR DEFENSE", 20000],
        ["MISSILE", 20000],
        ["LASER", 20000]
    ];
    private _profile5 = createHashMapFromArray [
        ["INFANTRY", 0],
        ["INFANTRY NAME", 0],
        ["VEHICLE", 0],
        ["AIRCRAFT", 0],
        ["AIR DEFENSE", 0],
        ["MISSILE", 0],
        ["LASER", 0]
    ];

    profileNamespace setVariable ["WL2_HMDSettingProfiles", [
        _profile1, _profile2, _profile3, _profile4, _profile5
    ]];
};

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    [_texture] call WL2_fnc_hmdSendData;
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_control", "_isConfirmDialog", "_message"];

    playSoundUI ["a3\sounds_f_mark\arsenal\sfx\bipods\bipod_generic_deploy.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    _message = fromJSON _message;
    if (count _message == 2) then {
        private _setting = _message select 0;
        private _value = _message select 1;

        if (_setting == "PROFILE") then {
            uiNamespace setVariable ["WL2_HMDSettingProfileIndex", _value];

            [_control] call WL2_fnc_hmdSendData;
        } else {
            private _currentProfile = profileNamespace getVariable ["WL2_HMDSettingProfiles", []];
            private _currentProfileIndex = uiNamespace getVariable ["WL2_HMDSettingProfileIndex", 0];
            private _profileData = _currentProfile # _currentProfileIndex;
            _profileData set [_setting, _value];
        };
    };

    true;
}];

(findDisplay 46) displayAddEventHandler ["KeyDown", {
    params ["_control", "_key"];
    private _display = uiNamespace getVariable ["RscWLHmdSettingMenu", displayNull];
    if (isNull _display) exitWith {
        (findDisplay 46) displayRemoveEventHandler ["KeyDown", _thisEventHandler];
        false;
    };

    private _texture = _display displayCtrl 5502;
    private _interceptKey = false;
    if (_key in actionKeys "BuldLeft") then {
        _texture ctrlWebBrowserAction ["ExecJS", "settingMinus();"];
        _interceptKey = true;
    };
    if (_key in actionKeys "BuldRight") then {
        _texture ctrlWebBrowserAction ["ExecJS", "settingPlus();"];
        _interceptKey = true;
    };
    if (_key in actionKeys "BuldBack") then {
        _texture ctrlWebBrowserAction ["ExecJS", "currentSettingNext();"];
        _interceptKey = true;
    };
    if (_key in actionKeys "BuldForward") then {
        _texture ctrlWebBrowserAction ["ExecJS", "currentSettingPrev();"];
        _interceptKey = true;
    };

    _interceptKey;
}];

while { !isNull _display } do {
    if !(cameraOn getVariable ['WL2_hasHMD', false] || typeof cameraOn == "Camera") then {
        "hmd" cutText ["", "PLAIN"];
    };
    uiSleep 0.1;
};