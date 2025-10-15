#include "includes.inc"
player addAction [
    "<t color='#ff0000'>NOT AFK</t>",
    {
        params ["_target", "_caller", "_actionId", "_argument"];
        missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_DURATION_AFKTIME];
        player setVariable ["WL2_afk", false, [clientOwner, 2]];
        hintSilent "";

        private _afkLog = profileNamespace getVariable ["WL2_afkLog", createHashMap];
        _afkLog set [[systemTimeUTC] call MENU_fnc_printSystemTime, (estimatedEndServerTime - serverTime) / 60];
        profileNamespace setVariable ["WL2_afkLog", _afkLog];

        player removeAction _actionId;
        call WL2_fnc_afkAction;
    },
    nil,
    round (random [0, 3, 6]),
    false,
    true,
    "",
    "_this == player && player getVariable ['WL2_afk', false]",
    -1
];