#include "includes.inc"
params ["_driverProxies"];

["Resist!"] call WL2_fnc_smoothText;

if !(WL_ISUP(player)) then {
    setPlayerRespawnTime 0.1;
    forceRespawn player;

    waitUntil {
        uiSleep 0.1;
        WL_ISUP(player);
    };
};

uiNamespace setVariable ["WL2_canBuy", false];

private _playerUid = getPlayerUID player;

private _driverIndex = -1;
while { count (_driverProxies select { alive _x }) > 0 && WL_ISUP(player) } do {
    _driverIndex = (_driverIndex + 1) mod (count _driverProxies);
    private _driverProxy = _driverProxies # _driverIndex;

    if (!alive _driverProxy) then {
        continue;
    };

    private _collaborateVehicle = vehicle _driverProxy;

    _collaborateVehicle setVariable ["BIS_WL_ownerAsset", _playerUid, true];
    _collaborateVehicle setVariable ["BIS_WL_ownerAssetSide", side group player, true];
    _collaborateVehicle setVariable ["WL2_assetOwnerName", "", true];
    _collaborateVehicle setVariable ["WL2_isCollaborator", true, true];

    private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", _playerUid];
    private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
    _ownedVehicles pushBack _collaborateVehicle;
    missionNamespace setVariable [_ownedVehicleVar, _ownedVehicles, true];

    switchCamera _collaborateVehicle;
    player remoteControl _driverProxy;
    _collaborateVehicle setEffectiveCommander _driverProxy;

    _driverProxy addEventHandler ["GetInMan", {
        params ["_unit", "_role", "_vehicle", "_turret"];
        _vehicle setEffectiveCommander _unit;
    }];

    waitUntil {
        uiSleep 0.1;
        !WL_ISUP(_driverProxy) || !WL_ISUP(player) || focusOn != _driverProxy;
    };

    uiSleep 1;

    switchCamera player;
    player remoteControl objNull;

    uiSleep 1;
};

switchCamera player;
player remoteControl objNull;
uiNamespace setVariable ["WL2_canBuy", true];