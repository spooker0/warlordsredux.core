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

    private _lon = uiNamespace getVariable ["DIS_GPS_LON", 0];
    private _lat = uiNamespace getVariable ["DIS_GPS_LAT", 0];
    private _posATL = [_lon * 10, _lat * 10, 0];
    private _posASL = ATLToASL _posATL;
    private _heightASL = _posASL # 2;

    private _display = ctrlParent _display;
    private _heightDisplay = _display displayCtrl DIS_GPS_SEALEVEL;
    private _color = if (_heightASL > 0) then {
        "#00ff00"
    } else {
        "#ff0000"
    };
    _heightDisplay ctrlSetStructuredText parseText format [
        "<t color='%1' size='2' align='center'>%2 M</t><br/><t align='center' size='0.7'>ABOVE SEA LEVEL</t>",
        _color,
        round _heightASL
    ];

    private _sectorDisplay = _display displayCtrl DIS_GPS_SECTOR;
    private _closestSector = [BIS_WL_allSectors, [_posATL], {
        ((_x getVariable "objectAreaComplete") # 0) distance2D _input0
    }, "ASCEND"] call BIS_fnc_sortBy;
    _closestSector = _closestSector # 0;
    private _sectorPos = _closestSector getVariable "objectAreaComplete";

    private _prefix = "INSIDE";
    private _color = "#00ff00";
    if !(_posATL inArea _sectorPos) then {
        private _distance = _posATL distance2D (_sectorPos # 0);
        _prefix = format ["%1 KM FROM", (_distance / 1000) toFixed 1];
        _color = "#ff0000";
    };
    _sectorDisplay ctrlSetStructuredText parseText format [
        "<t align='center' size='1'>%1</t><br/><t align='center' size='1.2' color='%2'>%3</t>",
        _prefix,
        _color,
        toUpper (_closestSector getVariable ["BIS_WL_name", "UNKNOWN"])
    ];
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

    private _closeButton = _display displayCtrl DIS_GPS_CLOSE_BUTTON;
    _closeButton ctrlAddEventHandler ["ButtonClick", {
        params ["_control", "_button"];
        closeDialog 0;
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

    [_display] spawn {
        params ["_display"];
        while { !isNull _display } do {
            private _datalinkList = _display displayCtrl DIS_GPS_DATALINK_LIST;
            lbClear _datalinkList;

            private _targets = (listRemoteTargets BIS_WL_playerSide) select {
                private _target = _x # 0;
                private _targetSide = [_target] call WL2_fnc_getAssetSide;

                private _targetTime = _x # 1;
                _targetTime >= 0 && _targetSide != BIS_WL_playerSide;
            };

            if (count _targets == 0) then {
                _datalinkList lbAdd "No targets on datalink.";
            };

            {
                private _target = _x # 0;
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
            } forEach _targets;

            sleep 2;
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
	"vehicle _this == _target",
	50,
	false
];
