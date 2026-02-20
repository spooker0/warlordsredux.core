#include "includes.inc"
params ["_isSecured", "_secureObject"];

if (isDedicated) exitWith {};

private _previousRespawnBag = player getVariable ["WL2_respawnBag", objNull];
if (isNull _previousRespawnBag) exitWith {};

if (_isSecured) then {
    private _distance = _secureObject distance _previousRespawnBag;
    if (_distance < 100) then {
        player setVariable ["WL2_respawnBag", objNull];
        deleteVehicle _previousRespawnBag;
        ["Tent removed."] call WL2_fnc_smoothText;
    };
} else {
    player setVariable ["WL2_respawnBag", objNull];
    deleteVehicle _previousRespawnBag;
};