#include "constants.inc"

params ["_selectedPlayer"];

private _display = findDisplay MODR_DISPLAY;
if (isNull _display) exitWith {};

private _infoDisplay = _display displayCtrl MODR_INFO_DISPLAY;
_infoDisplay ctrlShow true;

private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;
private _playerGuid = getPlayerUID _selectedPlayer;

private _timeoutTime = _display displayCtrl MODR_TIMEOUT_TIME;
private _timeoutButton = _display displayCtrl MODR_TIMEOUT_BUTTON;

private _systemTimeDisplay = [systemTimeUTC] call MENU_fnc_printSystemTime;
private _fullDisplayString = format["[Name] %1%5[BEID] %2%5[GUID] %3%5[UTC] %4", _playerName, "Loading...", _playerGuid, _systemTimeDisplay, endl];
_infoDisplay ctrlSetText _fullDisplayString;

private _beIdReply = "";
private _startTime = serverTime;
waitUntil {
    sleep 0.1;
    _beIdReply = uiNamespace getVariable ["MODR_returnedBeId", ""];
    _beIdReply != "" || serverTime - _startTime > 10;
};
if (_beIdReply == "") then {
    _beIdReply = "Failed to load Battleye info...";
};

_fullDisplayString = format["[Name] %1%5[BEID] %2%5[GUID] %3%5[UTC] %4", _playerName, _beIdReply, _playerGuid, _systemTimeDisplay, endl];
_infoDisplay ctrlSetText _fullDisplayString;

private _elevated = _display getVariable ["MODR_elevatedPrivilege", false];

private _timeoutReasonLabel = _display displayCtrl MODR_TIMEOUT_REASON_LABEL;
private _timeoutReasonEdit = _display displayCtrl MODR_TIMEOUT_REASON;
private _reportTable = _display displayCtrl MODR_REPORT_TABLE;
private _clearReports = _display displayCtrl MODR_CLEAR_REPORTS;
private _clearTimeout = _display displayCtrl MODR_CLEAR_TIMEOUT;
private _rebalance = _display displayCtrl MODR_REBALANCE;

if (_elevated) then {
    _timeoutReasonLabel ctrlShow true;
    _timeoutReasonEdit ctrlShow true;
    _timeoutTime ctrlShow true;
    _timeoutButton ctrlShow true;

    _timeoutButton ctrlSetText format["Timeout %1 for %2 minutes", _playerName, sliderPosition _timeoutTime];

    _reportTable ctrlShow true;
    _clearReports ctrlShow true;
    _clearTimeout ctrlShow true;
    _rebalance ctrlShow true;

    private _playerReports = _selectedPlayer getVariable ["WL2_playerReports", createHashMap];
    lbClear _reportTable;
    {
        private _reporterName = _x;
        private _reportReason = _y;
        private _reportId = _reportTable lbAdd _reportReason;
        _reportTable lbSetTextRight [_reportId, _reporterName];
    } forEach _playerReports;
} else {
    _timeoutReasonLabel ctrlShow true;
    _timeoutReasonEdit ctrlShow true;
    _timeoutTime ctrlShow false;
    _timeoutButton ctrlShow true;

    _timeoutButton ctrlSetText format["Report %1", _playerName];
};