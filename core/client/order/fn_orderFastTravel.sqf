#include "includes.inc"
params ["_fastTravelMode"];

private _conditions = {
	params ["_sector", "_arguments"];
	private _fastTravelMode = _arguments # 0;

	switch (_fastTravelMode) do {
		case 0: {
			private _linkOwner = _sector getVariable ["WL2_linkedOwner", sideUnknown];
			_linkOwner == BIS_WL_playerSide
		};
		case 1;
		case 2: {
			_sector == WL_TARGET_FRIENDLY
		};
		case 3: {
			private _isCarrier = _sector getVariable ["WL2_isAircraftCarrier", false];
			private _linkOwner = _sector getVariable ["WL2_linkedOwner", sideUnknown];
			_linkOwner == BIS_WL_playerSide && !_isCarrier
		};
		case 5: {
			private _linkOwner = _sector getVariable ["WL2_linkedOwner", sideUnknown];
			private _stronghold = _sector getVariable ["WL_stronghold", objNull];
			_linkOwner == BIS_WL_playerSide && !isNull _stronghold
		};
		default {
			false
		};
	};
};

private _successCallback = {
	params ["_sector", "_arguments"];
	private _fastTravelMode = _arguments # 0;
	[_fastTravelMode, _sector] call WL2_fnc_executeFastTravel;
};

private _cancelCallback = {
	[localize "STR_A3_WL_menu_fasttravel_canceled"] call WL2_fnc_smoothText;
};

[
	"fastTravel",
	_conditions,
	{},
	_successCallback,
	_cancelCallback,
	[_fastTravelMode],
	false
] spawn WL2_fnc_orderMapSelection;