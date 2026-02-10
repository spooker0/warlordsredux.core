#include "includes.inc"
params ["_key", "_targetListFunction", "_targetListParams", "_targetVariable"];

private _display = uiNamespace getVariable ["RscWLTargetingMenu", displayNull];
if (isNull _display) exitWith {};
private _texture = _display displayCtrl 5502;

private _delta = 0;
if (_key in actionKeys "gunElevUp") then {
    _delta = -1;
};

if (_key in actionKeys "gunElevDown") then {
    _delta = 1;
};

if (_delta != 0) then {
    private _targetList = _targetListParams call _targetListFunction;
    private _selectedTarget = cameraOn getVariable [format ["WL2_selectedTarget%1", _targetVariable], objNull];
    private _targetIndex = 0;
    {
        private _target = objectFromNetId (_x # 0);
        if (_target == _selectedTarget) then {
            _targetIndex = _forEachIndex;
        };
    } forEach _targetList;
    private _newIndex = (_targetIndex + _delta) % (count _targetList);
    private _newSelectedTargetId = _targetList select _newIndex select 0;
    private _newSelectedTarget = objectFromNetId _newSelectedTargetId;

    if (!isNull _selectedTarget) then {
        private _selectedTargetThreats = _selectedTarget getVariable ["WL2_advancedThreats", []];
        _selectedTargetThreats = _selectedTargetThreats select {
            _x != cameraOn && alive _x
        };
        _selectedTarget setVariable ["WL2_advancedThreats", _selectedTargetThreats, true];
    };

    if (_newSelectedTargetId != "none" && _newSelectedTarget isKindOf "Air") then {
        private _newSelectedTargetThreats = _newSelectedTarget getVariable ["WL2_advancedThreats", []];
        _newSelectedTargetThreats pushBack cameraOn;
        _newSelectedTargetThreats = _newSelectedTargetThreats select {
            alive _x
        };
        _newSelectedTarget setVariable ["WL2_advancedThreats", _newSelectedTargetThreats, true];
    };
    cameraOn setVariable [format ["WL2_selectedLockPercent%1", _targetVariable], 0];

    cameraOn setVariable [format ["WL2_selectedTarget%1", _targetVariable], _newSelectedTarget];
    playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];
};