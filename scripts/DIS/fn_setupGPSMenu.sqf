#include "constants.inc"
#include "\a3\ui_f\hpp\definedikcodes.inc"

params ["_asset", "_target"];
private _display = findDisplay DIS_GPS_DISPLAY;

if (isNull _display) then {
    _display = (findDisplay 46) createDisplay "DIS_GPS_MenuUI";
};

private _lon = uiNamespace getVariable ["DIS_GPS_LON", 0];
private _lat = uiNamespace getVariable ["DIS_GPS_LAT", 0];
private _settingLon = uiNamespace setVariable ["DIS_GPS_SETTINGLON", true];

private _lonDisplay = _display displayCtrl DIS_GPS_INPUTLON;
private _latDisplay = _display displayCtrl DIS_GPS_INPUTLAT;

[_lonDisplay, _lon] call DIS_fnc_setGpsNumber;
[_latDisplay, _lat] call DIS_fnc_setGpsNumber;

_lonDisplay ctrlAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_ctrl", "_shift", "_alt"];
    if (_button != 0) exitWith {};
    uiNamespace setVariable ["DIS_GPS_SETTINGLON", true];
    uiNamespace setVariable ["DIS_GPS_LON", 0];
    [_display, 0] call DIS_fnc_setGpsNumber;

    _display ctrlSetTextColor [1, 0, 0, 1];
    ((ctrlParent _display) displayCtrl DIS_GPS_INPUTLAT) ctrlSetTextColor [1, 1, 1, 1];
}];
_latDisplay ctrlAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_ctrl", "_shift", "_alt"];
    if (_button != 0) exitWith {};
    uiNamespace setVariable ["DIS_GPS_SETTINGLON", false];
    uiNamespace setVariable ["DIS_GPS_LAT", 0];
    [_display, 0] call DIS_fnc_setGpsNumber;

    _display ctrlSetTextColor [1, 0, 0, 1];
    ((ctrlParent _display) displayCtrl DIS_GPS_INPUTLON) ctrlSetTextColor [1, 1, 1, 1];
}];

private _closeButton = _display displayCtrl DIS_GPS_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    (ctrlParent _control) closeDisplay 1;
}];

_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    private _lon = uiNamespace getVariable ["DIS_GPS_LON", 0];
    private _lat = uiNamespace getVariable ["DIS_GPS_LAT", 0];
    private _settingLon = uiNamespace getVariable ["DIS_GPS_SETTINGLON", true];

    private _closeKeys = actionKeys "binocular";
    if (_key in _closeKeys) exitWith {
        [_display] spawn {
            params ["_display"];
            waitUntil {
                sleep 0.001;
                inputAction "binocular" == 0;
            };
            _display closeDisplay 1;
        };
    };

    private _numericInput = switch (_key) do {
        case DIK_NUMPAD0;
        case DIK_0: {0};
        case DIK_NUMPAD1;
        case DIK_1: {1};
        case DIK_NUMPAD2;
        case DIK_2: {2};
        case DIK_NUMPAD3;
        case DIK_3: {3};
        case DIK_NUMPAD4;
        case DIK_4: {4};
        case DIK_NUMPAD5;
        case DIK_5: {5};
        case DIK_NUMPAD6;
        case DIK_6: {6};
        case DIK_NUMPAD7;
        case DIK_7: {7};
        case DIK_NUMPAD8;
        case DIK_8: {8};
        case DIK_NUMPAD9;
        case DIK_9: {9};
        case DIK_BACKSPACE: {-1};
        default {-2};
    };
    if (_numericInput == -2) exitWith {};

    if (_settingLon) then {
        private _control = _display displayCtrl DIS_GPS_INPUTLON;

        if (_numericInput == -1) exitWith {
            uiNamespace setVariable ["DIS_GPS_LON", 0];
            [_control, 0] call DIS_fnc_setGpsNumber;
        };

        private _lon = _lon * 10 + _numericInput;
        if (_lon > 999) exitWith {};
        uiNamespace setVariable ["DIS_GPS_LON", _lon];
        [_control, _lon] call DIS_fnc_setGpsNumber;
    } else {
        private _control = _display displayCtrl DIS_GPS_INPUTLAT;

        if (_numericInput == -1) exitWith {
            uiNamespace setVariable ["DIS_GPS_LAT", 0];
            [_control, 0] call DIS_fnc_setGpsNumber;
        };

        private _lat = _lat * 10 + _numericInput;
        if (_lat > 999) exitWith {};
        uiNamespace setVariable ["DIS_GPS_LAT", _lat];
        [_control, _lat] call DIS_fnc_setGpsNumber;
    };
}];

