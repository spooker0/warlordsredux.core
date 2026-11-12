#include "includes.inc"
player addAction [
    format ["<t color='#ff0000'>HMD Settings (%1)</t>", (actionKeysNames "binocular") regexReplace ["""", ""]],
    {
        params ["_target", "_caller", "_actionId", "_argument"];
        private _display = uiNamespace getVariable ["RscWLHmdSettingDisplay", displayNull];
        if (isNull _display) then {
            0 spawn WL2_fnc_hmdSettings;
            ["HMDSettings", [localize "STR_WL_hmdSettings", [
                [localize "STR_WL_hmdDecrease", "BuldLeft"],
                [localize "STR_WL_hmdIncrease", "BuldRight"],
                [localize "STR_WL_hmdNext", "BuldBack"],
                [localize "STR_WL_hmdPrev", "BuldForward"]
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