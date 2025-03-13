params ["_class", "_orderedClass", "_offset", "_range", "_ignoreSector", ["_originalAsset", objNull]];

private _asset = createVehicleLocal [_class, player modelToWorld _offset, [], 0, "NONE"];
_asset setPhysicsCollisionFlag false;
_asset enableSimulation false;

_asset setVectorDirAndUp [vectorDir player, vectorUp player];
_asset setVehiclePosition [player modelToWorld _offset, [], 0, "CAN_COLLIDE"];
private _newAssetPos = player modelToWorldWorld _offset;
private _assetPosHeight = (getPosWorld _asset) # 2;
_asset setPosWorld [_newAssetPos # 0, _newAssetPos # 1, _assetPosHeight];
_asset attachTo [player];

_asset allowDamage false;
_asset lock 2;
_asset lockInventory true;
_asset enableWeaponDisassembly false;
_asset setRepairCargo 0;
_asset setFuelCargo 0;
_asset setAmmoCargo 0;
_asset setVariable ["WL2_accessControl", 7];
_asset setVariable ["WLM_ammoCargo", 0];

private _appearanceDefaults = profileNamespace getVariable ["WLM_appearanceDefaults", createHashmap];
private _assetAppearanceDefaults = _appearanceDefaults getOrDefault [_orderedClass, createHashmap];

private _camo = _assetAppearanceDefaults getOrDefault ["camo", createHashmap];
if (count _camo == 0) then {
    private _textureHashmap = missionNamespace getVariable ["WL2_textures", createHashMap];
    private _assetTextures = _textureHashmap getOrDefault [_orderedClass, []];
    {
        _asset setObjectTextureGlobal [_forEachIndex, _x];
    } forEach _assetTextures;
};

{
    if (_x == "camo") then {
        [_asset, _y] call WLM_fnc_applyTexture;
    } else {
        private _skipped = ["smoke", "horn"];
        if !(_x in _skipped) then {
            [_asset, ["", "", 0, 0, [[_x, _y]], []]] call BIS_fnc_adjustSimpleObject;
        };
    };
} forEach _assetAppearanceDefaults;

private _turretOverrides = missionNamespace getVariable ["WL2_turretOverrides", createHashMap];
private _turretOverridesForVehicle = _turretOverrides getOrDefault [_orderedClass, []];
{
	private _turretOverride = _x;
	private _hideTurret = getNumber (_turretOverride >> "hideTurret");
	if (_hideTurret != 0) then {
		[_asset] spawn {
            params ["_asset"];
            sleep 0.5;
            _asset animateSource ["HideTurret", 1, true];
        };
	};
} forEach _turretOverridesForVehicle;

[player, "assembly"] call WL2_fnc_hintHandle;

private _originalPosition = getPosATL player;

[_asset, _offset, _range] spawn {
    params ["_asset", "_offset", "_range"];

    _offset set [2, 0.2];

    WL_DeploymentLock = false;
    WL_DeploymentEnd = false;
    WL_DeploymentSuccess = false;
    private _directionOffset = 0;

    while { !(isNull _asset) } do {
        private _distance = player distance _asset;
        if (_distance > _range) then {
            systemChat format ["Out of range: %1", _distance];
            detach _asset;
            deleteVehicle _asset;
            break;
        };

        if (WL_DeploymentLock) then {
            detach _asset;

            if (inputAction "prevAction" > 0) then {
                _asset setDir (direction _asset - 5);
            };
            if (inputAction "nextAction" > 0) then {
                _asset setDir (direction _asset + 5);
            };
        } else {
            if (inputAction "prevAction" > 0) then {
                _directionOffset = _directionOffset - 5;
            };
            if (inputAction "nextAction" > 0) then {
                _directionOffset = _directionOffset + 5;
            };
        };

        if (inputAction "lockTarget" > 0) then {
            waitUntil {
                sleep 0.001;
                inputAction "lockTarget" == 0;
            };
            detach _asset;
            WL_DeploymentLock = !WL_DeploymentLock;
            if (WL_DeploymentLock) then {
                _assetPos = _asset modelToWorld [0, 0, 0];
                _asset setPosASL [_assetPos # 0, _assetPos # 1, 500];
                _asset setVehiclePosition [_assetPos, [], 0, "CAN_COLLIDE"];
                private _assetPosHeight = (getPosASL _asset) # 2;
                _asset setPosASL [_assetPos # 0, _assetPos # 1, _assetPosHeight];
            } else {
                _directionOffset = (direction _asset) - (direction player);
                _asset attachTo [player];
                _offset = player getRelPos _asset;
            };
        };

        if (!WL_DeploymentLock) then {
            _asset setDir _directionOffset;
        };

        if (inputAction "BuldSelect" > 0) then {
            WL_DeploymentSuccess = true;
            break;
        };
        if (inputAction "navigateMenu" > 0) then {
            WL_DeploymentSuccess = false;
            break;
        };

        sleep 0.001;
    };

    WL_DeploymentEnd = true;
};

[_originalPosition, _range, _ignoreSector] spawn {
    params ["_originalPosition", "_range", "_ignoreSector"];

    waitUntil {
        sleep 0.1;
        [_originalPosition, _range, _ignoreSector] call WL2_fnc_cancelVehicleOrder;
    };

    WL_DeploymentEnd = true;
};

waitUntil {
    sleep 0.1;
    WL_DeploymentEnd;
};

if (!WL_DeploymentLock) then {
    private _assetPos = _asset modelToWorld [0, 0, 0];
    _asset setPosASL [_assetPos # 0, _assetPos # 1, 500];
    _asset setVehiclePosition [_assetPos, [], 0, "CAN_COLLIDE"];
    private _assetPosHeight = (getPosASL _asset) # 2;
    _asset setPosASL [_assetPos # 0, _assetPos # 1, _assetPosHeight];
};

private _finalPosition = getPosWorldVisual _asset;
private _finalDirection = [vectorDir _asset, vectorUp _asset];

detach _asset;
deleteVehicle _asset;

[player, "assembly", false] call WL2_fnc_hintHandle;

private _canStillOrderVehicle = !([_originalPosition, _range, _ignoreSector] call WL2_fnc_cancelVehicleOrder);

[WL_DeploymentSuccess && _canStillOrderVehicle, _finalPosition, _offset, _finalDirection];