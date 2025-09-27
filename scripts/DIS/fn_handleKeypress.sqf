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
    private _selectedTarget = cameraOn getVariable [_targetVariable, objNull];
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

    private _assetActualType = cameraOn getVariable ["WL2_orderedClass", typeof cameraOn];
    private _isAdvancedThreat = WL_ASSET(_assetActualType, "hasASAM", 0) > 0;
    if (_isAdvancedThreat) then {
        if (!isNull _selectedTarget) then {
            _selectedTarget setVariable ["WL2_advancedThreat", objNull, true];
        };
        if (_newSelectedTargetId != "none") then {
            _newSelectedTarget setVariable ["WL2_advancedThreat", cameraOn, true];
        };
    };

    cameraOn setVariable [_targetVariable, _newSelectedTarget];
    playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];
};