#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _assetTypeName = [_asset] call WL2_fnc_getAssetTypeName;
private _actionID = _asset addAction [
	format ["<t color = '#4bff58'>%1 %2</t>", localize "STR_repair", _assetTypeName],
	{
        params ["_asset"];
        private _nextRepairTime = _asset getVariable ["WL2_nextRepair", 0];
        if (_nextRepairTime <= serverTime) then {
            [player, "repair", _nextRepairTime, 0, _asset] remoteExec ["WL2_fnc_handleClientRequest", 2];
            playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Repair.wss", _asset, false, getPosASL _asset, 2, 1, 75];
            [localize "STR_A3_WL_popup_asset_repaired"] call WL2_fnc_smoothText;
            _asset setVariable ["WL2_nextRepair", serverTime + WL_COOLDOWN_REPAIR, true];

            private _maxHealth = _asset getVariable ["WL2_demolitionMaxHealth", 5];
            _asset setVariable ["WL2_demolitionHealth", _maxHealth, true];

            _asset setVariable ["WL2_immobilized", false, true];
        } else {
            playSound "AddItemFailed";
        };
	},
	[],
	5,
	true,
	false,
	"",
	"cursorTarget == _target && [_target, _this] call WL2_fnc_repairActionEligibility",
	WL_MAINTENANCE_RADIUS,
	false
];
_asset setVariable ["WL2_repairActionID", _actionID];

private _allHitPoints = getAllHitPointsDamage _asset;
if (count _allHitPoints == 0) exitWith {};
private _validWheels = _allHitPoints select 0 select {
    _x regexMatch "hit.*wheel" || _x == "hitengine";
};
private _validTracks = _allHitPoints select 0 select {
    _x regexMatch "hit.*track" || _x == "hitengine";
};
private _validHitPoints = _validWheels + _validTracks;

if (count _validHitPoints == 0) exitWith {};

private _repairTitle = if (count _validTracks > 0) then {
    "Track Repair"
} else {
    "Tire Change"
};

private _repairWheels = _asset addAction [
	format ["<t color = '#4bff58'>%1</t>", _repairTitle],
	{
        _this spawn {
            params ["_asset", "_caller", "_actionId", "_arguments"];
            private _animation = "Acts_carFixingWheel";
            [player, [_animation]] remoteExec ["switchMove", 0];

            private _validHitPoints = _arguments select 0;
            [[0, -3, 1]] call WL2_fnc_actionLockCamera;

            ["Animation", ["REPAIR", [
                ["Cancel", "Action"],
                ["", "ActionContext"],
                ["", "navigateMenu"]
            ]], 10, true] spawn WL2_fnc_showHint;

            private _startCheckingUnhold = false;
            private _timeToRemove = serverTime + 5;
            private _timeToRepair = serverTime + 10;
            private _timeToStop = serverTime + 11;
            while { _timeToStop > serverTime } do {
                if (WL_ISDOWN(player)) then {
                    break;
                };

                private _inputAction = inputAction "Action" + inputAction "ActionContext" + inputAction "navigateMenu";
                if (_startCheckingUnhold && _inputAction > 0) then {
                    break;
                };
                if (_inputAction == 0) then {
                    _startCheckingUnhold = true;
                };

                if (_timeToRemove <= serverTime) then {
                    {
                        if (_asset getHitPointDamage _x != 0) then {
                            _asset setHitPointDamage [_x, 1];
                        };
                    } forEach _validHitPoints;
                };

                if (_timeToRepair <= serverTime) then {
                    {
                        _asset setHitPointDamage [_x, 0];
                    } forEach _validHitPoints;
                    _asset setVariable ["WL2_immobilized", false, true];
                };

                if (_timeToStop <= serverTime) then {
                    break;
                };

                uiSleep 0.001;
            };

            ["Animation"] spawn WL2_fnc_showHint;

            cameraOn cameraEffect ["Terminate", "BACK"];
            [player, [""]] remoteExec ["switchMove", 0];
        };
	},
	[_validHitPoints],
	5,
	true,
	true,
	"",
	"cursorTarget == _target && [_target, _this] call WL2_fnc_tireChangeEligibility",
	WL_MAINTENANCE_RADIUS,
	false
];