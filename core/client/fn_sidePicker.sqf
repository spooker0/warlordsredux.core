#include "includes.inc"

private _camera = "camera" camCreate [0, 0, 1000];
switchCamera _camera;

private _selectedSide = sideUnknown;
waitUntil {
    uiSleep 0.001;
    _selectedSide = player getVariable ["WL2_selectedSide", sideUnknown];
    _selectedSide != sideUnknown;
};

WL_LoadingState = 2;

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));

private _canRepick = _isAdmin || _isModerator || _isSpectator;
#if WL_STOP_TEAM_SWITCH
_canRepick = true;
#endif

if (!_canRepick && _selectedSide != civilian) exitWith {
    switchCamera player;
    camDestroy _camera;
};

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLSidePickerMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\picker.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["PageLoaded", {
    ["main"] call BIS_fnc_endLoadingScreen;
    _this spawn {
        params ["_texture"];
        private _uid = getPlayerUID player;
        private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
        private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
        private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));

        while { !isNull _texture } do {
            private _allPlayers = call BIS_fnc_listPlayers;

            private _bluforPlayers = _allPlayers select {
                side group _x == west
            };
            private _opforPlayers = _allPlayers select {
                side group _x == east
            };

            private _bluforCount = count _bluforPlayers;
            private _opforCount = count _opforPlayers;

            if (_isAdmin) then {
                private _playerArray = [
                    _bluforPlayers apply { name _x },
                    _opforPlayers apply { name _x }
                ];
                private _playerJSON = _texture ctrlWebBrowserAction ["ToBase64", toJSON _playerArray];

                _texture ctrlWebBrowserAction ["ExecJS", format [
                    "setPlayers(%1, %2, %3, atobr(""%4""));",
                    _bluforCount, _opforCount,
                    str (_isAdmin || _isModerator || _isSpectator),
                    _playerJSON
                ]];
            } else {
                _texture ctrlWebBrowserAction ["ExecJS", format [
                    "setPlayers(%1, %2, %3);",
                    _bluforCount, _opforCount,
                    str (_isAdmin || _isModerator || _isSpectator)
                ]];
            };

            uiSleep 0.1;
        };
    };
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "blufor") exitWith {
        player setVariable ["WL2_selectedSide", west, true];
        closeDialog 0;
    };
    if (_message == "opfor") exitWith {
        player setVariable ["WL2_selectedSide", east, true];
        closeDialog 0;
    };

    true;
}];

while { !isNull _texture } do {
    uiSleep 0.001;
};

["main"] call BIS_fnc_startLoadingScreen;

switchCamera player;
camDestroy _camera;