#include "includes.inc"
params [
    "_className",
    "_requirements",
    "_displayName",
    "_picture",
    "_text",
    "_offset",
    "_cost",
    "_category"
];

private _checkConditions = {
    params ["_conditions"];

    private _results = _conditions apply {
        private _checker = _x # 0;
        if (count _x == 1) then {
            call _checker;
        } else {
            private _arguments = _x # 1;
            _arguments call _checker;
        };
    };

    private _failedResults = _results select { !(_x # 0) };

    private _failures = _failedResults apply { _x # 1 };

    _failures;
};

if (isNil "_className") exitWith {};

private _failures = [];

private _allConditions = [
    [WL2_fnc_checkFunds, _cost],
    [WL2_fnc_checkDead]
];
private _resultAllConditions = [_allConditions] call _checkConditions;
_failures append _resultAllConditions;

private _teamSectorsData = WL_SECTORS_DATA(BIS_WL_playerSide);
private _ownedSectors = _teamSectorsData getOrDefault ["owned", []];

private _findCurrentOwnedSector = _ownedSectors select {
    player inArea (_x getVariable "objectAreaComplete")
};

private _sector = if (count _findCurrentOwnedSector > 0) then {
    _findCurrentOwnedSector # 0;
} else {
    objNull;
};

private _conditions = switch (_className) do {
    case "FTSeized";
    case "FTPriority": {
        [
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkNearbyEnemies]
        ]
    };

    case "FTHome": {
        [
            [WL2_fnc_checkPlayerInVehicle]
        ]
    };

    case "FTAirAssault": {
        [
            [WL2_fnc_checkIndependents],
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkTargetAssault],
            [WL2_fnc_checkTargetSelected],
            [WL2_fnc_checkTargetUnlinked],
            [WL2_fnc_checkNearbyEnemies]
        ]
    };

    case "FTParadropVehicle": {
        [
            [WL2_fnc_checkIndependents],
            [WL2_fnc_checkInFriendlySector, [_cost, []]],
            [WL2_fnc_checkGroundVehicleDriver, [true]],
            [WL2_fnc_checkNearbyEnemies]
        ]
    };

    case "FTSquadLeader": {
        [
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkNearbyEnemies],
            [WL2_fnc_checkFastTravelSL]
        ]
    };

    case "FTSquad": {
        [
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkNearbyEnemies]
        ]
    };

    case "FundsTransfer": {
        [
            [WL2_fnc_checkAlliedPlayers]
        ]
    };

    case "TargetReset": {
        [
            [WL2_fnc_checkIndependents],
            [WL2_fnc_checkTargetSelected],
            [WL2_fnc_checkTargetReset]
        ]
    };

    case "Arsenal": {
        [
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkInFriendlySector, [_cost, []]],
            [WL2_fnc_checkNearbyEnemies]
        ]
    };

    case "RemoveUnits": {
        [
            [WL2_fnc_checkSelectedUnits]
        ]
    };

    case "Camouflage": {
        [
            [WL2_fnc_checkInFriendlySector, [_cost, []]],
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkNearbyEnemies]
        ]
    };

    case "CruiseMissiles": {
        [
            [WL2_fnc_checkCruiseMissileAvailable]
        ]
    };

    case "Conscription": {
        [
            [WL2_fnc_checkConscription]
        ]
    };

    case "SwitchToCollaborator": {
        [
            [WL2_fnc_checkCollaborator]
        ]
    };

    case "RespawnBagFT": {
        [
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkNearbyEnemies],
            [WL2_fnc_checkTent]
        ]
    };

    case "BuyStronghold": {
        [
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkNearbyEnemies],
            [WL2_fnc_checkNoStronghold]
        ]
    };

    case "StrongholdFT";
    case "StrongholdFTNear";
    case "BulkDeploy": {
        [
            [WL2_fnc_checkPlayerInVehicle],
            [WL2_fnc_checkNearbyEnemies]
        ]
    };

    case "ResetVehicle": {
        [
            [WL2_fnc_checkResetVehicle],
            [WL2_fnc_checkPlayerInVehicle]
        ]
    };

    case "SwitchToGreen": {
        [
            [WL2_fnc_checkIndependents],
            [WL2_fnc_checkGreenSwitch]
        ]
    };

    case "NearestCombatAir": {
        [
            [WL2_fnc_checkCombatAir]
        ]
    };

    case "CombatAirHome": {
        [
            [WL2_fnc_checkCombatAirHome]
        ]
    };

    case "HelpAA": {[]};

    default {
        if (_category in ["Fast Travel", "Strategy"]) then {
            []
        } else {
            private _assetConditions = [
                [WL2_fnc_checkRequirements, [_sector, _requirements]],
                [WL2_fnc_checkInfantryAvailable, [_className]],
                [WL2_fnc_checkAssetLimit, [_className]],
                [WL2_fnc_checkNearbyEnemies, [_category]],
                [WL2_fnc_checkPlayerInVehicle, [_requirements]],
                [WL2_fnc_checkInFriendlySector, [_cost, _requirements]],
                [WL2_fnc_checkIsOrdering],
                [WL2_fnc_checkUAVLimit, [_className]],
                [WL2_fnc_checkPlayerCountForAirSpawn, [_category, _cost]],
                [WL2_fnc_checkAAPlacement, [_category, _className]]
            ];

            _assetConditions;
        };
    };
};

private _result = [_conditions] call _checkConditions;
_failures append _result;

private _dlcInfo = [_className] call WL2_fnc_purchaseMenuGetDLCInfo;
_dlcInfo params ["_dlcOwned", "_dlcTooltip"];

[count _failures == 0, _failures, _dlcOwned, _dlcTooltip];
