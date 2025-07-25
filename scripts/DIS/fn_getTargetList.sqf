#include "includes.inc"
params ["_targetFunction", "_defaultOption"];

private _selectedTarget = cameraOn getVariable ["WL2_selectedTarget", objNull];

private _targetInList = false;
private _targets = [cameraOn] call _targetFunction;
private _targetList = [["none", _defaultOption, false]];
{
    private _target = _x # 0;
    private _name = _x # 1;

    if (_targetList findIf { _x # 0 == netid _target } > -1) then {
        continue;
    };

    private _isSelected = _target == _selectedTarget;
    if (_isSelected) then {
        _targetInList = true;
    };

    private _distance = cameraOn distance _target;
    _name = format ["%1 [%2KM]", toUpper _name, (_distance / 1000) toFixed 1];
    _targetList pushBack [netid _target, _name, _isSelected];
} forEach _targets;
if (!_targetInList) then {
    if (!alive _selectedTarget) then {
        private _autoOption = _targetList # 0;
        _autoOption set [2, true];
    } else {
        _targetList pushBack [netid _selectedTarget, format ["SELECTED: %1", [_selectedTarget] call WL2_fnc_getAssetTypeName], true];
    };
};

_targetList;