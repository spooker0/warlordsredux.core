#include "includes.inc"
params ["_asset"];
if (isDedicated) exitWith {};

private _deployActionId = _asset addAction [
	"",
	{
		_this params ["_asset", "_caller", "_deployActionId"];
        private _assetLoadedItem = _asset getVariable ["WL2_loadedItem", objNull];

        if (!isNull _assetLoadedItem && _asset isKindOf "Air" && (_asset modelToWorld [0, 0, 0]) # 2 > 50) exitWith {
            playSoundUI ["assemble_target"];
            [_asset, _assetLoadedItem] spawn {
                params ["_asset", "_vehicle"];
                _vehicle attachTo [_asset, [0, 0, -10]];
                detach _vehicle;
                [_asset, _vehicle, false] call WL2_fnc_attachVehicle;
                _vehicle setPosASL (_vehicle modelToWorldWorld [0, 0, -10]);

                private _parachuteClass = switch (BIS_WL_playerSide) do {
                    case west: {
                        "B_Parachute_02_F";
                    };
                    case east: {
                        "O_Parachute_02_F";
                    };
                    case independent: {
                        "I_Parachute_02_F";
                    };
                };

                private _parachute = createVehicle [_parachuteClass, _vehicle, [], 0, "NONE"];
                _parachute setPosASL (_vehicle modelToWorldWorld [0, 0, 0]);
                _parachute setDir (getDir _vehicle);
                _vehicle attachTo [_parachute, [0, 0, 0]];

                waitUntil {
                    uiSleep 0.2;
                    _parachute setVelocity [0, 0, (velocity _parachute) # 2];
                    _parachute setVectorUp [0, 0, 1];
                    private _alt = (getPosVisual _vehicle) # 2;
                    _alt < 5;
                };
                detach _vehicle;
                deleteVehicle _parachute;

                uiSleep 0.5;
                _vehicle setVehiclePosition [_vehicle modelToWorld [0, 0, 0], [], 0, "NONE"];
            };
        };

        private _speed = abs (speed _asset);
        if (_speed > 5) exitWith {
            ["Cannot load/unload deployable while moving!"] call WL2_fnc_smoothText;
            playSound "AddItemFailed";
        };

        private _eligibilityQuery = [_asset, _caller, false, _deployActionId] call WL2_fnc_deployableEligibility;
        _asset setVariable ["WL2_loadingAsset", true, true];

        if (isNull _assetLoadedItem) then {
            private _nearLoadableEntities = _eligibilityQuery # 1;
            if (count _nearLoadableEntities > 0) then {
                private _assetToLoad = _nearLoadableEntities select 0;
                private _offset = _eligibilityQuery # 2;

                [true, [_asset, _assetToLoad, _offset]] remoteExec ["WL2_fnc_attachDetach", _assetToLoad];
                playSoundUI ["a3\sounds_f\vehicles\armor\bobcat\bobcat_plow_up_01.wss", 0.2];
            };
        } else {
            [_asset, _assetLoadedItem] spawn {
                params ["_asset", "_assetLoadedItem"];

                private _assetLoadedItemClass = typeOf _assetLoadedItem;
                private _orderedClass = WL_ASSET_TYPE(_assetLoadedItem);
                private _distanceToVehicle = player distance2D _asset;
                private _offset = [0, _distanceToVehicle, 0];

                private _deploymentAction = {
                    private _deploymentResult = [_assetLoadedItemClass, _orderedClass, _offset, 30, true, false] call WL2_fnc_deployment;

                    if !(_deploymentResult # 0) exitWith {
                        playSound "AddItemFailed";
                        _asset setVariable ["WL2_loadingAsset", false, true];
                        false;
                    };

                    private _position =  _deploymentResult # 1;
                    private _direction = _deploymentResult # 3;
                    private _class = typeOf _assetLoadedItem;
                    private _nearbyEntities = [_assetLoadedItemClass, _position, _direction, "dontcheckuid", [_assetLoadedItem]] call WL2_fnc_grieferCheck;

                    if (count _nearbyEntities > 0) exitWith {
                        private _nearbyObjectName = [_nearbyEntities # 0] call WL2_fnc_getAssetTypeName;
                        [format ["Deploying too close to %1!", _nearbyObjectName]] call WL2_fnc_smoothText;
                        playSound "AddItemFailed";
                        _asset setVariable ["WL2_loadingAsset", false, true];
                        false;
                    };

                    private _offset = _deploymentResult # 2;
                    [false, [_asset, _assetLoadedItem, _offset, _position, _direction]] remoteExec ["WL2_fnc_attachDetach", _assetLoadedItem];

                    playSoundUI ["assemble_target"];
                    true;
                };

                while { WL_ISUP(player) } do {
                    private _deployResult = [] call _deploymentAction;
                    if (_deployResult) then {
                        break;
                    };
                    if (inputAction "navigateMenu" > 0) then {
                        break;
                    };
                    uiSleep 0.1;
                };
            };
        };
	},
	[],
	3,
	false,
	true,
	"",
	"([_target, _this, false, _actionId] call WL2_fnc_deployableEligibility) # 0",
	15,
	false
];

[_asset] spawn {
    params ["_asset"];
    while { alive _asset } do {
        private _assetLoadedItem = _asset getVariable ["WL2_loadedItem", objNull];
        private _hasLoad = !isNull _assetLoadedItem;

        if (_hasLoad) then {
            if (isAutonomous _assetLoadedItem) then {
				[_asset, false] remoteExec ["setAutonomous", 0];
            };
            if ((locked _assetLoadedItem) != 2) then {
                _assetLoadedItem setVehicleLock "LOCKED";
            };
            {
                moveOut _x;
            } forEach (crew _assetLoadedItem);
        };
        uiSleep 1;
    };
};
