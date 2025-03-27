#include "..\..\warlords_constants.inc"
params ["_asset"];

if (isDedicated) exitWith {};

_asset addAction [
    "<t color='#ff0000'>Control Station</t>",
    {
        params ["_asset", "_caller", "_actionId", "_arguments"];
        private _inUseBy = _asset getVariable ["DIS_remoteInUseBy", objNull];
        if !(isNull _inUseBy) exitWith {
            systemChat "This station is already in use!";
            playSound "AddItemFailed";
        };

        private _teamVehiclesVar = format ["BIS_WL_%1OwnedVehicles", BIS_WL_playerSide];
        private _teamVehicles = missionNamespace getVariable [_teamVehiclesVar, []];
        private _controllableJets = _teamVehicles select {
            private _assetActualType = _x getVariable ["WL2_orderedClass", typeof _x];
            private _hasRemoteBombMap = missionNamespace getVariable ["WL2_hasRemoteBomb", createHashMap];
            private _hasRemoteBomb = _hasRemoteBombMap getOrDefault [_assetActualType, false];
            _hasRemoteBomb
        };
        if (count _controllableJets == 0) exitWith {
            systemChat "No remote munition standoff jets available.";
            playSound "AddItemFailed";
        };

        _controllableJets = _controllableJets select {
            _x getVariable ["DIS_remoteControlStation", objNull] == _asset
        };
        if (count _controllableJets == 0) exitWith {
            systemChat "This station is not linked to a remote munition standoff jet!";
            playSound "AddItemFailed";
        };

        private _controllableJet = _controllableJets # 0;
        [_controllableJet, _asset] spawn DIS_fnc_remoteMunition;
    },
	[],
	100,
	true,
	false,
	"",
	"([_target, _this, 'driver'] call WL2_fnc_accessControl) # 0",
	WL_MAINTENANCE_RADIUS,
	false
];
