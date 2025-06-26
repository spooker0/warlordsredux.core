#include "includes.inc"
params ["_killer", "_event", ["_show", true]];

if (_event == "init") then {
	{
		_varName = format ["BIS_WL_showHint_%1", _x];

		if (isNil _varName) then {
			missionNamespace setVariable [_varName, false]
		};
	} forEach ["assembly", "placeCharge"];

	_hintText = "";
	_lastHint = "";
	while {!BIS_WL_missionEnd} do {
		_hintText = "";

		if (BIS_WL_showHint_assembly) then {
			private _assembleText = format ["<t align = 'left'>[ %1 ]</t><t align = 'right' color = '#4bff58'>%2</t>", (actionKeysNames "BuldSelect") regexReplace ["""", ""], localize "STR_A3_assemble"];
			private _lockPositionText = format ["<t align = 'left'>[ %1 ]</t><t align = 'right' color = '#4bff58'>%2</t>", (actionKeysNames "lockTarget") regexReplace ["""", ""], "Lock Position"];
			private _rotateCounterClockwiseText = format ["<t align = 'left'>[ %1 ]</t><t align = 'right' color = '#4bff58'>%2</t>", (actionKeysNames "prevAction") regexReplace ["""", ""], "Rotate Left"];
			private _rotateClockwiseText = format ["<t align = 'left'>[ %1 ]</t><t align = 'right' color = '#4bff58'>%2</t>", (actionKeysNames "nextAction") regexReplace ["""", ""], "Rotate Right"];
			private _cancelText = format ["<t align = 'left'>[ %1 ]</t><t align = 'right' color = '#ff4b4b'>%2</t>", (actionKeysNames "navigateMenu") regexReplace ["""", ""], localize "STR_ca_cancel"];
			_hintText = _hintText + format ["<t size = '1.2' shadow = '0'>%1<br/>%2<br/>%3<br/>%4<br/>%5<br/></t>", _assembleText, _lockPositionText, _rotateCounterClockwiseText, _rotateClockwiseText, _cancelText];
		};

		if (BIS_WL_showHint_placeCharge) then {
			private _placeChargeText = format ["<t align = 'left'>[ %1 ]</t><t align = 'right' color = '#4bff58'>%2</t>", localize "STR_dik_space", "Place Charge"];
			private _cancelText = format ["<t align = 'left'>[ %1 ]</t><t align = 'right' color = '#ff4b4b'>%2</t>", localize "STR_dik_back", localize "STR_ca_cancel"];
			_hintText = _hintText + format ["<t size = '1.2' shadow = '0'>%1<br/>%2</t>", _placeChargeText, _cancelText];
		};

		if((_hintText != "" ) or ( _lastHint != "")) then {
			hintSilent parseText _hintText;
			_lastHint = _hintText;
		};
		sleep WL_TIMEOUT_MEDIUM;
	};
} else {
	private _varName = format ["BIS_WL_showHint_%1", _event];

	if (_show isEqualType true) then {
		missionNamespace setVariable [_varName, _show];
	};
};