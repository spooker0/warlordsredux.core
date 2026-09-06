#include "includes.inc"
params ["_display", "_text", "_title"];
disableSerialization;

if (isNull _display) exitWith {};

private _logGroup = _display displayCtrl REP_LOG_GROUP_IDC;
private _logControl = _display displayCtrl REP_LOG_IDC;
private _titleControl = _display displayCtrl REP_LOG_TITLE_IDC;
private _copyControl = _display displayCtrl REP_COPY_LOG_IDC;

_logControl ctrlSetText _text;
_titleControl ctrlSetText _title;

_logGroup ctrlSetPositionH REP_LAYOUT_LOG_H;
_logGroup ctrlCommit 0;
_logGroup ctrlShow true;

[_copyControl, _text, "COPY LOG"] call REP_fnc_setCopyButton;

private _contentGroup = ctrlParentControlsGroup _logGroup;
private _selectedUid = _display getVariable ["REP_selectedUid", ""];
private _scrollRequest = (_logGroup getVariable ["REP_scrollRequest", 0]) + 1;
_logGroup setVariable ["REP_scrollRequest", _scrollRequest];

[_display, _logGroup, _contentGroup, _selectedUid, _scrollRequest, diag_frameNo] spawn {
    params ["_display", "_logGroup", "_contentGroup", "_selectedUid", "_scrollRequest", "_startFrame"];
    disableSerialization;

    private _validRequest = {
        if (isNull _display || isNull _logGroup || isNull _contentGroup) exitWith { false };

        private _currentUid = _display getVariable ["REP_selectedUid", ""];
        private _currentRequest = _logGroup getVariable ["REP_scrollRequest", 0];

        ctrlShown _logGroup && _currentUid == _selectedUid && _currentRequest == _scrollRequest;
    };

    waitUntil {
        if !(call _validRequest) exitWith { true };

        diag_frameNo >= _startFrame + 2 && ctrlCommitted _logGroup && ctrlCommitted _contentGroup;
    };

    if !(call _validRequest) exitWith {};
    _contentGroup ctrlSetScrollValues [1, -1];
};
