#include "includes.inc"
params ["_driverProxies"];

if !(WL_ISUP(player)) then {
    setPlayerRespawnTime 0.1;
    forceRespawn player;

    waitUntil {
        uiSleep 0.1;
        WL_ISUP(player);
    };
};

private _sideBase = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
[0, _sideBase] spawn WL2_fnc_executeFastTravel;

["Resist!"] call WL2_fnc_smoothText;

uiNamespace setVariable ["WL2_canBuy", false];

private _playerUid = getPlayerUID player;
private _playerSide = side group player;

private _newVehicles = [];
{
    private _vehicle = vehicle _x;

    _vehicle setVariable ["BIS_WL_ownerAsset", _playerUid, true];
    _vehicle setVariable ["BIS_WL_ownerAssetSide", _playerSide, true];
    _vehicle setVariable ["WL2_assetOwnerName", "", true];
    _vehicle setVariable ["WL2_isCollaborator", true, true];

    _x addEventHandler ["GetInMan", {
        params ["_unit", "_role", "_vehicle", "_turret"];
        _vehicle setEffectiveCommander _unit;
    }];

    _newVehicles pushBack _vehicle;
} forEach _driverProxies;

private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", _playerUid];
private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
_ownedVehicles append _newVehicles;
missionNamespace setVariable [_ownedVehicleVar, _ownedVehicles, true];

private _driverIndex = -1;
while { count (_driverProxies select { alive _x }) > 0 && WL_ISUP(player) } do {
    _driverIndex = (_driverIndex + 1) mod (count _driverProxies);
    private _driverProxy = _driverProxies # _driverIndex;

    if (!alive _driverProxy) then {
        continue;
    };

    private _collaborateVehicle = vehicle _driverProxy;
    switchCamera _collaborateVehicle;
    player remoteControl _driverProxy;
    _collaborateVehicle setEffectiveCommander _driverProxy;

    waitUntil {
        uiSleep 0.1;
        !WL_ISUP(_driverProxy) || !WL_ISUP(player) || focusOn != _driverProxy;
    };

    if (!WL_ISUP(player)) then {
        break;
    };

    uiSleep 1;

    switchCamera player;
    player remoteControl objNull;

    uiSleep 1;
};

switchCamera player;
player remoteControl objNull;
uiNamespace setVariable ["WL2_canBuy", true];