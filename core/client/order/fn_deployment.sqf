params ["_class", "_orderedClass", "_offset", "_range", "_ignoreSector"];

private _asset = createVehicleLocal [_class, player modelToWorld [0, 0, 1000], [], 0, "NONE"];
_asset setPhysicsCollisionFlag false;
_asset enableSimulation false;

private _assetPos = player modelToWorld _offset;
_asset setPosASL [_assetPos # 0, _assetPos # 1, 500];
private _playerPos = ASLtoAGL eyePos player;
_assetPos set [2, _playerPos # 2];
_asset setVehiclePosition [_assetPos, [], 0, "CAN_COLLIDE"];
private _assetPosHeight = (getPosASL _asset) # 2;
_asset setPosASL [_assetPos # 0, _assetPos # 1, _assetPosHeight];
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

uiNamespace setVariable ["WL2_vehicleOrderAsset", _asset];
private _drawRestrictionId = addMissionEventHandler ["Draw3D", {
	private _asset = uiNamespace getVariable ["WL2_vehicleOrderAsset", objNull];
	if (!alive _asset) exitWith {};
	if (cameraOn distance _asset > 50) exitWith {};
	private _restriction = _asset getVariable ["WL2_vehicleOrderError", ""];
	if (_restriction == "") exitWith {};

	drawIcon3D [
        "\a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca.paa",
        [1, 0.2, 0.2, 1],
        _asset modelToWorld [0, 0, 0],
        1.0,
		1.0,
        0,
        _restriction,
        true,
        0.045,
        "TahomaB",
        "center",
        false,
		0,
		0.01
    ];
}];

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
            _asset animateSource ["HideTurret", 1, true];
            sleep 0.5;
            _asset animateSource ["HideTurret", 1, true];
        };
	};
} forEach _turretOverridesForVehicle;

[player, "assembly"] call WL2_fnc_hintHandle;

private _originalPosition = getPosATL player;

WL_DeploymentEnd = false;
[_asset, _offset, _originalPosition, _range, _ignoreSector] spawn {
    params ["_asset", "_offset", "_originalPosition", "_range", "_ignoreSector"];

    waitUntil {
        sleep 0.001;
        inputAction "BuldSelect" == 0 && inputAction "navigateMenu" == 0;
    };

    _offset set [2, 0.2];

    WL_DeploymentLock = false;
    WL_DeploymentSuccess = false;
    private _directionOffset = 0;
    private _lastTime = serverTime;

    while { !(isNull _asset) } do {
        if (WL_DeploymentLock) then {
            detach _asset;

            if (inputAction "prevAction" > 0) then {
                _asset setDir (direction _asset - 15);
            };
            if (inputAction "nextAction" > 0) then {
                _asset setDir (direction _asset + 15);
            };
        } else {
            if (inputAction "prevAction" > 0) then {
                _directionOffset = _directionOffset - 15;
            };
            if (inputAction "nextAction" > 0) then {
                _directionOffset = _directionOffset + 15;
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
                private _assetPos = _asset modelToWorld [0, 0, 0];
                _asset setPosASL [_assetPos # 0, _assetPos # 1, 500];
                private _playerPos = ASLtoAGL eyePos player;
                _assetPos set [2, _playerPos # 2];
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

        if (serverTime - _lastTime > 0.1) then {
            _lastTime = serverTime;
            private _cancel = [_originalPosition, _range, _ignoreSector, _asset] call WL2_fnc_cancelVehicleOrder;
            if (_cancel # 0) then {
                _asset setVariable ["WL2_vehicleOrderError", _cancel # 1];
            } else {
                _asset setVariable ["WL2_vehicleOrderError", ""];
            };
        };

        sleep 0.001;
    };

    WL_DeploymentEnd = true;
};

waitUntil {
    sleep 0.1;
    WL_DeploymentEnd;
};

if (!WL_DeploymentLock) then {
    _assetPos = _asset modelToWorld [0, 0, 0];
    _asset setPosASL [_assetPos # 0, _assetPos # 1, 500];
    _asset setVehiclePosition [_assetPos, [], 0, "CAN_COLLIDE"];
    private _assetPosHeight = (getPosASL _asset) # 2;
    _asset setPosASL [_assetPos # 0, _assetPos # 1, _assetPosHeight];
};

private _finalPosition = getPosWorldVisual _asset;
private _finalDirection = [vectorDir _asset, vectorUp _asset];

private _finalCancel = [_originalPosition, _range, _ignoreSector, _asset] call WL2_fnc_cancelVehicleOrder;
private _canStillOrderVehicle = !(_finalCancel # 0);

detach _asset;
deleteVehicle _asset;
removeMissionEventHandler ["Draw3D", _drawRestrictionId];

[player, "assembly", false] call WL2_fnc_hintHandle;

[WL_DeploymentSuccess && _canStillOrderVehicle, _finalPosition, _offset, _finalDirection];