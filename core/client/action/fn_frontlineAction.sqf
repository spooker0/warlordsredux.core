#include "includes.inc"
params ["_asset"];

_asset addAction [
    format ["<t color='#4bff58'>%1</t>", localize "STR_WL_travelFrontline"],
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _travelResult = [true] call WL2_fnc_travelTeamPriority;
        if (_travelResult) then {
            playSoundUI ["AddItemOk"];
        } else {
            playSoundUI ["AddItemFailed"];
            [localize "STR_WL_conscriptFailed"] call WL2_fnc_smoothText;
        };
    },
    [],
    90,
    false,
    true,
    "",
    "!isWeaponDeployed player && vehicle player == player && player distance2D ([BIS_WL_playerSide] call WL2_fnc_getSideBase) < 100",
    20,
    false
];