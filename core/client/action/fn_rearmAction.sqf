#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};
if (_asset isKindOf "Building") exitWith {};

private _actionConditions = {
	if (vehicle _this != _this) exitWith { false };
	if (!alive _target) exitWith { false };
	private _accessControl = [_target, _this, "full"] call WL2_fnc_accessControl;
	if (!(_accessControl # 0)) exitWith { false };
	[getPosASL player, getDir player, 180, getPosASL _target] call WL2_fnc_inAngleCheck
};

private _rearmActionId = _asset addAction [
	format ["Modify/%1", localize "STR_rearm"],
	{
		params ["_asset"];
		_asset spawn WLM_fnc_initMenu;
	},
	[],
	5,
	false,
	false,
	"",
	toString _actionConditions,
	WL_MAINTENANCE_RADIUS,
	false
];

_asset setUserActionText [
	_rearmActionId,
	format ["<t color='#4bff58'>Modify/%1</t>", localize "STR_rearm"],
	"<img size='1.5' image='a3\ui_f\data\igui\cfg\simpletasks\types\rearm_ca.paa'/>"
];

private _maxAmmo = [_asset] call APS_fnc_getMaxAmmo;
if (_maxAmmo >= 6) then {
	_asset addAction [
		"<t color='#4bff58'>Reload APS</t>",
		{
			_this spawn {
				params ["_asset", "_caller", "_actionId", "_arguments"];
				private _animation = "Acts_TerminalOpen";
				[player, [_animation]] remoteExec ["switchMove", 0];

				[[0, -3, 1]] call WL2_fnc_actionLockCamera;

				["Animation", ["REPAIR", [
					["Cancel", "Action"],
					["", "ActionContext"],
					["", "navigateMenu"]
				]], WL_DURATION_REARMAPS, true] spawn WL2_fnc_showHint;

				private _startCheckingUnhold = false;
				private _timeToStop = serverTime + WL_DURATION_REARMAPS;
				private _actionSuccess = false;
				while { true } do {
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

					if (_timeToStop <= serverTime) then {
						_actionSuccess = true;
						break;
					};

					uiSleep 0.001;
				};

				["Animation"] spawn WL2_fnc_showHint;

				if (_actionSuccess) then {
					_asset spawn APS_fnc_rearmAPS;
					playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Rearm.wss", _asset, false, getPosASL _asset, 2, 1, 75];
				} else {
					playSoundUI ["AddItemFailed"];
				};

				cameraOn cameraEffect ["Terminate", "BACK"];
				[player, [""]] remoteExec ["switchMove", 0];
			};
		},
		[],
		5,
		true,
		true,
		"",
		"cursorTarget == _target && [_target, _this] call WL2_fnc_rearmAPSEligibility",
		WL_MAINTENANCE_RADIUS,
		false
	];
};