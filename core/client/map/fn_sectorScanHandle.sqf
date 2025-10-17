#include "includes.inc"
params ["_sector", "_uav"];

if (isDedicated) exitWith {};

private _side = BIS_WL_playerSide;

private _currentScannedSectors = missionNamespace getVariable ["WL2_scanningSectors", []];
_currentScannedSectors pushBack _sector;
missionNamespace setVariable ["WL2_scanningSectors", _currentScannedSectors];

"Scan" call WL2_fnc_announcer;
playSound "Beep_Target";
[toUpper format [localize "STR_A3_WL_popup_scan_active", _sector getVariable "WL2_name"]] spawn WL2_fnc_smoothText;

private _sectorArea = _sector getVariable "objectAreaComplete";

waitUntil {
    uiSleep 1;

    private _allDetected = [_side, _sectorArea] call WL2_fnc_detectUnits;

    {
        _side reportRemoteTarget [_x, 1];
    } forEach _allDetected;

    _sector setVariable ["WL2_detectedUnits", _allDetected];
    _sector setVariable ["WL2_lastScanned", serverTime];
    _uav setVariable ["WL2_accessControl", 7];

    player disableUAVConnectability [_uav, true];
    !alive _uav
};

private _currentScannedSectors = missionNamespace getVariable ["WL2_scanningSectors", []];
_currentScannedSectors = _currentScannedSectors select {_x != _sector};
missionNamespace setVariable ["WL2_scanningSectors", _currentScannedSectors];

"Scan_terminated" call WL2_fnc_announcer;
[toUpper format [localize "STR_A3_WL_popup_scan_ended", _sector getVariable "WL2_name"]] spawn WL2_fnc_smoothText;