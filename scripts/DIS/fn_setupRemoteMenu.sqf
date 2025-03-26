#include "constants.inc"
#include "\a3\ui_f\hpp\definedikcodes.inc"

params ["_asset", "_target"];
private _display = findDisplay DIS_REMOTE_DISPLAY;

if (isNull _display) then {
    _display = createDialog ["DIS_Remote_MenuUI", true];
};

private _closeButton = _display displayCtrl DIS_REMOTE_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control", "_button"];
    closeDialog 0;
}];

private _cameraView = _display displayCtrl DIS_REMOTE_CONTROL_STATION_PREVIEW;
_cameraView ctrlShow false;

[_display, _asset] spawn {
    params ["_display", "_asset"];
    private _remoteControlList = _display displayCtrl DIS_REMOTE_CONTROL_STATION_LIST;
    private _camera = "camera" camCreate [0, 0, 0];
    _camera cameraEffect ["Terminate", "BACK TOP", "rtt2"];
    _camera cameraEffect ["Internal", "BACK TOP", "rtt2"];
    uiNamespace setVariable ["DIS_remoteControlCamera", _camera];

    _remoteControlList ctrlAddEventHandler ["LBSelChanged", {
        params ["_control", "_index"];
        private _asset = vehicle player;

        if (!alive _asset) exitWith {};
        if (_asset == player) exitWith {};

        private _netId = _control lbData _index;
        private _existingValue = _asset getVariable ["DIS_remoteControlStation", objNull];

        private _camera = uiNamespace getVariable ["DIS_remoteControlCamera", objNull];
        private _display = ctrlParent _control;
        private _cameraView = _display displayCtrl DIS_REMOTE_CONTROL_STATION_PREVIEW;

        if (_netId == "none") then {
            if (!isNull _existingValue) then {
                _asset setVariable ["DIS_remoteControlStation", objNull, true];
            };
            _cameraView ctrlShow false;
        } else {
            private _controlStation = objectFromNetId _netId;
            if (_existingValue != _controlStation) then {
                _asset setVariable ["DIS_remoteControlStation", _controlStation, true];
            };

            _camera camSetTarget _controlStation;
            _camera camSetRelPos [0, -4, 2];
            _camera camCommit 0;

            _cameraView ctrlShow true;
        };
    }];

    private _firstRun = true;
    while { alive _asset && !isNull _display } do {
        lbClear _remoteControlList;

        private _teamVehiclesVar = format ["BIS_WL_%1OwnedVehicles", BIS_WL_playerSide];
        private _teamVehicles = missionNamespace getVariable [_teamVehiclesVar, []];
        _teamVehicles = _teamVehicles arrayIntersect _teamVehicles;
        private _controlStations = _teamVehicles select {
            typeOf _x == "RuggedTerminal_01_communications_F"
        };
        if (count _controlStations == 0) then {
            private _notFoundId = _remoteControlList lbAdd "No ground support terminals found. Buy Menu >> Remote Control >> Ground Support Terminal.";
            _remoteControlList lbSetValue [_notFoundId, -1];
            _remoteControlList lbSetData [_notFoundId, "none"];
            sleep 1;
            continue;
        };

        private _currentStation = _asset getVariable ["DIS_remoteControlStation", objNull];

        private _noneId = _remoteControlList lbAdd "None";
        _remoteControlList lbSetValue [_noneId, -1];
        _remoteControlList lbSetData [_noneId, "none"];
        {
            private _station = _x;
            private _stationASL = getPosASL _station;
            private _stationOwner = (_station getVariable ["BIS_WL_ownerAsset", "123"]) call BIS_fnc_getUnitByUID;
            private _stationName = format ["Terminal: %1 [%2, %3]", name _stationOwner, round (_stationASL # 0 / 100), round (_stationASL # 1 / 100)];
            private _lbId = _remoteControlList lbAdd _stationName;

            private _assetPos = getPosASL _asset;
            private _distance = _assetPos distance _stationASL;
            private _distanceText = format ["%1 KM AWAY", (_distance / 1000) toFixed 1];
            _remoteControlList lbSetTextRight [_lbId, _distanceText];
            _remoteControlList lbSetValue [_lbId, _distance];
            _remoteControlList lbSetData [_lbId, netId _station];

            if (_currentStation == _station && _firstRun) then {
                _remoteControlList lbSetCurSel _lbId;
            };
        } forEach _controlStations;
        _firstRun = false;

        lbSortByValue _remoteControlList;
        sleep 1;
    };

    camDestroy _camera;
};