#include "includes.inc"
params ["_asset", "_targetId"];
private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];

private _assetName = if (isPlayer _asset) then {
    name _asset;
} else {
    private _isStronghold = !isNull (_asset getVariable ["WL_strongholdSector", objNull]);
    if (_isStronghold) then {
        "Stronghold";
    } else {
        [_asset] call WL2_fnc_getAssetTypeName;
    };
};
_asset setVariable ["WL2_mapButtonText", _assetName];

private _ownsVehicle = (_asset getVariable ["BIS_WL_ownerAsset", "123"]) == getPlayerUID player;
if (!isPlayer _asset && _ownsVehicle) then {
    [_asset, _targetId, "remove", "<span class='red'>Remove</span>", {
        params ["_asset"];
        if ((_asset getVariable ["BIS_WL_ownerAsset", "123"]) == getPlayerUID player) then {
            _asset spawn WL2_fnc_deleteAssetFromMap;
        } else {
            playSoundUI ["AddItemFailed"];
            ["You do not own this asset."] call WL2_fnc_smoothText;
        };
    }, true] call WL2_fnc_addTargetMapButton;
};

if (side group player == independent && _asset isKindOf "Man" && !isPlayer _asset) then {
    [_asset, _targetId, "control", "Control", {
        params ["_asset"];

        private _assetIsNotMine = (_asset getVariable ["BIS_WL_ownerAsset", "123"]) != getPlayerUID player;
        private _noMoreClaims = BIS_WL_matesAvailable <= 0;
        if (!alive _asset || (_assetIsNotMine && _noMoreClaims)) then {
            playSoundUI ["AddItemFailed"];
            ["No available slots for this unit, or the unit is dead."] call WL2_fnc_smoothText;
        } else {
            private _maxSubordinates = missionNamespace getVariable [format ["BIS_WL_maxSubordinates_%1", BIS_WL_playerSide], 1];
            private _refreshTimerVar = format ["WL2_manpowerRefreshTimers_%1", getPlayerUID player];
            private _manpowerRefreshTimers = missionNamespace getVariable [_refreshTimerVar, []];
            private _assetIndex = _manpowerRefreshTimers findIf {
                _x # 1 == _asset
            };

            // spawned unit
            if (_assetIndex != -1) then {
                _manpowerRefreshTimers set [_assetIndex, [_manpowerRefreshTimers # _assetIndex # 0, player]];
            } else {
                _asset setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
                _manpowerRefreshTimers pushBack [serverTime + WL_COOLDOWN_AIREFRESH, _asset];
            };
            missionNamespace setVariable [_refreshTimerVar, _manpowerRefreshTimers, true];
            call WL2_fnc_teammatesAvailability;

            private _playerGroup = group player;
            [_asset] joinSilent _playerGroup;

            selectPlayer _asset;
            _playerGroup selectLeader player;

            playSoundUI ["AddItemOK"];
        };
    }, true] call WL2_fnc_addTargetMapButton;
};

private _accessControl = _asset getVariable ["WL2_accessControl", -1];
if (_ownsVehicle && _accessControl != -1 && !(_asset isKindOf "Man")) then {
    private _lockText = [_accessControl] call WL2_fnc_assetButtonAccessControl;

    private _accessControlNext = {
        params ["_asset"];
        private _accessControl = _asset getVariable ["WL2_accessControl", 0];
        private _newAccess = (_accessControl - 1 + 8) % 8;
        _asset setVariable ["WL2_accessControl", _newAccess, true];
        playSound3D ["a3\sounds_f\sfx\objects\upload_terminal\terminal_lock_close.wss", _asset, false, getPosASL _asset, 1, 1, 0, 0];

        // return
        [_newAccess] call WL2_fnc_assetButtonAccessControl;
    };
    private _accessControlPrevious = {
        params ["_asset"];
        private _accessControl = _asset getVariable ["WL2_accessControl", 0];
        private _newAccess = (_accessControl + 1) % 8;
        _asset setVariable ["WL2_accessControl", _newAccess, true];
        playSound3D ["a3\sounds_f\sfx\objects\upload_terminal\terminal_lock_close.wss", _asset, false, getPosASL _asset, 1, 1, 0, 0];

        // return
        [_newAccess] call WL2_fnc_assetButtonAccessControl;
    };

    [_asset, _targetId, "lock-access-control", _lockText, [_accessControlNext, _accessControlPrevious], false] call WL2_fnc_addTargetMapButton;
};

private _hasCrew = count ((crew _asset) select {
    !(typeof _x in ["B_UAV_AI", "O_UAV_AI", "I_UAV_AI"]) && getPlayerUID player != (_x getVariable ["BIS_WL_ownerAsset", "123"])
}) > 0;
private _isNotFlying = (getPosATL _asset # 2) < 10;
if (_hasCrew && _isNotFlying && !(_asset isKindOf "Man") && _ownsVehicle) then {
    [_asset, _targetId, "kick", "Kick", {
        params ["_asset"];
        if ((getPosATL _asset # 2) < 10) then {
            private _unwantedPassengers = (crew _asset) select {
                (_x != player) && getPlayerUID player != (_x getVariable ["BIS_WL_ownerAsset", "123"])
            };
            {
                moveOut _x;
            } forEach _unwantedPassengers;
        };
    }, true] call WL2_fnc_addTargetMapButton;
};

private _operateAccess = ([_asset, player, "driver"] call WL2_fnc_accessControl) # 0;

if (_operateAccess && typeof _asset in ["O_T_Truck_03_device_ghex_F", "O_Truck_03_device_F", "Land_MobileRadar_01_radar_F"]) then {
    private _jammerText = [_asset] call WL2_fnc_assetButtonJammer;

    [_asset, _targetId, "ew", _jammerText, {
        params ["_asset"];
        [_asset] call WL2_fnc_jammerToggle;
    }, true] call WL2_fnc_addTargetMapButton;
};

if (_operateAccess && typeof _asset in ["B_Radar_System_01_F", "O_Radar_System_01_F", "I_E_Radar_System_01_F"]) then {
    private _radarRotateText = [_asset] call WL2_fnc_assetButtonRadarRotate;

    [_asset, _targetId, "radar-rotate", _radarRotateText, {
        params ["_asset"];
        _asset setVariable ["radarRotation", !(_asset getVariable ["radarRotation", false]), true];
        playSoundUI ["AddItemOK"];

        // return
        [_asset] call WL2_fnc_assetButtonRadarRotate;
    }, false] call WL2_fnc_addTargetMapButton;
};

if (_operateAccess && WL_ASSET(_assetActualType, "smartMine", 0) > 0) then {
    private _smartMineNext = {
        params ["_asset"];
        private _smartMineDistance = _asset getVariable ["WL2_smartMineDistance", 0];
        private _newSmartMineDistance = (_smartMineDistance - 1 + 6) % 6;
        _asset setVariable ["WL2_smartMineDistance", _newSmartMineDistance, true];
        playSoundUI ["a3\ui_f\data\sound\rscbutton\soundclick.wss"];

        private _distanceText = WL_SMART_MINE_DISTANCES # _newSmartMineDistance;
        private _distanceColor = if (_distanceText == 0) then { "red" } else { "green" };
        format ["<span class='%1'>Trigger distance: %2 m</span>", _distanceColor, _distanceText];
    };
    private _smartMinePrevious = {
        params ["_asset"];
        private _smartMineDistance = _asset getVariable ["WL2_smartMineDistance", 0];
        private _newSmartMineDistance = (_smartMineDistance + 1) % 6;
        _asset setVariable ["WL2_smartMineDistance", _newSmartMineDistance, true];
        playSoundUI ["a3\ui_f\data\sound\rscbutton\soundclick.wss"];

        private _distanceText = WL_SMART_MINE_DISTANCES # _newSmartMineDistance;
        private _distanceColor = if (_distanceText == 0) then { "red" } else { "green" };
        format ["<span class='%1'>Trigger distance: %2 m</span>", _distanceColor, _distanceText];
    };

    private _detonationDistance = WL_SMART_MINE_DISTANCES # (_asset getVariable ["WL2_smartMineDistance", 0]);
    private _detonationDistanceColor = if (_detonationDistance == 0) then { "red" } else { "green" };
    private _smartDistanceText = format ["<span class='%1'>Trigger distance: %2m</span>", _detonationDistanceColor, _detonationDistance];

    [_asset, _targetId, "smart-mine-adjust", _smartDistanceText, [_smartMineNext, _smartMinePrevious], false] call WL2_fnc_addTargetMapButton;

    private _smartMineTypeChange = {
        params ["_asset"];
        private _smartMineType = _asset getVariable ["WL2_smartMineType", 0];
        private _newSmartMineType = (_smartMineType + 1) % 3;
        _asset setVariable ["WL2_smartMineType", _newSmartMineType, true];
        playSoundUI ["a3\ui_f\data\sound\rscbutton\soundclick.wss"];

        private _smartMineTypeText = switch (_newSmartMineType) do {
            case 0: { "Trigger type: All" };
            case 1: { "Trigger type: Anti-tank" };
            case 2: { "Trigger type: Anti-personnel" };
            default { "Trigger type: All" };
        };
        format ["<span class='green'>%1</span>", _smartMineTypeText];
    };

    private _smartMineType = _asset getVariable ["WL2_smartMineType", 0];
    private _smartMineTypeText = switch (_smartMineType) do {
        case 0: { "Trigger type: All" };
        case 1: { "Trigger type: Anti-tank" };
        case 2: { "Trigger type: Anti-personnel" };
        default { "Trigger type: All" };
    };
    _smartMineTypeText = format ["<span class='green'>%1</span>", _smartMineTypeText];
    [_asset, _targetId, "smart-mine-type", _smartMineTypeText, _smartMineTypeChange, false] call WL2_fnc_addTargetMapButton;
};

private _crewPosition = (fullCrew [_asset, "", true]) select {!("cargo" in _x)};
private _radarSensor = (listVehicleSensors _asset) select {{"ActiveRadarSensorComponent" in _x} forEach _x};
private _hasRadar = count _radarSensor > 0 && (count _crewPosition > 1 || unitIsUAV _asset);
if (_operateAccess && _hasRadar) then {
    private _radarOperateText = [_asset] call WL2_fnc_assetButtonRadarOperate;

    [_asset, _targetId, "radar-operate", _radarOperateText, {
        params ["_asset"];
        _asset setVariable ["radarOperation", !(_asset getVariable ["radarOperation", false]), true];
        playSoundUI ["AddItemOK"];

        // return
        [_asset] call WL2_fnc_assetButtonRadarOperate;
    }, false] call WL2_fnc_addTargetMapButton;
};

private _isTent = typeof _asset in ["Land_TentSolar_01_bluewhite_F", "Land_TentDome_F", "Land_TentSolar_01_redwhite_F", "Land_TentA_F"];
if (_ownsVehicle && _isTent) then {
    [_asset, _targetId, "ft-tent", "Fast travel tent", {
        if (!alive player || lifeState player == "INCAPACITATED") exitWith {
            ["Cannot fast travel."] call WL2_fnc_smoothText;
            playSoundUI ["AddItemFailed"];
        };
        [4, ""] spawn WL2_fnc_executeFastTravel;
    }, true, "", [0, "RespawnBagFT", "Fast Travel"]] call WL2_fnc_addTargetMapButton;
};

private _canFastTravel = WL_ASSET(_assetActualType, "hasFastTravel", 0) > 0;
if (_canFastTravel) then {
    [_asset, _targetId, "ft-asset", "Fast travel", {
        params ["_asset"];
        if (!alive player || lifeState player == "INCAPACITATED") exitWith {
            ["Cannot fast travel while dead."] call WL2_fnc_smoothText;
            playSoundUI ["AddItemFailed"];
        };
        if (isWeaponDeployed player) exitWith {
            ["Cannot fast travel while weapon is deployed."] call WL2_fnc_smoothText;
            playSoundUI ["AddItemFailed"];
        };
        [_asset] spawn WL2_fnc_executeFastTravelVehicle;
    }, true, "", [0, "FTSeized", "Fast Travel"]] call WL2_fnc_addTargetMapButton;
};

if (typeof _asset == "RuggedTerminal_01_communications_hub_F") then {
    private _fastTravelFOBExecute = {
        params ["_asset"];
        BIS_WL_targetSector = nil;

        private _marker = createMarkerLocal ["WL2_fastTravelFOBMarker", getPosATL _asset];
        _marker setMarkerShapeLocal "ELLIPSE";
        _marker setMarkerSizeLocal [WL_FOB_RANGE, WL_FOB_RANGE];
        _marker setMarkerAlphaLocal 0;

        [6, "WL2_fastTravelFOBMarker"] spawn WL2_fnc_executeFastTravel;
    };
    [
        _asset, _targetId,
        "ft-fob",
        "Fast travel forward base",
        _fastTravelFOBExecute,
        true,
        "fastTravelFOB",
        [
            0,
            "FTSeized",
            "Fast Travel"
        ]
    ] call WL2_fnc_addTargetMapButton;

    // Vehicle Paradrop Button
    private _vehicleParadropFOBExecute = {
        params ["_asset"];
        private _marker = createMarkerLocal ["WL2_fastTravelFOBMarker", getPosATL _asset];
        _marker setMarkerShapeLocal "ELLIPSE";
        _marker setMarkerSizeLocal [500, 500];
        _marker setMarkerAlphaLocal 0;
        [7, "WL2_fastTravelFOBMarker"] spawn WL2_fnc_executeFastTravel;
    };
    [
        _asset, _targetId,
        "vehicle-paradrop",
        "Vehicle paradrop",
        _vehicleParadropFOBExecute,
        true,
        "vehicleParadropFOB",
        [
            WL_COST_PARADROP,
            "FTParadropVehicle",
            "Fast Travel"
        ]
    ] call WL2_fnc_addTargetMapButton;

    // Lock FOB Button
    private _isLocked = _asset getVariable ["WL2_forwardBaseLocked", false];
    private _lockText = if (_isLocked) then {
        "<span class='red'>Forward base: Locked</span>";
    } else {
        "<span class='green'>Forward base: Unlocked</span>";
    };
    private _lockFOBExecute = {
        params ["_asset"];
        private _isLocked = _asset getVariable ["WL2_forwardBaseLocked", false];
        _isLocked = !_isLocked;
        _asset setVariable ["WL2_forwardBaseLocked", _isLocked, true];
        if (_isLocked) then {
            "<span class='red'>Forward base: Locked</span>";
        } else {
            "<span class='green'>Forward base: Unlocked</span>";
        };
    };
    [
        _asset, _targetId,
        "lock-fob",
        _lockText,
        _lockFOBExecute,
        false,
        "lockFOB"
    ] call WL2_fnc_addTargetMapButton;

    // Delete FOB Button
    private _deleteFOBExecute = {
        params ["_asset"];
        private _result = ["Delete FOB", "Are you sure you would like to delete your FOB?", "Yes", "Cancel"] call WL2_fnc_prompt;
        if (!_result) exitWith {
            playSoundUI ["AddItemFailed"];
        };
        deleteVehicle _asset;
    };
    [
        _asset, _targetId,
        "remove-fob",
        "<span class='red'>Remove forward base</span>",
        _deleteFOBExecute,
        true,
        "deleteFOB"
    ] call WL2_fnc_addTargetMapButton;

    private _repairFOBExecute = {
        params ["_asset"];
        private _repairCost = WL_FOB_REPAIR_COST;
        private _supplyFinal = (_asset getVariable ["WL2_forwardBaseSupplies", -1]) - _repairCost;
        _asset setVariable ["WL2_forwardBaseSupplies", _supplyFinal, true];

        private _maxHealth = _asset getVariable ["WL2_demolitionMaxHealth", 12];
        _asset setVariable ["WL2_demolitionHealth", _maxHealth, true];
        playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Repair.wss", _asset, false, getPosASL _asset, 2, 1, 75];

        [player, "repairFOB"] remoteExec ["WL2_fnc_handleClientRequest", 2];
    };
    [
        _asset, _targetId,
        "repair-fob",
        "Repair forward base",
        _repairFOBExecute,
        true,
        "repairFOB",
        [
            500,
            "RepairFOB",
            "Strategy"
        ]
    ] call WL2_fnc_addTargetMapButton;

#if WL_STRONGHOLD_DEBUG
    // Fast Travel FOB Test
    private _fastTravelFOBTestExecute = {
        params ["_asset"];
        ["Testing Sector Stronghold spawns. Force respawn to end test."] call WL2_fnc_smoothText;
        while { alive player } do {
            private _marker = createMarkerLocal ["WL2_fastTravelFOBMarker", getPosATL _asset];
            _marker setMarkerShapeLocal "ELLIPSE";
            _marker setMarkerSizeLocal [WL_FOB_RANGE, WL_FOB_RANGE];
            _marker setMarkerAlphaLocal 0;

            [6, "WL2_fastTravelFOBMarker"] spawn WL2_fnc_executeFastTravel;
            uiSleep 3;
        };
    };
    [
        _asset, _targetId,
        "ft-fob-test",
        "Forward base test fast travel",
        _fastTravelFOBTestExecute,
        true,
        "fastTravelFOB",
        [
            0,
            "FTSeized",
            "Fast Travel"
        ]
    ] call WL2_fnc_addTargetMapButton;
#endif
};

private _isUav = [_asset] call WL2_fnc_isDrone;
if (_operateAccess && _isUav) then {
    if (alive driver _asset) then {
        [_asset, _targetId, "control-driver", "Control driver", {
            params ["_asset"];
            private _access = [_asset, player, "driver"] call WL2_fnc_accessControl;
            if (_access # 0) then {
                openMap false;
                switchCamera _asset;
                player remoteControl (driver _asset);

                private _eligibleDrones = missionNamespace getVariable ["WL2_eligibleDrones", []];
                _eligibleDrones pushBackUnique _asset;
                missionNamespace setVariable ["WL2_eligibleDrones", _eligibleDrones];
                _asset setVariable ["WL2_lastSeatUsed", "Driver"];
            };
        }, true] call WL2_fnc_addTargetMapButton;
    };
    if (alive gunner _asset) then {
        [_asset, _targetId, "control-gunner", "Control gunner", {
            params ["_asset"];
            private _access = [_asset, player, "driver"] call WL2_fnc_accessControl;
            if (_access # 0) then {
                openMap false;
                switchCamera _asset;
                player remoteControl (gunner _asset);

                private _eligibleDrones = missionNamespace getVariable ["WL2_eligibleDrones", []];
                _eligibleDrones pushBackUnique _asset;
                missionNamespace setVariable ["WL2_eligibleDrones", _eligibleDrones];
                _asset setVariable ["WL2_lastSeatUsed", "Gunner"];
            };
        }, true] call WL2_fnc_addTargetMapButton;
    };
};

// Fast Travel SL Button
private _fastTravelSLExecute = {
    params ["_asset"];
    ["ftSquadLeader"] spawn SQD_fnc_client;
};
[
    _asset, _targetId,
    "ft-squad-leader",
    "Fast travel squad leader",
    _fastTravelSLExecute,
    true,
    "fastTravelSL",
    [
        WL_COST_FTSL,
        "FTSquadLeader",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Squad Button
private _fastTravelSquadmateExecute = {
    params ["_asset"];
    private _playerId = getPlayerID _asset;
    ["ftSquad", [_playerId]] spawn SQD_fnc_client;
};
[
    _asset, _targetId,
    "ft-squad",
    "Fast travel squad member",
    _fastTravelSquadmateExecute,
    true,
    "fastTravelSquad",
    [
        0,
        "FTSquad",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel AI Button
private _fastTravelAIExecute = {
    params ["_asset"];
    [_asset] spawn WL2_fnc_executeFastTravelVehicle;
};
[
    _asset, _targetId,
    "ft-ai",
    "Fast travel AI",
    _fastTravelAIExecute,
    true,
    "fastTravelAI",
    [
        0,
        "FTAI",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Stronghold Button
private _fastTravelStrongholdExecute = {
    params ["_asset"];
    private _findSector = (BIS_WL_sectorsArray # 2) select {
        (_x getVariable ["WL_stronghold", objNull]) == _asset
    };
    if (count _findSector == 0) exitWith {};

    BIS_WL_targetSector = (_findSector # 0);
    [5, ""] spawn WL2_fnc_executeFastTravel;
};
[
    _asset, _targetId,
    "ft-stronghold",
    "Fast travel stronghold",
    _fastTravelStrongholdExecute,
    true,
    "fastTravelStronghold",
    [
        0,
        "StrongholdFT",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Near Stronghold Button
private _fastTravelNearStrongholdExecute = {
    params ["_asset"];
    private _findSector = (BIS_WL_sectorsArray # 2) select {
        (_x getVariable ["WL_stronghold", objNull]) == _asset
    };
    if (count _findSector == 0) exitWith {};

    BIS_WL_targetSector = (_findSector # 0);
    [8, ""] spawn WL2_fnc_executeFastTravel;
};
[
    _asset, _targetId,
    "ft-stronghold-near",
    "Fast travel near stronghold",
    _fastTravelNearStrongholdExecute,
    true,
    "fastTravelNearStronghold",
    [
        0,
        "StrongholdFTNear",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Remove Stronghold button
private _removeStrongholdExecute = {
    params ["_asset"];
    private _findSector = (BIS_WL_sectorsArray # 2) select {
        (_x getVariable ["WL_stronghold", objNull]) == _asset
    };
    if (count _findSector == 0) exitWith {};
    private _sector = (_findSector # 0);

    private _sectorName = _sector getVariable ["WL2_name", ""];
    private _message = format ["Are you sure you want to pay to remove the Sector Stronghold in %1?", _sectorName];
    private _result = [_message, "Remove Sector Stronghold", "Remove", "Cancel"] call BIS_fnc_guiMessage;
    if (!_result) exitWith {
        playSoundUI ["AddItemFailed"];
    };

    [_sector] call WL2_fnc_removeStronghold;
    [player, "buyStronghold"] remoteExec ["WL2_fnc_handleClientRequest", 2];
};
[
    _asset, _targetId,
    "remove-stronghold",
    "<span class='red'>Remove stronghold</span>",
    _removeStrongholdExecute,
    true,
    "removeStronghold",
    [
        WL_COST_STRONGHOLD,
        "RemoveStronghold",
        "Strategy"
    ]
] call WL2_fnc_addTargetMapButton;

private _repairStrongholdExecute = {
    params ["_asset"];
    private _maxHealth = _asset getVariable ["WL2_demolitionMaxHealth", 8];
    _asset setVariable ["WL2_demolitionHealth", _maxHealth, true];
    playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Repair.wss", _asset, false, getPosASL _asset, 2, 1, 75];

    [player, "repairStronghold"] remoteExec ["WL2_fnc_handleClientRequest", 2];
};
[
    _asset, _targetId,
    "repair-stronghold",
    "Repair stronghold",
    _repairStrongholdExecute,
    true,
    "repairStronghold",
    [
        WL_COST_STRONGHOLD / 2,
        "RepairStronghold",
        "Strategy"
    ]
] call WL2_fnc_addTargetMapButton;

// Fortify Stronghold button
private _fortifyStrongholdExecute = {
    params ["_asset"];
    private _findSector = (BIS_WL_sectorsArray # 2) select {
        (_x getVariable ["WL_stronghold", objNull]) == _asset
    };
    private _sector = (_findSector # 0);
    private _fortificationTime = _sector getVariable ["WL_fortificationTime", -1];
    if (_fortificationTime < serverTime) exitWith {};
    private _fortificationTimeRemaining = _fortificationTime - serverTime;
    _sector setVariable ["WL_fortificationTime", serverTime + _fortificationTimeRemaining / 5, true];

#if WL_QUICK_CAPTURE
    _sector setVariable ["WL_fortificationTime", serverTime + 10, true];
#endif

    _sector setVariable ["WL_strongholdFortified", true, true];

    private _impactSounds = [
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_01.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_02.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_03.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_04.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_01.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_02.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_03.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_01.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_02.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_03.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_04.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_01.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_02.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_03.wss",
        "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_04.wss"
    ];

    for "_i" from 1 to 10 do {
        playSound3D [selectRandom _impactSounds, player, false, getPosASL player, 2, 1, 200, 0];
        uiSleep 0.3;
    };

    [player, "fortifyStronghold"] remoteExec ["WL2_fnc_handleClientRequest", 2];
};
[
    _asset, _targetId,
    "fortify-stronghold",
    "Fortify stronghold",
    _fortifyStrongholdExecute,
    true,
    "fortifyStronghold",
    [
        WL_COST_FORTIFY,
        "FortifyStronghold",
        "Strategy"
    ]
] call WL2_fnc_addTargetMapButton;

#if WL_STRONGHOLD_DEBUG
// Fast Travel Stronghold Test
private _fastTravelStrongholdTestExecute = {
    params ["_asset"];
    private _findSector = (BIS_WL_sectorsArray # 2) select {
        (_x getVariable ["WL_stronghold", objNull]) == _asset
    };
    BIS_WL_targetSector = (_findSector # 0);
    ["Testing Sector Stronghold spawns. Force respawn to end test."] call WL2_fnc_smoothText;
    while { alive player } do {
        [5, ""] spawn WL2_fnc_executeFastTravel;
        uiSleep 3;
    };
};
[
    _asset, _targetId,
    "ft-stronghold-test",
    "Stronghold test fast travel",
    _fastTravelStrongholdTestExecute,
    true,
    "fastTravelStronghold",
    [
        0,
        "StrongholdFT",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;
#endif