#include "includes.inc"

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\report.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    _message = fromJSON _message;
    private _action = _message select 0;
    switch (_action) do {
        case "select": {
            private _uid = _message select 1;

            private _allPlayers = call BIS_fnc_listPlayers;
            private _selectedPlayer = _allPlayers select { getPlayerUID _x == _uid };
            if (count _selectedPlayer == 0) exitWith { true };
            _selectedPlayer = _selectedPlayer select 0;

            private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;
            private _systemTimeDisplay = [systemTimeUTC] call MENU_fnc_printSystemTime;

            private _hiddenIdentity = _selectedPlayer getVariable ["WL2_hideIdentity", ""];
            if (_hiddenIdentity != "") then {
                _uid = _hiddenIdentity;
            };

            private _playerData = [_uid, _playerName, _systemTimeDisplay];
            private _playerDataJson = toJSON _playerData;
            _playerDataJson = _texture ctrlWebBrowserAction ["ToBase64", _playerDataJson];
            private _script = format [
                "updatePlayerInfo(atobr(""%1""));",
                _playerDataJson
            ];
            _texture ctrlWebBrowserAction ["ExecJS", _script];
        };
        case "report": {
            private _uid = _message select 1;
            private _playerName = _message select 2;
            private _reason = _message select 3;
            _reason = _texture ctrlWebBrowserAction ["FromBase64", _reason];

            [player, _uid, _reason] remoteExec ["MENU_fnc_reportPlayer", 2];
            systemChat format["Reported %1 for %2", _playerName, _reason];

            closeDialog 0;
        };
    };
    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    _this spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            [_texture] call MENU_fnc_sendReportData;
            uiSleep 5;
        };
    };
}];