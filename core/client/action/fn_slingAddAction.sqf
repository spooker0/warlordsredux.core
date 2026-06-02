#include "includes.inc"
params ["_asset"];
if (isDedicated) exitWith {};

private _slingActionId = _asset addAction [
	"",
	{
		_this params ["_asset", "_caller", "_slingActionId"];

        private _assetLoadedItem = _asset getVariable ["WL2_loadedItem", objNull];
        if (isNull _assetLoadedItem && isNull (getSlingLoad _asset)) then {
            private _speed = abs (speed _asset);
            if (_speed > 5) exitWith {
                ["Cannot load/unload deployable while moving!"] call WL2_fnc_smoothText;
                playSound "AddItemFailed";
            };

            private _eligibilityQuery = [_asset, _caller, true, _slingActionId] call WL2_fnc_deployableEligibility;
            private _nearLoadableEntities = _eligibilityQuery # 1;

            if (count _nearLoadableEntities > 0) then {
                private _assetToLoad = _nearLoadableEntities select 0;

                [_asset, _assetToLoad, true] call WL2_fnc_attachVehicle;

                playSoundUI ["a3\sounds_f\air\sfx\sl_4hooksunlock.wss"];

                [_asset, _assetToLoad] remoteExec ["WL2_fnc_slingloadInit", _asset];
            };
        } else {
            [_asset, _assetLoadedItem, false] call WL2_fnc_attachVehicle;
            playSoundUI ["a3\sounds_f\air\sfx\sl_4hookslock.wss"];
        };
	},
	[],
	5,
	false,
	false,
	"",
	"([_target, _this, true, _actionId] call WL2_fnc_deployableEligibility) # 0",
	30,
	false
];

_asset addAction [
	"<t color='#00FFFF'>Toggle Rope Length</t>",
	{
		_this spawn {
            params ["_asset", "_caller"];
            private _ropes = ropes _asset;
            if (count _ropes == 0) exitWith {};

            private _assetLoadedItem = _asset getVariable ["WL2_loadedItem", objNull];
            private _shortRope = _asset getVariable ["WL2_shortRope", false];
            if (_shortRope) then {
                detach _assetLoadedItem;
                {
                    ropeUnwind [_x, 5, 20];
                } forEach _ropes;
                _asset setVariable ["WL2_shortRope", false, true];
            } else {
                {
                    ropeUnwind [_x, 5, 5];
                } forEach _ropes;
                uiSleep 3;
                _assetLoadedItem attachTo [_asset, [0, 0, -6]];
                _asset setVariable ["WL2_shortRope", true, true];
            };
        };
	},
	[],
	5,
	false,
	false,
	"",
	"_target == cameraOn && count (ropes _target) > 0",
	30,
	false
];

_asset addEventHandler ["RopeBreak", {
	params ["_asset", "_rope", "_loadedItem"];
    private _assetLoadedItem = _asset getVariable ["WL2_loadedItem", objNull];
    private _hasLoad = !isNull _assetLoadedItem;
    private _attachedTo = ropesAttachedTo _loadedItem;
    if (count _attachedTo == 0 && _hasLoad) then {
        [_asset, _loadedItem, false] call WL2_fnc_attachVehicle;
    };
}];