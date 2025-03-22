#include "..\..\warlords_constants.inc"

params ["_sector", "_scanEnd"];

if (isDedicated) exitWith {};

private _side = BIS_WL_playerSide;
_sector setVariable [format ["BIS_WL_lastScanEnd_%1", _side], _scanEnd];

BIS_WL_currentlyScannedSectors pushBack _sector;
"Scan" call WL2_fnc_announcer;
playSound "Beep_Target";
[toUpper format [localize "STR_A3_WL_popup_scan_active", _sector getVariable "BIS_WL_name"]] spawn WL2_fnc_smoothText;

private _sectorArea = _sector getVariable "objectAreaComplete";

waitUntil {
    sleep 1;

    private _allDetected = (allUnits + vehicles) select {
        alive _x &&
        _x inArea _sectorArea &&
        [_x] call WL2_fnc_getAssetSide != _side &&
        !(_x isKindOf "Logic") &&
        !(_x isKindOf "WeaponHolderSimulated") &&
        vehicle _x == _x
    };

    {
        _side reportRemoteTarget [_x, 5];
    } forEach _allDetected;

    _sector setVariable ["WL2_detectedUnits", _allDetected];

    (_sector getVariable [format ["BIS_WL_lastScanEnd_%1", BIS_WL_playerSide], -9999]) <= serverTime
};

BIS_WL_currentlyScannedSectors = BIS_WL_currentlyScannedSectors select {
    _x != _sector
};

"Scan_terminated" call WL2_fnc_announcer;
[toUpper format [localize "STR_A3_WL_popup_scan_ended", _sector getVariable "BIS_WL_name"]] spawn WL2_fnc_smoothText;