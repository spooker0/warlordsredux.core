#include "includes.inc"

private _selectedLaserTarget = cameraOn getVariable ["WL2_selectedTargetLaser", objNull];

private _currentMode = uiNamespace getVariable ["DIS_currentTargetingMode", "none"];
private _isLasing = _currentMode == "lasing";
private _laserTargetList = if (_isLasing) then {
    []
} else {
    [["none", "NO TARGET", false]]
};

private _targetInList = false;

private _side = BIS_WL_playerSide;

private _allLaserTargets = if (_side == west) then {
    entities "LaserTargetW";
} else {
    entities "LaserTargetE";
};

private _enemyUnits = switch (_side) do {
    case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
    case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
    default { [] };
};

private _allLasedTargets = [];
{
    private _laserTarget = _x;
    private _lasePosition = getPosASL _laserTarget;
    if (count _lasePosition < 3) then {
        continue;
    };
    if (_lasePosition isEqualTo [0, 0, 0]) then {
        continue;
    };

    private _enemiesNear = _enemyUnits select {
        alive _x;
    } select {
        (_x distance2D _lasePosition) < 250;
    } select {
        _x distance cameraOn < 20000;
    } select {
        !(_x isKindOf "Man");
    } select {
        !(getText (configFile >> "CfgVehicles" >> typeOf _x >> "destrType") in ["DestructNo", "DestructTree"]);
    };

    _allLasedTargets insert [-1, _enemiesNear, true];
} forEach _allLaserTargets;

{
    private _lasedTarget = _x;

    private _isSelected = _lasedTarget == _selectedLaserTarget;
    if (_isSelected) then {
        _targetInList = true;
    };

    private _distance = cameraOn distance _lasedTarget;
    private _assetName = toUpper ([_lasedTarget] call WL2_fnc_getAssetTypeShortName);
    private _name = format ["%1 (%2 KM)", _assetName, (_distance / 1000) toFixed 1];
    _laserTargetList pushBack [netid _lasedTarget, _name, _isSelected];
} forEach _allLasedTargets;

if (!_targetInList) then {
    if (!alive _selectedLaserTarget) then {
        if (!_isLasing) then {
            private _autoOption = _laserTargetList # 0;
            _autoOption set [2, true];
        };
    } else {
        _laserTargetList pushBack [netid _selectedLaserTarget, format ["SELECTED: %1", [_selectedLaserTarget] call WL2_fnc_getAssetTypeName], true];
    };
};

_laserTargetList;