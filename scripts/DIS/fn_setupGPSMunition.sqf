#include "constants.inc"
#include "\a3\ui_f\hpp\definedikcodes.inc"

params ["_asset"];

DIS_fnc_setGpsNumber = {
    params ["_display", "_number"];

    private _num1 = floor (_number / 1000);
    private _num2 = floor ((_number - _num1 * 1000) / 100);
    private _num3 = floor ((_number - _num1 * 1000 - _num2 * 100) / 10);
    private _num4 = _number % 10;
    _display ctrlSetText format ["%1%2%3.%4", _num1, _num2, _num3, _num4];
};

private _setupMenu = {
    params ["_asset", "_target"];
    private _display = findDisplay DIS_GPS_DISPLAY;

    if (isNull _display) then {
        _display = createDialog ["DIS_GPS_MenuUI", true];
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

    _display displayAddEventHandler ["KeyDown", {
        params ["_display", "_key", "_shift", "_ctrl", "_alt"];

        private _lon = uiNamespace getVariable ["DIS_GPS_LON", 0];
        private _lat = uiNamespace getVariable ["DIS_GPS_LAT", 0];
        private _settingLon = uiNamespace getVariable ["DIS_GPS_SETTINGLON", true];

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
            if (_lon > 9999) exitWith {};
            uiNamespace setVariable ["DIS_GPS_LON", _lon];
            [_control, _lon] call DIS_fnc_setGpsNumber;
        } else {
            private _control = _display displayCtrl DIS_GPS_INPUTLAT;

            if (_numericInput == -1) exitWith {
                uiNamespace setVariable ["DIS_GPS_LAT", 0];
                [_control, 0] call DIS_fnc_setGpsNumber;
            };

            private _lat = _lat * 10 + _numericInput;
            if (_lat > 9999) exitWith {};
            uiNamespace setVariable ["DIS_GPS_LAT", _lat];
            [_control, _lat] call DIS_fnc_setGpsNumber;
        };
    }];

    private _datalinkList = _display displayCtrl DIS_GPS_DATALINK_LIST;
    _datalinkList ctrlAddEventHandler ["LBSelChanged", {
        params ["_control", "_lbCurSel"];
        private _targetLonLat = _control lbData _lbCurSel;
        private _targetLonLatSplit = _targetLonLat splitString ":";

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

    [_display] spawn {
        params ["_display"];
        while { !isNull _display } do {
            private _datalinkList = _display displayCtrl DIS_GPS_DATALINK_LIST;
            lbClear _datalinkList;
            {
                private _target = _x # 0;
                private _targetSide = [_target] call WL2_fnc_getAssetSide;
                if (_targetSide == BIS_WL_playerSide) then {
                    continue;
                };

                private _assetType = [_target] call WL2_fnc_getAssetTypeName;
                private _lbId = _datalinkList lbAdd _assetType;

                private _targetPos = getPosASL _target;
                private _lon = (_targetPos # 0 / 100) toFixed 1;
                private _lat = (_targetPos # 1 / 100) toFixed 1;
                private _posCords = format ["[%1, %2]", _lon, _lat];
                _datalinkList lbSetTextRight [_lbId, format ["%1", _posCords]];

                private _listPic = if (_target isKindOf "Man") then {
                    "\a3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa";
                } else {
                    getText (configFile >> "CfgVehicles" >> (typeOf _target) >> "picture");
                };
                _datalinkList lbSetPicture [_lbId, _listPic];

                _datalinkList lbSetData [_lbId, format ["%1:%2", _targetPos # 0 / 10, _targetPos # 1 / 10]];
            } forEach (listRemoteTargets BIS_WL_playerSide);

            sleep 1;
        };
    };

};

private _actionID = _asset addAction [
	"<t color='#0000ff'>GPS Munition Configuration</t>",
	_setupMenu,
	[],
	100,
	true,
	false,
	"",
	"true",
	50,
	false
];
