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
            [toUpper localize "STR_A3_WL_popup_asset_repaired"] spawn WL2_fnc_smoothText;
            _asset setVariable ["WL2_nextRepair", serverTime + WL_COOLDOWN_REPAIR, true];
            _asset setVariable ["WL2_demolitionHealth", 10, true];

            ["TaskRepairVehicle"] call WLT_fnc_taskComplete;
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
    _x regexMatch "hit.*wheel";
};
private _validTracks = _allHitPoints select 0 select {
    _x regexMatch "hit.*track";
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
        params ["_asset", "_caller", "_actionId", "_arguments"];
        private _validHitPoints = _arguments select 0;

        player switchMove "Acts_carFixingWheel";
        [_asset, _validHitPoints] spawn {
            params ["_asset", "_validHitPoints"];
            private _wheelsRemoved = false;

            while { alive player && animationState player == "Acts_carFixingWheel" && vehicle player == player } do {
                private _progress = getUnitMovesInfo player # 0;

                if (_progress > 0.3 && !_wheelsRemoved) then {
                    {
                        if (_asset getHitPointDamage _x != 0) then {
                            _asset setHitPointDamage [_x, 1];
                        };
                    } forEach _validHitPoints;
                    _wheelsRemoved = true;
                };

                if (_progress > 0.9 && animationState player == "Acts_carFixingWheel") then {
                    {
                        _asset setHitPointDamage [_x, 0];
                    } forEach _validHitPoints;
                    break;
                };
            };
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