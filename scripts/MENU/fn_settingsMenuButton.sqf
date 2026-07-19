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
    case "SPAWN": {
        0 spawn SQD_fnc_initSquadMenu;
    };
    case "BADGES": {
        0 spawn RWD_fnc_badgeMenu;
    };
    case "REPORT": {
        0 spawn MENU_fnc_reportMenu;
    };
    case "POLL": {
        0 spawn POLL_fnc_pollMenu;
    };
    case "PERF": {
        0 spawn PERF_fnc_perfMenuInit;
    };
    case "RESET ALL": {
        0 spawn MENU_fnc_resetDefault;
    };
    case "DEBUG": {
        [""] spawn MENU_fnc_debugMenu;
    };
    case "SPECTATE": {
        0 spawn SPEC_fnc_spectator;
    };
    case "MODERATE": {
        0 spawn MENU_fnc_modMenu;
    };
    default {};
};