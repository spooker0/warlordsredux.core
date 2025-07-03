private _selectedTarget = cameraOn getVariable ["WL2_selectedTarget", objNull];

private _targetInList = false;
private _seadTargets = [cameraOn] call DIS_fnc_getSeadTarget;
private _seadTargetList = [["none", "TARGET: AUTO", false]];
{
    private _target = _x # 0;
    private _name = _x # 1;

    if (_seadTargetList findIf { _x # 0 == netid _target } > -1) then {
        continue;
    };

    private _isSelected = _target == _selectedTarget;
    if (_isSelected) then {
        _targetInList = true;
    };

    private _distance = cameraOn distance _target;
    _name = format ["%1 [%2KM]", _name, (_distance / 1000) toFixed 1];
    _seadTargetList pushBack [netid _target, _name, _isSelected];
} forEach _seadTargets;
if (!_targetInList) then {
    if (!alive _selectedTarget) then {
        private _autoOption = _seadTargetList # 0;
        _autoOption set [2, true];
    } else {
        _seadTargetList pushBack [netid _selectedTarget, format ["SELECTED: %1", [_selectedTarget] call WL2_fnc_getAssetTypeName], true];
    };
};

_seadTargetList;