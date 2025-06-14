#include "includes.inc"
params ["_unit", "_target"];
private _asset = vehicle _unit;
private _display = findDisplay DIS_ESAM_DISPLAY;

uiNamespace setVariable ["DIS_ASAM_asset", _asset];

if (isNull _display) then {
    _display = createDialog ["DIS_ESAM_MenuUI", true];
};

private _closeButton = _display displayCtrl DIS_ESAM_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control", "_button"];
    closeDialog 0;
}];

private _launchButton = _display displayCtrl DIS_ESAM_LAUNCH_BUTTON;
_launchButton ctrlShow false;

[_display, _asset] spawn {
    params ["_display", "_asset"];
    private _aircraftList = _display displayCtrl DIS_ESAM_AIRCRAFT_LIST;

    _aircraftList ctrlAddEventHandler ["LBSelChanged", {
        params ["_control", "_index"];
        private _asset = uiNamespace getVariable ["DIS_ASAM_asset", objNull];
        if (!alive _asset) exitWith {};

        private _netId = _control lbData _index;
        if (_netId == "none") then {
            private _lastTarget = _asset getVariable ["WL2_selectedAircraft", objNull];
            _lastTarget setVariable ["WL2_advancedThreat", objNull, true];

            _asset setVariable ["WL2_selectedAircraft", objNull];
            systemChat "Target: None";
        } else {
            private _target = objectFromNetId _netId;

            private _lastTarget = _asset getVariable ["WL2_selectedAircraft", objNull];
            if (_lastTarget != _target) then {
                _lastTarget setVariable ["WL2_advancedThreat", objNull, true];
            };
            _target setVariable ["WL2_advancedThreat", _asset, true];

            _asset setVariable ["WL2_selectedAircraft", _target];
            systemChat format ["Target: %1", _control lbText _index];
            playSoundUI ["AddItemOk"];
        };
    }];

    private _firstRun = true;
    while { alive _asset && !isNull _display } do {
        lbClear _aircraftList;

        private _selectedAircraft = _asset getVariable ["WL2_selectedAircraft", objNull];

        private _detectedAircraft = (listRemoteTargets BIS_WL_playerSide) select {
            private _target = _x # 0;
            private _targetSide = [_target] call WL2_fnc_getAssetSide;
            private _targetTime = _x # 1;
            private _targetAltitude = (ASLtoAGL (getPosASL _target)) # 2;
            private _targetDistance = _target distance _asset;
            _targetTime >= -10 && _targetSide != BIS_WL_playerSide && alive _target && _targetDistance < 14000 && _targetAltitude >= 50
        };


        if (count _detectedAircraft == 0) then {
            private _notFoundId = _aircraftList lbAdd "No enemy aircraft found.";
            _aircraftList lbSetValue [_notFoundId, -1];
            _aircraftList lbSetData [_notFoundId, "none"];
            sleep 1;
            continue;
        };

        private _noneId = _aircraftList lbAdd "None";
        _aircraftList lbSetValue [_noneId, -1];
        _aircraftList lbSetData [_noneId, "none"];
        {
            private _aircraft = _x # 0;

            private _aircraftName = [_aircraft] call WL2_fnc_getAssetTypeName;
            private _lbId = _aircraftList lbAdd _aircraftName;

            private _distance = _asset distance _aircraft;
            private _distanceText = format ["%1 KM AWAY", (_distance / 1000) toFixed 1];

            private _aircraftSide = [_aircraft] call WL2_fnc_getAssetSide;
            private _color = switch (_aircraftSide) do {
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

            _aircraftList lbSetColor [_lbId, _color];
            _aircraftList lbSetPictureColor [_lbId, _color];

            private _aircraftPic = getText (configFile >> "CfgVehicles" >> (typeOf _aircraft) >> "picture");
            _aircraftList lbSetPicture [_lbId, _aircraftPic];

            _aircraftList lbSetTextRight [_lbId, _distanceText];
            _aircraftList lbSetValue [_lbId, _distance];
            _aircraftList lbSetData [_lbId, netId _aircraft];

            if (_selectedAircraft == _aircraft && _firstRun) then {
                _aircraftList lbSetCurSel _lbId;
            };
        } forEach _detectedAircraft;
        _firstRun = false;

        lbSortByValue _aircraftList;
        sleep 1;
    };
};