#include "includes.inc"
params ["_sector", "_mode"];

if (!isServer) exitWith {};

private _sectorName = _sector getVariable ["WL2_name", "Sector"];
private _message = switch (_mode) do {
    case -1: { format ["%1 has been resupplied with reinforcements!", _sectorName] };
    case 0: { format ["%1 has run out of reinforcements!", _sectorName] };
    case 25: { format ["%1 has 25%% reinforcements remaining!", _sectorName] };
    case 50: { format ["%1 has 50%% reinforcements remaining!", _sectorName] };
    case 75: { format ["%1 has 75%% reinforcements remaining!", _sectorName] };
    default { "" };
};

private _revealedBy = _sector getVariable ["BIS_WL_revealedBy", []];
if (_revealedBy isEqualTo []) exitWith {};
[_message] remoteExec ["WL2_fnc_broadcastAction", _revealedBy];