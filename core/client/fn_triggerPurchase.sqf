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
        private _unitType = switch (BIS_WL_playerSide) do {
            case west: {"B_Soldier_TL_F"};
            case east: {"O_Soldier_TL_F"};
            case independent: {"I_Soldier_TL_F"};
            default {"B_Soldier_TL_F"};
        };

        private _asset = (group player) createUnit [_unitType, getPosATL player, [], 2, "NONE"];
        _asset setVehiclePosition [getPosATL player, [], 0, "CAN_COLLIDE"];
        _asset setVariable ["BIS_WL_ownerAsset", getPlayerUID player, [2, clientOwner]];
        [player, "buildABear"] remoteExec ["WL2_fnc_handleClientRequest", 2];
        [_asset, player] spawn WL2_fnc_newAssetHandle;
        player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];

        [_asset] call WL2_fnc_factionBasedClientInit;
        [_asset] spawn WLC_fnc_onRespawn;

        [_asset] spawn {
            params ["_asset"];
            private _assetReady = false;
            waitUntil {
                uiSleep 1;
                _assetReady = _asset getVariable ["WL_spawnedAsset", false];
                _assetReady || !alive _asset;
            };
            _asset setSkill 1;
            _asset disableAI "SUPPRESSION";
            _asset disableAI "AIMINGERROR";
            _asset setUnitTrait ["engineer", true];
        };
    };
    case "Arsenal": {
        [player, "orderArsenal"] remoteExec ["WL2_fnc_handleClientRequest", 2];
    };
    case "NearestCombatAir": {
        0 spawn WL2_fnc_nearestCombatAir;
    };
    case "CombatAirHome": {
        0 spawn WL2_fnc_combatAirHome;
    };
    case "Conscription": {
        "RequestMenu_close" call WL2_fnc_setupUI;
        playSoundUI ["AddItemOk"];
        [player] remoteExec ["WL2_fnc_conscription", BIS_WL_playerSide];
        [player, "conscript"] remoteExec ["WL2_fnc_handleClientRequest", 2];
    };
    case "FTHome": {
        private _homeBase = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
        [0, _homeBase] spawn WL2_fnc_executeFastTravel;
    };
    case "FTPriority": {
        0 spawn {
            private _travelResult = [true] call WL2_fnc_travelTeamPriority;
            if (_travelResult) then {
                playSoundUI ["AddItemOk"];
            } else {
                playSoundUI ["AddItemFailed"];
                [localize "STR_WL_conscriptFailed"] call WL2_fnc_smoothText;
            };
        };
    };
    case "FTAirAssault": {
        [2, WL_TARGET_FRIENDLY] spawn WL2_fnc_executeFastTravel;
    };
    case "BuyStronghold": {
        0 spawn WL2_fnc_orderStronghold;
    };
    case "FundsTransfer": {
        call WL2_fnc_orderFundsTransfer;
    };
    case "TargetReset": {
        "RequestMenu_close" call WL2_fnc_setupUI;
        missionNamespace setVariable ["WL_targetResetTime", serverTime];
        [player, "targetReset"] remoteExec ["WL2_fnc_handleClientRequest", 2];
    };
    case "LockVehicles": {
        private _ownedVehicles = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
        {
            _x setVariable ["WL2_accessControl", 6, true];
        } forEach (_ownedVehicles select { alive _x });
        [localize "STR_A3_WL_feature_lock_all_msg"] call WL2_fnc_smoothText;
    };
    case "UnlockVehicles": {
        private _ownedVehicles = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
        {
            _x setVariable ["WL2_accessControl", 1, true];
        } forEach (_ownedVehicles select { alive _x });
        [localize "STR_A3_WL_feature_unlock_all_msg"] call WL2_fnc_smoothText;
    };
    case "ClearVehicles": {
        private _playerAssets = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
        private _eligibleAssets = _playerAssets select { alive _x };
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
    case "PruneMines": {
        private _ownedMineVar = format ["WL2_ownedMines_%1", getPlayerUID player];
        private _allOwnedMines = missionNamespace getVariable [_ownedMineVar, []];
        {
            if (alive _x) then {
                deleteVehicle _x;
            };
        } forEach _allOwnedMines;
        missionNamespace setVariable [_ownedMineVar, [], true];

        private _ownedExplosiveVar = format ["WL2_ownedExplosives_%1", getPlayerUID player];
        private _allOwnedExplosives = missionNamespace getVariable [_ownedExplosiveVar, []];
        {
            if (alive _x) then {
                deleteVehicle _x;
            };
        } forEach _allOwnedExplosives;
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
    case "BulkRemove": {
        missionNamespace setVariable ["WL2_bulkRemoveActive", true];
        ["Bulk remove activated."] call WL2_fnc_smoothText;
        0 spawn {
            uiSleep 30;
            missionNamespace setVariable ["WL2_bulkRemoveActive", false];
            ["Bulk remove deactivated."] call WL2_fnc_smoothText;
        };
    };
    case "WipeMap": {
        {
            if ("_USER_DEFINED #" in _x) then {
                deleteMarkerLocal _x;
            };
        } forEach allMapMarkers;
    };
    case "SwitchToCollaborator": {
        private _sectorCollaboratorVar = format ["WL2_sectorCollaborator_%1", BIS_WL_enemySide];
        private _nextSectorCollaborator = missionNamespace getVariable [_sectorCollaboratorVar, ""];
        if (_nextSectorCollaborator != "") exitWith {
            ["Someone on your team has already applied to be collaborator for the next sector."] call WL2_fnc_smoothText;
        };

        missionNamespace setVariable [_sectorCollaboratorVar, getPlayerUID player, true];
        ["You have applied to be the next sector collaborator."] call WL2_fnc_smoothText;

        missionNamespace setVariable ["WL2_collaboratorCooldown", serverTime + 60];
        [player, "controlCollaborator"] remoteExec ["WL2_fnc_handleClientRequest", 2];
    };
    case "RespawnBagFT": {
        [4] spawn WL2_fnc_executeFastTravel;
        "RequestMenu_close" call WL2_fnc_setupUI;
    };
    case "WelcomeScreen": { 0 spawn WL2_fnc_welcome };
    case "Surrender": {
        0 spawn {
            private _message = "Are you sure you want to surrender? You will ruin the game for people who still want to play :(<br/>Votes needed: 1";
            private _result = ["Surrender", _message, "OK", "Cancel"] call WL2_fnc_prompt;
            if (_result) then {
                [player, "surrender"] remoteExec ["WL2_fnc_handleClientRequest", 2];
                [BIS_WL_enemySide, true, true] spawn WL2_fnc_missionEndHandle;
            } else {
                playSoundUI ["AddItemFailed"];
            };
        };
    };
    case "HelpAA": {
        openMap true;
        player selectDiarySubject "Warlords Redux:Record2";
    };
    case "SeeChangelog": {
        openMap true;
        player selectDiarySubject "Warlords Redux:Record1";
    };
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
                private _pos = selectRandom ([_sector] call WL2_fnc_findSpawnsInSector);
                if (_orderedClass isKindOf "Man") then {
                    continue;
                };
                [player, "orderAsset", "vehicle", _pos, _orderedClass, _direction, false, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
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
                    private _pos = selectRandom ([_sector] call WL2_fnc_findSpawnsInSector);
                    if (_orderedClass isKindOf "Man") then {
                        continue;
                    };
                    [player, "orderAsset", "vehicle", _pos, _orderedClass, _direction, false, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
                };
            } forEach BIS_WL_allSectors;
        };
    };
    case "StressTestSpawns": {
        0 spawn {
            private _spawns = [];
            {
                private _sectorName = _x getVariable ["WL2_name", "Unknown"];
                (format ["Finding spawns in sector: %1", _sectorName]) call WL2_fnc_smoothText;
                private _spawnsForSector = [_x] call WL2_fnc_findSpawnsInSector;
                _spawns append _spawnsForSector;
            } forEach BIS_WL_allSectors;

            (format ["Found %1 spawns on map. Painting sector spawns. This can take a while...", count _spawns]) call WL2_fnc_smoothText;

            private _markers = [];
            {
                private _marker = createMarkerLocal [format ["WL2_testSpawnMarker_%1", _forEachIndex], _x];
                _marker setMarkerShapeLocal "ICON";
                _marker setMarkerTypeLocal "mil_dot";
                _marker setMarkerColorLocal "ColorRed";
                _marker setMarkerShadowLocal false;
                _markers pushBack _marker;
            } forEach _spawns;

            (format ["%1 markers painted.", count _markers]) call WL2_fnc_smoothText;

            openMap true;
        };
    };
    case "StressTestKillfeed": {
        0 spawn {
            private _testSupports = [
                ["ATTACKING SECTOR", WL_COLOR_SUPPORT],
                ["DEFENDING SECTOR", WL_COLOR_SUPPORT],
                ["ACTIVE PROTECTION SYSTEM", WL_COLOR_KILL],
                ["PROJECTILE JAMMED", WL_COLOR_KILL],
                ["PROJECTILE DESTROYED", WL_COLOR_KILL],
                ["REGION CAPTURED", WL_COLOR_SUPPORT],
                ["REVIVED TEAMMATE", WL_COLOR_SUPPORT],
                ["RECON", WL_COLOR_SUPPORT],
                ["SPOT ASSIST", WL_COLOR_SUPPORT],
                ["TRANSPORT", WL_COLOR_SUPPORT],
                ["SQUAD ASSIST", WL_COLOR_SUPPORT]
            ];
            for "_i" from 1 to 20 do {
                private _testSupport = selectRandom _testSupports;
                private _reward = floor (random 100);
                [objNull, _reward, _testSupport # 0, _testSupport # 1] call WL2_fnc_killRewardClient;
                uiSleep (random 1);
            };

            {
                private _asset = _x;
                private _assetData = _y;
                // _asset = _assetData getOrDefault ["spawn", _asset];
                private _reward = floor (random 400);
                [objNull, _reward, "", WL_COLOR_KILL, _asset] call WL2_fnc_killRewardClient;
                uiSleep (random 1);
            } forEach WL_ASSET_DATA;
        };
    };
    case "TestRebalance": {
        [player, getPlayerUID player] remoteExec ["WL2_fnc_rebalance", 2];
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
                uiSleep 0.1;
                local _unit;
            };

            BIS_WL_playerSide = independent;
            player setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
            player setVariable ["BIS_WL_ownerAssetSide", independent, true];

            call WL2_fnc_updateSectorsData;
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