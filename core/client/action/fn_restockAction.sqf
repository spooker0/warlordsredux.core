#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

[
    _asset,
    "<t color='#4bff58'>Restock to customization</t>",
    "\A3\Ui_f\data\IGUI\Cfg\HoldActions\holdAction_loadDevice_ca.paa",
    "\A3\Ui_f\data\IGUI\Cfg\HoldActions\holdAction_loadDevice_ca.paa",
    "true",
    "true",
    {
        params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];
		playSound3D ["a3\sounds_f\arsenal\weapons_static\static_gmg\reload_static_gmg.wss", _caller, false, getPosASL _caller, 2, 5.0, 50, 0, true];
    },
    {},
    {
        params ["_asset", "_caller", "_actionId"];
        WL2_lastLoadout = getUnitLoadout player;
        [_caller, false] call WLC_fnc_onRespawn;
        [] call WL2_fnc_factionBasedClientInit;
    },
    {},
    [],
    0.5,
	100,
	false,
	false
] call BIS_fnc_holdActionAdd;