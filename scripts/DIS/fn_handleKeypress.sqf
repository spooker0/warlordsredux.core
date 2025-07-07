#include "includes.inc"
params ["_key", "_displayName", "_targetListFunction", "_defaultOption"];

private _targetDisplay = uiNamespace getVariable [_displayName, displayNull];
if (isNull _targetDisplay) exitWith {};

private _delta = 0;
if (_key in actionKeys "gunElevUp") then {
    _delta = -1;
};

if (_key in actionKeys "gunElevDown") then {
    _delta = 1;
};

if (_delta != 0) then {
    private _targetList = [_targetListFunction, _defaultOption] call DIS_fnc_getTargetList;
    private _selectedTarget = cameraOn getVariable ["WL2_selectedTarget", objNull];
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

    cameraOn setVariable ["WL2_selectedTarget", _newSelectedTarget];

    private _texture = _targetDisplay displayCtrl 5502;

    _targetList = [_targetListFunction, _defaultOption] call DIS_fnc_getTargetList;
    [_texture, _targetList] call DIS_fnc_sendTargetData;
    playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];
};