params ["_class", "_orderedClass", "_offset", "_range", "_ignoreSector", ["_originalAsset", objNull]];

private _asset = createVehicleLocal [_class, AGLToASL (player modelToWorld _offset), [], 0, "NONE"];
_asset setPhysicsCollisionFlag false;
_asset enableSimulation false;

_asset setVectorDirAndUp [vectorDir player, vectorUp player];
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
		_asset animateSource ["HideTurret", 1, true];
	};
} forEach _turretOverridesForVehicle;

[player, "assembly"] call WL2_fnc_hintHandle;

BIS_WL_spacePressed = false;
BIS_WL_backspacePressed = false;

private _deployKeyHandle = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    if (_this # 1 == 57) then {
        if !(BIS_WL_backspacePressed) then {
            BIS_WL_spacePressed = true;
        };
    };
    if (_this # 1 == 14) then {
        if !(BIS_WL_spacePressed) then {
            BIS_WL_backspacePressed = true;
        };
    };
}];

uiNamespace setVariable ["BIS_WL_deployKeyHandle", _deployKeyHandle];
private _originalPosition = getPosATL player;

[_asset, _offset] spawn {
    params ["_asset", "_offset"];

    _offset set [2, 0.2];

    private _isInCarrierSector = count (BIS_WL_allSectors select {
        player inArea (_x getVariable "objectAreaComplete") && count (_x getVariable ["WL_aircraftCarrier", []]) > 0
    }) > 0;

    private _toggleLock = false;
    private _directionOffset = 0;

    private _assetPos = player modelToWorldWorld _offset;
    _asset setPosASL _assetPos;

    while { !(isNull _asset) && !(BIS_WL_spacePressed) && !(BIS_WL_backspacePressed) } do {
        detach _asset;

        if (_toggleLock) then {
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
            _toggleLock = !_toggleLock;
            if (_toggleLock) then {
                private _assetPos = _asset modelToWorld [0, 0, 0];
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

        if (!_toggleLock) then {
            _asset attachTo [player];
            _asset setDir _directionOffset;
            _asset attachTo [player]; // twice, yes
        };

        sleep 0.001;
    };
};

[_originalPosition, _range, _ignoreSector] spawn {
    params ["_originalPosition", "_range", "_ignoreSector"];

    waitUntil {
        sleep 0.1;
        BIS_WL_spacePressed ||
        BIS_WL_backspacePressed ||
        [_originalPosition, _range, _ignoreSector] call WL2_fnc_cancelVehicleOrder;
    };

    if !(BIS_WL_spacePressed) then {
        BIS_WL_backspacePressed = true;
    };
};

waitUntil {
    sleep 0.1;
    BIS_WL_spacePressed || BIS_WL_backspacePressed;
};

private _deployKeyHandle = uiNamespace getVariable ["BIS_WL_deployKeyHandle", nil];
if !(isNil "_deployKeyHandle") then {
    (findDisplay 46) displayRemoveEventHandler ["KeyDown", _deployKeyHandle];
};
uiNamespace setVariable ['BIS_WL_deployKeyHandle', nil];
detach _asset;
private _finalPosition = getPosATL _asset;
private _finalDirection = direction _asset;

deleteVehicle _asset;

[player, "assembly", false] call WL2_fnc_hintHandle;

private _canStillOrderVehicle = !([_originalPosition, _range, _ignoreSector] call WL2_fnc_cancelVehicleOrder);

[BIS_WL_spacePressed && _canStillOrderVehicle, _finalPosition, _offset, _finalDirection];