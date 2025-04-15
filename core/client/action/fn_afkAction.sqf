#include "..\..\warlords_constants.inc"

player addAction [
    "<t color='#ff0000'>NOT AFK</t>",
    {
        params ["_target", "_caller", "_actionId", "_argument"];
        missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_AFK_TIMER];
        player setVariable ["WL2_afk", false, [clientOwner, 2]];
        hintSilent "";

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