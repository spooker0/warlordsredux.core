#include "includes.inc"
params ["_target", "_previousAmmo", "_remainingAmmo", "_maxAmmo", "_ammoConsumption"];

if (!hasInterface || isNull _target) exitWith {};
if (isRemoteExecuted && remoteExecutedOwner != 2) exitWith {};

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
private _showEnemyAPS = _settingsMap getOrDefault ["showEnemyAPS", true];
if (!_showEnemyAPS) exitWith {};

disableSerialization;

private _apsDisplay = uiNamespace getVariable ["WL_enemyAPSDisplay", displayNull];
if (isNull _apsDisplay) then {
    "WL_enemyAPS" cutRsc ["RscWLEnemyAPS", "PLAIN"];
    _apsDisplay = uiNamespace getVariable ["WL_enemyAPSDisplay", displayNull];
    uiNamespace setVariable ["WL_enemyAPSRows", [[], []]];
    if (!isNull _apsDisplay) then {
        {
            private _control = _apsDisplay displayCtrl _x;
            _control setVariable ["WL_enemyAPSPosition", ctrlPosition _control];
        } forEach [7801, 7802, 7803, 7811, 7812, 7813];
    };
};

if (isNull _apsDisplay) exitWith {};

private _apsRows = uiNamespace getVariable ["WL_enemyAPSRows", [[], []]];
private _targetId = netId _target;
private _currentTime = diag_tickTime;
private _rowIndex = -1;
{
    if (_rowIndex >= 0) then {
        continue;
    };

    if (count _x == 0) then {
        continue;
    };

    if (_x # 0 == _targetId) then {
        _rowIndex = _forEachIndex;
    };
} forEach _apsRows;

if (_rowIndex < 0) then {
    {
        if (_rowIndex >= 0) then {
            continue;
        };

        if (count _x == 0) then {
            _rowIndex = _forEachIndex;
            continue;
        };

        if (_currentTime > (_x # 5) + 2.5) then {
            _rowIndex = _forEachIndex;
        };
    } forEach _apsRows;
};
if (_rowIndex < 0) then {
    _rowIndex = if ((_apsRows # 0 # 5) <= (_apsRows # 1 # 5)) then {
        0;
    } else {
        1;
    };
};

private _previousRow = _apsRows # _rowIndex;
// Merge only overlapping transitions for the same vehicle; never queue stale counts.
if (count _previousRow > 0) then {
    if (_previousRow # 0 == _targetId) then {
        if (_currentTime - (_previousRow # 5) < 0.4) then {
            _previousAmmo = _previousRow # 1;
            _ammoConsumption = _ammoConsumption + (_previousRow # 4);
        };
    };
};

private _animationId = (uiNamespace getVariable ["WL_enemyAPSGeneration", 0]) + 1;
uiNamespace setVariable ["WL_enemyAPSGeneration", _animationId];
_apsRows set [_rowIndex, [_targetId, _previousAmmo, _remainingAmmo, _maxAmmo, _ammoConsumption, _currentTime, _animationId]];
uiNamespace setVariable ["WL_enemyAPSRows", _apsRows];

private _controlId = 7800 + _rowIndex * 10;
private _ammoControl = _apsDisplay displayCtrl (_controlId + 1);
private _previousAmmoControl = _apsDisplay displayCtrl (_controlId + 2);
private _consumptionControl = _apsDisplay displayCtrl (_controlId + 3);

private _apsColor = if (_remainingAmmo == 0) then {
    [1, 0.35, 0.2, 1];
} else {
    [1, 0.75, 0.3, 1];
};

{
    _x ctrlSetFade 0;
    _x ctrlSetTextColor _apsColor;
    _x ctrlCommit 0;
} forEach [_ammoControl, _previousAmmoControl, _consumptionControl];

{
    private _controlPosition = _x getVariable ["WL_enemyAPSPosition", ctrlPosition _x];
    _x ctrlSetPosition _controlPosition;
    _x ctrlCommit 0;
} forEach [_ammoControl, _previousAmmoControl, _consumptionControl];

private _ammoPosition = ctrlPosition _ammoControl;
private _consumptionPosition = ctrlPosition _consumptionControl;
_ammoControl ctrlSetStructuredText parseText format [
    "<img size='0.78' image='A3\ui_f\data\map\markers\military\pickup_CA.paa'/> %1/%2",
    _previousAmmo,
    _maxAmmo
];
_ammoControl ctrlCommit 0;
_previousAmmoControl ctrlSetStructuredText parseText "";
_consumptionControl ctrlSetStructuredText parseText "";

private _isCurrentAnimation = {
    if (isNull _apsDisplay) exitWith {
        false
    };

    private _apsRows = uiNamespace getVariable ["WL_enemyAPSRows", [[], []]];
    private _apsRow = _apsRows # _rowIndex;
    private _currentAnimationId = _apsRow # 6;
    _currentAnimationId == _animationId;
};

uiSleep 0.15;
if !(call _isCurrentAnimation) exitWith {};

_previousAmmoControl ctrlSetPosition _ammoPosition;
_previousAmmoControl ctrlSetStructuredText parseText format [
    "<img size='0.78' color='#00ffffff' image='A3\ui_f\data\map\markers\military\pickup_CA.paa'/> %1",
    _previousAmmo
];
_previousAmmoControl ctrlSetFade 0;
_previousAmmoControl ctrlCommit 0;
private _previousAmmoPosition = +_ammoPosition;
_previousAmmoPosition set [1, (_ammoPosition # 1) - 0.03];
_previousAmmoControl ctrlSetPosition _previousAmmoPosition;
_previousAmmoControl ctrlSetFade 1;
_previousAmmoControl ctrlCommit 0.25;

_consumptionControl ctrlSetPosition _consumptionPosition;
_consumptionControl ctrlSetStructuredText parseText format ["−%1", _ammoConsumption];
_consumptionControl ctrlCommit 0;
_consumptionPosition set [1, (_consumptionPosition # 1) - 0.03];
_consumptionControl ctrlSetPosition _consumptionPosition;
_consumptionControl ctrlSetFade 1;
_consumptionControl ctrlCommit 0.4;

_ammoControl ctrlSetStructuredText parseText format [
    "<img size='0.78' image='A3\ui_f\data\map\markers\military\pickup_CA.paa'/> %1/%2",
    _remainingAmmo,
    _maxAmmo
];

private _displayDuration = if (_remainingAmmo == 0) then {
    1.8;
} else {
    1.45;
};
uiSleep _displayDuration;
if !(call _isCurrentAnimation) exitWith {};

{
    (_apsDisplay displayCtrl (_controlId + _x)) ctrlSetFade 1;
    (_apsDisplay displayCtrl (_controlId + _x)) ctrlCommit 0.3;
} forEach [1, 2, 3];
