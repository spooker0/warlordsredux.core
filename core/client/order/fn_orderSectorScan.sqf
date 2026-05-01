#include "includes.inc"
private _conditions = {
	params ["_sector"];

	private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
	if (_sector != WL_TARGET_FRIENDLY && _sectorOwner != BIS_WL_playerSide) exitWith {
		false
	};

	private _currentScannedSectors = missionNamespace getVariable ["WL2_scanningSectors", []];
	if (_sector in _currentScannedSectors) exitWith {
		false
	};

	private _lastScannedVar = format ["WL2_lastScanned_%1", BIS_WL_playerSide];
	private _lastScan = _sector getVariable [_lastScannedVar, -9999];
	if (_lastScan + WL_COOLDOWN_SCAN > serverTime) exitWith {
		false
	};

	true
};

private _successCallback = {
	params ["_sector"];
	[player, "scan", [], _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
};

private _cancelCallback = {
	[localize "STR_A3_WL_scan_canceled"] call WL2_fnc_smoothText;
};

[
	"scan",
	_conditions,
	{},
	_successCallback,
	_cancelCallback,
	[],
	false
] spawn WL2_fnc_orderMapSelection;