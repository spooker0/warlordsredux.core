#include "includes.inc"
params ["_control"];
if (isNull _control) exitWith {};

private _actionId = _control getVariable ["WL2_actionId", ""];
if (_actionId == "") exitWith {};

playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 1];

private _display = ctrlParent _control;

if (!isNull _display) then {
    _display closeDisplay 2;
};

switch (_actionId) do {
    case "spawn": {
        0 spawn SQD_fnc_initSquadMenu;
    };
    case "badges": {
        0 spawn RWD_fnc_badgeMenuInit;
    };
    case "report": {
        0 spawn REP_fnc_reportMenu;
    };
    case "poll": {
        0 spawn POLL_fnc_pollMenu;
    };
    case "performance": {
        0 spawn PERF_fnc_perfMenuInit;
    };
    case "resetAll": {
        0 spawn MENU_fnc_resetDefault;
    };
    case "debug": {
        [""] spawn MENU_fnc_debugMenu;
    };
    case "spectate": {
        0 spawn SPEC_fnc_spectator;
    };
    case "moderate": {
        0 spawn REP_fnc_modMenu;
    };
    default {};
};