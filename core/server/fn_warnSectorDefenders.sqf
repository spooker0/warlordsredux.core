#include "includes.inc"
params ["_sector", "_mode", ["_adderName", ""]];

if (!isServer) exitWith {};

private _sectorName = _sector getVariable ["WL2_name", localize "STR_WL_sector"];
private _message = switch (_mode) do {
    case -2: { format [localize "STR_WL_sectorReinforcementsSabotaged", _sectorName, _adderName] };
    case -1: { format [localize "STR_WL_sectorReinforcementsResupplied", _sectorName, _adderName] };
    case 0: { format [localize "STR_WL_sectorReinforcementsDepleted", _sectorName] };
    case 25: { format [localize "STR_WL_sectorReinforcements25", _sectorName] };
    case 50: { format [localize "STR_WL_sectorReinforcements50", _sectorName] };
    case 75: { format [localize "STR_WL_sectorReinforcements75", _sectorName] };
    default { "" };
};

private _revealedBy = _sector getVariable ["BIS_WL_revealedBy", []];
if (_revealedBy isEqualTo []) exitWith {};
[_message] remoteExec ["WL2_fnc_broadcastAction", _revealedBy];