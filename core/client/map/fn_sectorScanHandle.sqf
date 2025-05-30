#include "..\..\warlords_constants.inc"

params ["_sector", "_scanEnd"];

if (isDedicated) exitWith {};

private _side = BIS_WL_playerSide;
_sector setVariable [format ["BIS_WL_lastScanEnd_%1", _side], _scanEnd];

BIS_WL_currentlyScannedSectors pushBack _sector;
"Scan" call WL2_fnc_announcer;
playSound "Beep_Target";
[toUpper format [localize "STR_A3_WL_popup_scan_active", _sector getVariable "WL2_name"]] spawn WL2_fnc_smoothText;

private _sectorArea = _sector getVariable "objectAreaComplete";

waitUntil {
    sleep 1;

    private _allDetected = [_side, _sectorArea] call WL2_fnc_detectUnits;

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
[toUpper format [localize "STR_A3_WL_popup_scan_ended", _sector getVariable "WL2_name"]] spawn WL2_fnc_smoothText;