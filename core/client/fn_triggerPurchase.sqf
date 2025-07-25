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

if (typeName _offset == "STRING") then {
    _offset = call compile _offset;
};
if (typeName _requirements == "STRING") then {
    _requirements = call compile _requirements;
};
switch (_className) do {
    case "BuildABear": {
        private _asset = (group player) createUnit [typeof player, getPosATL player, [], 2, "NONE"];
        _asset setVehiclePosition [getPosATL player, [], 0, "CAN_COLLIDE"];
        _asset setVariable ["BIS_WL_ownerAsset", getPlayerUID player, [2, clientOwner]];
        [player, "buildABear"] remoteExec ["WL2_fnc_handleClientRequest", 2];
        [_asset, player] spawn WL2_fnc_newAssetHandle;
        player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];

        [_asset] call WL2_fnc_factionBasedClientInit;
        [_asset, true] spawn WLC_fnc_onRespawn;

        [_asset] spawn {
            params ["_asset"];
            private _assetReady = false;
            waitUntil {
                sleep 1;
                _assetReady = _asset getVariable ["WL_spawnedAsset", false];
                _assetReady || !alive _asset;
            };
            _asset setSkill 1;
            _asset disableAI "SUPPRESSION";
            _asset disableAI "AIMINGERROR";
            _asset setUnitTrait ["engineer", true];
        };
    };
    case "Arsenal": {if (isNull (findDisplay 602)) then {"RequestMenu_close" call WL2_fnc_setupUI; [player, "orderArsenal"] remoteExec ["WL2_fnc_handleClientRequest", 2]} else {playSound "AddItemFailed"}};
    case "Customization": {
        "RequestMenu_close" call WL2_fnc_setupUI;
        0 spawn WLC_fnc_buildMenu;
        ["TaskCustomization"] call WLT_fnc_taskComplete;
    };
    case "BuyGlasses": {
        "RequestMenu_close" call WL2_fnc_setupUI;
        [player, "equip", 1000] remoteExec ["WL2_fnc_handleClientRequest", 2];
        player addGoggles "G_Tactical_Clear";
        player setVariable ["WL_hasGoggles", true, true];
    };
    case "Scan": { 0 spawn WL2_fnc_orderSectorScan };
    case "FTSeized": { 0 spawn WL2_fnc_orderFastTravel };
    case "FTConflict": { 1 spawn WL2_fnc_orderFastTravel };
    case "FTAirAssault": { 2 spawn WL2_fnc_orderFastTravel };
    case "FTParadropVehicle": { 3 spawn WL2_fnc_orderFastTravel };
    case "FTSquadLeader": {
        ["ftSquadLeader"] spawn SQD_fnc_client;
        // private _ftNextUseVar = format ["BIS_WL_FTSLNextUse_%1", getPlayerUID player];
        // missionNamespace setVariable [_ftNextUseVar, serverTime + WL_COOLDOWN_FTSL];
        ["TaskFastTravelSquad"] call WLT_fnc_taskComplete;
    };
    case "BuyStronghold": {
        0 spawn WL2_fnc_orderStronghold;
    };
    case "StrongholdFT": {
        5 spawn WL2_fnc_orderFastTravel;
    };
    case "BuyFOB": {
        switch (BIS_WL_playerSide) do {
            case west: {
                ["Land_Cargo10_blue_F", 500, "Fast Travel", [], [0, 3, 0]] call WL2_fnc_requestPurchase;
            };
            case east: {
                ["Land_Cargo10_red_F", 500, "Fast Travel", [], [0, 3, 0]] call WL2_fnc_requestPurchase;
            };
        };
    };
    case "FundsTransfer": {
        call WL2_fnc_orderFundsTransfer;
    };
    case "TargetReset": {
        "RequestMenu_close" call WL2_fnc_setupUI;
        missionNamespace setVariable ["WL_targetResetTime", serverTime];
        [player, "targetReset"] remoteExec ["WL2_fnc_handleClientRequest", 2]
    };
    case "LockVehicles": {
        private _ownedVehicles = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
        {
            _x setVariable ["WL2_accessControl", 6, true];
        } forEach (_ownedVehicles select { alive _x });
        [toUpper localize "STR_A3_WL_feature_lock_all_msg"] spawn WL2_fnc_smoothText;
    };
    case "UnlockVehicles": {
        private _ownedVehicles = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
        {
            _x setVariable ["WL2_accessControl", 1, true];
        } forEach (_ownedVehicles select { alive _x });
        [toUpper localize "STR_A3_WL_feature_unlock_all_msg"] spawn WL2_fnc_smoothText;
    };
    case "ClearVehicles": {
        private _playerAssets = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
        private _eligibleAssets = _playerAssets select {
            alive _x && ((getPosATL _x) # 2) < 10
        };
        {
            private _unwantedPassengers = (crew _x) select {
                _x != player &&
                getPlayerUID player != (_x getVariable ["BIS_WL_ownerAsset", "123"])
            };
            {
                moveOut _x;
            } forEach _unwantedPassengers;
        } forEach _eligibleAssets;
    };
    case "ResetVehicle": {
        "RequestMenu_close" call WL2_fnc_setupUI;
        0 spawn WL2_fnc_resetVehicle;
    };
    case "Camouflage": {
        "RequestMenu_close" call WL2_fnc_setupUI;
        private _loc = getPosASL player;
        _loc set [2, _loc # 2 + 4.3];
        [player, "camouflage"] remoteExec ["WL2_fnc_handleClientRequest", 2];

        private _camo = createSimpleObject ["a3\plants_f\Bush\b_ArundoD3s_F.p3d", _loc];
        _camo setVariable ["WL2_placedTime", serverTime, 2];
    };
    case "CruiseMissiles": {
        "RequestMenu_close" call WL2_fnc_setupUI;
        0 spawn WL2_fnc_orderCruiseMissile;
    };
    case "RemoveUnits": {
        {
            deleteVehicle _x;
        } forEach ((groupSelectedUnits player) select {_x != player && {_x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player}});
    };
    case "WipeMap": {
        {
            if ("_USER_DEFINED #" in _x) then {
                deleteMarkerLocal _x;
            };
        } forEach allMapMarkers;
    };
    case "ControlCollaborator": {
        private _potentialCollaboratorsInRange = allUnits select {
            side group _x == independent &&
            _x getVariable ["BIS_WL_ownerAsset", "123"] == "123" &&
            _x distance player < 4000 &&
            vehicle _x == _x &&
            _x distance WL_TARGET_FRIENDLY > 1000
        };

        if (count _potentialCollaboratorsInRange == 0) exitWith {
            playSoundUI ["AddItemFailed"];
            systemChat "No eligible collaborators in range!";
        };

        missionNamespace setVariable ["WL2_collaboratorCooldown", serverTime + 600];
        [player, "controlCollaborator"] remoteExec ["WL2_fnc_handleClientRequest", 2];

        private _selectedCollaborator = selectRandom _potentialCollaboratorsInRange;

        _selectedCollaborator setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
        _selectedCollaborator setVariable ["BIS_WL_ownerAssetSide", side group player, true];

        [_selectedCollaborator] call WL2_fnc_factionBasedClientInit;
        [_selectedCollaborator, true] spawn WLC_fnc_onRespawn;

        switchCamera _selectedCollaborator;
        player remoteControl _selectedCollaborator;

        uiNamespace setVariable ["WL2_canBuy", false];

        [_selectedCollaborator] spawn {
            params ["_collaborator"];
            private _startTime = serverTime;
            while {
                alive _collaborator && lifeState _collaborator != "INCAPACITATED" &&
                alive player && lifeState player != "INCAPACITATED"
            } do {
                sleep 1;
            };

            sleep 5;
            player remoteControl objNull;
            uiNamespace setVariable ["WL2_canBuy", true];
        };
    };
    case "AIGetIn": {
        private _vehicle = vehicle player;
        "RequestMenu_close" call WL2_fnc_setupUI;
        if (isNull _vehicle) exitWith {};

        {
            if (!(isPlayer _x) && alive _x && _x distance2D player < 150) then {
                _x moveInGunner _vehicle;
            };
        } forEach (units group player);
    };
    case "RespawnBagFT": {
        [4, ""] spawn WL2_fnc_executeFastTravel;
        "RequestMenu_close" call WL2_fnc_setupUI;
    };
    case "WelcomeScreen": {0 spawn WL2_fnc_welcome};
    case "StressTestSector": {
        0 spawn {
            private _direction = [vectorDir player, vectorUp player];

            private _assetData = WL_ASSET_DATA;
            private _classesArray = keys _assetData;

            private _sector = BIS_WL_allSectors select {
                player inArea (_x getVariable "objectAreaComplete")
            } select 0;

            for "_i" from 0 to 50 do {
                private _orderedClass = selectRandom _classesArray;
                private _pos = selectRandom ([_sector, 0, true] call WL2_fnc_findSpawnPositions);
                if (_orderedClass isKindOf "Man") then {
                    continue;
                };
                [player, "orderAsset", "vehicle", _pos, _orderedClass, _direction, false] remoteExec ["WL2_fnc_handleClientRequest", 2];
                [player, "10K"] remoteExec ["WL2_fnc_handleClientRequest", 2];
                sleep 0.1;
            };
        };
    };
    case "StressTestMap": {
        0 spawn {
            private _direction = [vectorDir player, vectorUp player];
            private _assetData = WL_ASSET_DATA;
            private _classesArray = keys _assetData;

            {
                private _sector = _x;
                for "_i" from 0 to 5 do {
                    private _orderedClass = selectRandom _classesArray;
                    private _pos = selectRandom ([_sector, 0, true] call WL2_fnc_findSpawnPositions);
                    if (_orderedClass isKindOf "Man") then {
                        continue;
                    };
                    [player, "orderAsset", "vehicle", _pos, _orderedClass, _direction, false] remoteExec ["WL2_fnc_handleClientRequest", 2];
                    [player, "10K"] remoteExec ["WL2_fnc_handleClientRequest", 2];
                    sleep 0.1;
                };
            } forEach BIS_WL_allSectors;
        };
    };
    case "SwitchToGreen": {
        private _greenUnits = allUnits select {
            (_x getVariable ["WL2_isPlayableGreen", false]) && !isPlayer _x;
        };
        if (count _greenUnits == 0) exitWith {};

        private _oldUnit = player;

        private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
        private _ownedVehicles = (missionNamespace getVariable [_ownedVehiclesVar, []]) select {
            !(isNull _x
        )};
        {
            if (unitIsUAV _x) then {
                private _group = group effectiveCommander _x;
                {
                    _x deleteVehicleCrew _x;
                } forEach crew _x;
                deleteGroup _group;
            };

            deleteVehicle _x;
        } forEach _ownedVehicles;
        missionNamespace setVariable [_ownedVehiclesVar, nil];

        private _playerUnits = allUnits select {
            _x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player;
        };
        {
	    	if !(isPlayer _x) then {
                deleteVehicle _x;
            };
    	} forEach _playerUnits;

        ["remove", [getPlayerID player]] remoteExec ["SQD_fnc_server", 2];

        private _newUnit = _greenUnits # 0;
        selectPlayer _newUnit;

        [_newUnit, _oldUnit] spawn {
            params ["_unit", "_oldUnit"];

            waitUntil {
                sleep 0.1;
                local _unit;
            };

            BIS_WL_playerSide = independent;
            player setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
            player setVariable ["BIS_WL_ownerAssetSide", independent, true];

            ["client", true] call WL2_fnc_updateSectorArrays;
            {
                [_x, _x getVariable "BIS_WL_owner", []] call WL2_fnc_sectorMarkerUpdate;
            } forEach BIS_WL_allSectors;

            createMarkerLocal ["respawn_guerrila", [independent] call WL2_fnc_getSideBase];
            call WL2_fnc_playerEventHandlers;

            independent call WL2_fnc_parsePurchaseList;

            forceRespawn player;
            forceRespawn _oldUnit;

            player allowDamage true;
        };
    };
    default {[_className, _cost, _category, _requirements, _offset] call WL2_fnc_requestPurchase};
};