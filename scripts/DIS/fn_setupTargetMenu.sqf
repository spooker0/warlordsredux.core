#include "includes.inc"
params ["_asset", "_targetFunction"];
private _display = findDisplay DIS_TARGET_DISPLAY;

uiNamespace setVariable ["DIS_targetingAsset", _asset];

if (isNull _display) then {
    _display = createDialog ["DIS_TARGET_MenuUI", true];
};

_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    [_display, _key, _thisEventHandler] spawn {
        params ["_display", "_key", "_thisEventHandler"];
        if (_key in actionKeys "throw") then {
            closeDialog 0;
        };
    };
}];

private _closeButton = _display displayCtrl DIS_TARGET_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control", "_button"];
    closeDialog 0;
}];

private _launchButton = _display displayCtrl DIS_TARGET_LAUNCH_BUTTON;
_launchButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control", "_button"];
    private _asset = uiNamespace getVariable ["DIS_targetingAsset", objNull];
    if (!alive _asset) exitWith {
        closeDialog 0;
    };

    private _selectedTarget = _asset getVariable ["WL2_selectedTarget", objNull];
    if (!alive _selectedTarget) exitWith {
        playSoundUI ["AddItemFailed"];
        systemChat "No target found.";
    };

    private _turret = cameraOn unitTurret focusOn;
    private _weaponState = weaponState [cameraOn, _turret];
    focusOn forceWeaponFire [_weaponState # 0, _weaponState # 2];
    closeDialog 0;
}];

[_display, _asset, _targetFunction] spawn {
    params ["_display", "_asset", "_targetFunction"];
    private _targetList = _display displayCtrl DIS_TARGET_AIRCRAFT_LIST;

    _targetList ctrlAddEventHandler ["LBSelChanged", {
        params ["_control", "_index"];
        private _asset = uiNamespace getVariable ["DIS_targetingAsset", objNull];
        if (!alive _asset) exitWith {};

        private _assetActualType = _asset getVariable ["WL2_orderedClass", typeof _asset];
        private _isAdvancedThreat = WL_ASSET(_assetActualType, "hasASAM", 0) > 0;

        private _netId = _control lbData _index;
        if (_netId == "none") then {
            private _lastTarget = _asset getVariable ["WL2_selectedTarget", objNull];
            if (_isAdvancedThreat) then {
                _lastTarget setVariable ["WL2_advancedThreat", objNull, true];
            };

            _asset setVariable ["WL2_selectedTarget", objNull];
            systemChat "Target: None";
        } else {
            private _target = objectFromNetId _netId;

            private _lastTarget = _asset getVariable ["WL2_selectedTarget", objNull];
            if (_isAdvancedThreat) then {
                if (_lastTarget != _target) then {
                    _lastTarget setVariable ["WL2_advancedThreat", objNull, true];
                };
                _target setVariable ["WL2_advancedThreat", _asset, true];
            };

            _asset setVariable ["WL2_selectedTarget", _target];
            systemChat format ["Target: %1", _control lbText _index];
            playSoundUI ["AddItemOk"];
        };
    }];

    private _firstRun = true;
    while { alive _asset && !isNull _display } do {
        lbClear _targetList;

        private _selectedTarget = _asset getVariable ["WL2_selectedTarget", objNull];

        private _detectedTargets = [_asset] call _targetFunction;

        if (count _detectedTargets == 0) then {
            private _notFoundId = _targetList lbAdd "No enemy targets found.";
            _targetList lbSetValue [_notFoundId, -1];
            _targetList lbSetData [_notFoundId, "none"];
            sleep 1;
            continue;
        };

        private _noneId = _targetList lbAdd "None";
        _targetList lbSetValue [_noneId, -1];
        _targetList lbSetData [_noneId, "none"];
        {
            private _target = _x # 0;
            private _targetName = _X # 1;

            private _lbId = _targetList lbAdd _targetName;

            private _distance = _asset distance _target;
            private _distanceText = format ["%1 KM AWAY", (_distance / 1000) toFixed 1];

            private _targetSide = [_target] call WL2_fnc_getAssetSide;
            private _color = switch (_targetSide) do {
                case west: {
                    [0, 0, 1, 1]
                };
                case east: {
                    [1, 0, 0, 1]
                };
                case independent: {
                    [0, 1, 0, 1]
                };
                default {
                    [1, 1, 1, 1]
                };
            };

            _targetList lbSetColor [_lbId, _color];
            _targetList lbSetPictureColor [_lbId, _color];

            private _targetPic = getText (configFile >> "CfgVehicles" >> (typeOf _target) >> "picture");
            _targetList lbSetPicture [_lbId, _targetPic];

            _targetList lbSetTextRight [_lbId, _distanceText];
            _targetList lbSetValue [_lbId, _distance];
            _targetList lbSetData [_lbId, netId _target];

            if (_selectedTarget == _target && _firstRun) then {
                _targetList lbSetCurSel _lbId;
            };
        } forEach _detectedTargets;
        _firstRun = false;

        lbSortByValue _targetList;
        sleep 1;
    };
};