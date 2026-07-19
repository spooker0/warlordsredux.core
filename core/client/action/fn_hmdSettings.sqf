#include "includes.inc"
private _display = uiNamespace getVariable ["RscWLHmdSettingDisplay", displayNull];
if !(isNull _display) then {
    "hmd" cutText ["", "PLAIN"];
};
"hmd" cutRsc ["RscWLHmdSettingDisplay", "PLAIN", -1, true, true];
_display = uiNamespace getVariable ["RscWLHmdSettingDisplay", displayNull];

// init
private _existingProfiles = missionProfileNamespace getVariable ["WL2_HMDSettingProfiles", []];
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

    missionProfileNamespace setVariable ["WL2_HMDSettingProfiles", [
        _profile1, _profile2, _profile3, _profile4, _profile5
    ]];
};

uiNamespace setVariable ["WL2_HMDSettingProfileSelectorIndex", 0];
[_display] call WL2_fnc_hmdSendData;

(findDisplay 46) displayAddEventHandler ["KeyDown", {
    params ["_control", "_key"];
    private _display = uiNamespace getVariable ["RscWLHmdSettingDisplay", displayNull];
    if (isNull _display) exitWith {
        (findDisplay 46) displayRemoveEventHandler ["KeyDown", _thisEventHandler];
        false;
    };

    private _selectorIndex = uiNamespace getVariable ["WL2_HMDSettingProfileSelectorIndex", 0];
    private _currentProfile = missionProfileNamespace getVariable ["WL2_HMDSettingProfiles", []];
    private _currentProfileIndex = uiNamespace getVariable ["WL2_HMDSettingProfileIndex", 0];
    private _profileData = _currentProfile # _currentProfileIndex;
    private _currentProfileSelectorValue = WL_HMD_CATEGORIES # ((_selectorIndex - 1) max 0);

    private _interceptKey = false;
    if (_key in actionKeys "BuldLeft") then {
        if (_selectorIndex == 0) then {
            _currentProfileIndex = (_currentProfileIndex - 1) max 0;
            uiNamespace setVariable ["WL2_HMDSettingProfileIndex", _currentProfileIndex];
        } else {
            private _currentIndex = WL_HMD_DISTANCE_VALUES find (_profileData getOrDefault [_currentProfileSelectorValue, 500]);
            _currentIndex = (_currentIndex - 1) max 0;
            _profileData set [_currentProfileSelectorValue, WL_HMD_DISTANCE_VALUES # _currentIndex];
        };
        _interceptKey = true;
    };
    if (_key in actionKeys "BuldRight") then {
        if (_selectorIndex == 0) then {
            _currentProfileIndex = (_currentProfileIndex + 1) min 4;
            uiNamespace setVariable ["WL2_HMDSettingProfileIndex", _currentProfileIndex];
        } else {
            private _currentIndex = WL_HMD_DISTANCE_VALUES find (_profileData getOrDefault [_currentProfileSelectorValue, 500]);
            _currentIndex = (_currentIndex + 1) min (count WL_HMD_DISTANCE_VALUES - 1);
            _profileData set [_currentProfileSelectorValue, WL_HMD_DISTANCE_VALUES # _currentIndex];
        };
        _interceptKey = true;
    };
    if (_key in actionKeys "BuldBack") then {
        _selectorIndex = (_selectorIndex + 1) min 7;
        uiNamespace setVariable ["WL2_HMDSettingProfileSelectorIndex", _selectorIndex];
        _interceptKey = true;
    };
    if (_key in actionKeys "BuldForward") then {
        _selectorIndex = (_selectorIndex - 1) max 0;
        uiNamespace setVariable ["WL2_HMDSettingProfileSelectorIndex", _selectorIndex];
        _interceptKey = true;
    };

    if (_interceptKey) then {
        playSoundUI ["a3\sounds_f_mark\arsenal\sfx\bipods\bipod_generic_deploy.wss", 0.5];
        [_display] call WL2_fnc_hmdSendData;
    };

    _interceptKey;
}];

while { !isNull _display } do {
    if !(cameraOn getVariable ['WL2_hasHMD', false] || typeof cameraOn == "Camera") then {
        "hmd" cutText ["", "PLAIN"];
    };
    uiSleep 0.1;
};