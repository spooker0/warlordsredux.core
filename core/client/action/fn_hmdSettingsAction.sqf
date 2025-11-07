#include "includes.inc"
player addAction [
    format ["<t color='#ff0000'>HMD Settings (%1)</t>", (actionKeysNames "binocular") regexReplace ["""", ""]],
    {
        params ["_target", "_caller", "_actionId", "_argument"];
        private _display = uiNamespace getVariable ["RscWLHmdSettingMenu", displayNull];
        if (isNull _display) then {
            0 spawn WL2_fnc_hmdSettings;
            ["HMDSettings", ["HMD SETTINGS", [
                ["Decrease value", "BuldLeft"],
                ["Increase value", "BuldRight"],
                ["Next setting", "BuldBack"],
                ["Previous setting", "BuldForward"]
            ]], 10] spawn WL2_fnc_showHint;
        } else {
            "hmd" cutText ["", "PLAIN"];
        };
    },
    nil,
    4,
    false,
    true,
    "binocular",
    "cameraOn getVariable ['WL2_hasHMD', false]",
    -1
];