private _datalinkList = _display displayCtrl DIS_GPS_DATALINK_LIST;
_datalinkList ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_lbCurSel"];
    private _targetLonLat = _control lbData _lbCurSel;
    private _targetLonLatSplit = _targetLonLat splitString ":";

    if (count _targetLonLatSplit != 2) exitWith {};

    private _lon = _targetLonLatSplit # 0;
    _lon = parseNumber _lon;
    private _lat = _targetLonLatSplit # 1;
    _lat = parseNumber _lat;

    uiNamespace setVariable ["DIS_GPS_LON", _lon];
    uiNamespace setVariable ["DIS_GPS_LAT", _lat];

    private _display = ctrlParent _control;

    private _lonDisplay = _display displayCtrl DIS_GPS_INPUTLON;
    private _latDisplay = _display displayCtrl DIS_GPS_INPUTLAT;

    [_lonDisplay, _lon] call DIS_fnc_setGpsNumber;
    [_latDisplay, _lat] call DIS_fnc_setGpsNumber;
}];

[_display, _asset] spawn {
    params ["_display", "_asset"];
    while { !isNull _display } do {
        private _lon = uiNamespace getVariable ["DIS_GPS_LON", 0];
        private _lat = uiNamespace getVariable ["DIS_GPS_LAT", 0];
        private _posATL = [_lon * 100, _lat * 100, 0];
        private _posASL = ATLToASL _posATL;

        // Max range calculation
        private _inRangeCalculation = [_asset] call DIS_fnc_calculateInRange;

        private _inRange = _inRangeCalculation # 0;
        private _range = _inRangeCalculation # 1;
        private _distanceNeeded = _inRangeCalculation # 2;

        private _rangeDisplay = _display displayCtrl DIS_GPS_RANGE;

        private _color = if (_inRange) then {
            "#00ff00"
        } else {
            "#ff0000"
        };
        private _inRangeText = if (_inRange) then {
            "IN RANGE"
        } else {
            "OUT OF RANGE"
        };

        _rangeDisplay ctrlSetStructuredText parseText format [
            "<t align='center'>Target Coordinate Distance: %1 KM</t><br/><t align='center'>Munition Range Toward Target: %2 KM</t><br/><t align='center' color='%3' size='1.5'>%4</t>",
            (_distanceNeeded / 1000) toFixed 1,
            (_range / 1000) toFixed 1,
            _color,
            _inRangeText
        ];

        sleep 0.5;
    };
};

[_display, _asset] spawn {
    params ["_display", "_asset"];
    while { !isNull _display } do {
        private _datalinkList = _display displayCtrl DIS_GPS_DATALINK_LIST;
        lbClear _datalinkList;

        private _targets = (listRemoteTargets BIS_WL_playerSide) select {
            private _target = _x # 0;
            private _targetSide = [_target] call WL2_fnc_getAssetSide;

            private _targetTime = _x # 1;
            _targetTime >= -10 && _targetSide != BIS_WL_playerSide && alive _target;
        };

        if (count _targets == 0) then {
            _datalinkList lbAdd "No targets on datalink.";
        };

        {
            private _target = _x # 0;
            private _targetType = [_target] call WL2_fnc_getAssetTypeName;
            private _lbId = _datalinkList lbAdd _targetType;

            private _targetPos = getPosASL _target;
            private _lon = round (_targetPos # 0 / 100);
            private _lat = round (_targetPos # 1 / 100);

            private _assetPos = getPosASL _asset;
            private _distance = _assetPos distance _targetPos;
            private _distanceText = format ["%1 KM", (_distance / 1000) toFixed 1];
            private _posCords = format ["%1     [%2, %3]", _distanceText, _lon, _lat];
            _datalinkList lbSetTextRight [_lbId, format ["%1", _posCords]];
            _datalinkList lbSetValue [_lbId, _distance];

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
            _datalinkList lbSetColor [_lbId, _color];
            _datalinkList lbSetPictureColor [_lbId, _color];

            private _listPic = if (_target isKindOf "Man") then {
                "\a3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa";
            } else {
                if (_target isKindOf "LaserTarget") then {
                    "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\LaserTarget_ca.paa";
                } else {
                    getText (configFile >> "CfgVehicles" >> (typeOf _target) >> "picture");
                };
            };
            _datalinkList lbSetPicture [_lbId, _listPic];

            _datalinkList lbSetData [_lbId, format ["%1:%2", round (_targetPos # 0 / 100), round (_targetPos # 1 / 100)]];
        } forEach _targets;

        lbSortByValue _datalinkList;

        sleep 2;
    };
};