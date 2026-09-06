#include "includes.inc"
params ["_moderate"];
if (!hasInterface) exitWith {};

disableSerialization;

private _uid = getPlayerUID player;
private _isAdmin = _uid in getArray (missionConfigFile >> "adminIDs");
private _isModerator = _uid in getArray (missionConfigFile >> "moderatorIDs");
if (_moderate && !(_isAdmin || _isModerator)) exitWith {};

private _reportDisplay = findDisplay REP_REPORT_IDD;
private _modDisplay = findDisplay REP_MOD_IDD;
if (!isNull _reportDisplay || !isNull _modDisplay) exitWith {};

private _menuClass = if (_moderate) then { "REP_ModMenu" } else { "REP_ReportMenu" };
private _parentDisplay = findDisplay 46;
private _display = _parentDisplay createDisplay _menuClass;
if (isNull _display) exitWith {};

_display setVariable ["REP_isModerator", _moderate];
_display setVariable ["REP_isAdmin", _isAdmin];

private _blur = ppEffectCreate ["DynamicBlur", REP_LAYOUT_BLUR_ID];
_blur ppEffectEnable true;
_blur ppEffectAdjust [3];
_blur ppEffectCommit 0;
_display setVariable ["REP_blur", _blur];
_display displayAddEventHandler ["Unload", {
    params ["_display"];

    private _blur = _display getVariable ["REP_blur", -1];
    ppEffectDestroy _blur;
}];

private _closeButton = _display displayCtrl REP_CLOSE_IDC;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];

    private _display = ctrlParent _control;
    _display closeDisplay 0;
}];

private _searchControl = _display displayCtrl REP_SEARCH_IDC;
_searchControl ctrlAddEventHandler ["EditChanged", {
    params ["_control"];

    private _display = ctrlParent _control;
    [_display] call REP_fnc_refresh;
}];

private _submitAction = if (_moderate) then { "timeout" } else { "report" };
private _actions = [
    [REP_SUBMIT_IDC, _submitAction]
];

if (_moderate) then {
    _actions append [
        [REP_REBALANCE_IDC, "rebalance"],
        [REP_GOTO_IDC, "gotoPlayer"],
        [REP_MUTE_IDC, "mutePlayer"],
        [REP_TRANSFERS_IDC, "seeTransfers"],
        [REP_AFK_IDC, "seeAFKLog"],
        [REP_REWARDS_IDC, "seeRewardLog"],
        [REP_SCRIPTS_IDC, "downloadScriptLog"],
        [REP_DEPUTIZE_IDC, "deputize"],
        [REP_CLEAR_REPORTS_IDC, "clearReports"],
        [REP_CLEAR_TIMEOUT_IDC, "clearTimeout"]
    ];

    {
        private _control = _display displayCtrl _x;
        _control ctrlShow _isAdmin;
    } forEach [REP_SCRIPTS_IDC, REP_DEPUTIZE_IDC];

    private _slider = _display displayCtrl REP_SLIDER_IDC;
    private _durationControl = _display displayCtrl REP_DURATION_IDC;
    private _reasonControl = _display displayCtrl REP_REASON_IDC;

    _slider sliderSetRange [0, REP_MAX_DURATION];
    _slider sliderSetSpeed [1, 15, 1];
    _slider sliderSetPosition REP_DEFAULT_DURATION;
    _durationControl ctrlSetText str REP_DEFAULT_DURATION;

    _slider ctrlAddEventHandler ["SliderPosChanged", {
        params ["_control", "_value"];

        private _display = ctrlParent _control;
        private _durationControl = _display displayCtrl REP_DURATION_IDC;

        _durationControl ctrlSetText str _value;
        [_display] call REP_fnc_updateTimeout;
    }];

    {
        _x ctrlAddEventHandler ["EditChanged", {
            params ["_control"];

            private _display = ctrlParent _control;
            [_display] call REP_fnc_updateTimeout;
        }];
    } forEach [_durationControl, _reasonControl];

    _durationControl ctrlAddEventHandler ["KillFocus", {
        params ["_control"];

        private _display = ctrlParent _control;
        [_display, true] call REP_fnc_updateTimeout;
    }];

    private _timeoutControl = _display displayCtrl REP_TIMEOUTS_IDC;
    _timeoutControl ctrlAddEventHandler ["LBSelChanged", {
        params ["_control", "_index"];

        private _display = ctrlParent _control;
        private _clearTimeoutButton = _display displayCtrl REP_CLEAR_TIMEOUT_IDC;
        _clearTimeoutButton ctrlEnable (_index >= 0);
    }];

    private _channel = _display displayCtrl REP_CHAT_CHANNEL_IDC;
    {
        private _index = _channel lbAdd _x;
        private _channelData = if (_forEachIndex == 0) then { "" } else { _x };

        _channel lbSetData [_index, _channelData];
    } forEach [
        "All channels",
        "GLOBAL",
        "SIDE",
        "COMMAND",
        "GROUP",
        "VEHICLE",
        "DIRECT",
        "SYSTEM",
        "SQUAD"
    ];

    _channel lbSetCurSel 0;

    {
        private _control = _display displayCtrl _x;
        _control ctrlAddEventHandler ["LBSelChanged", {
            params ["_control"];

            private _display = ctrlParent _control;
            if (_display getVariable ["REP_chatRefreshing", false]) exitWith {};

            [_display] call REP_fnc_chat;
        }];
    } forEach [REP_CHAT_CHANNEL_IDC, REP_CHAT_PLAYER_IDC];

    private _chatControl = _display displayCtrl REP_CHAT_IDC;
    _chatControl ctrlAddEventHandler ["LBSelChanged", {
        params ["_control"];

        private _display = ctrlParent _control;
        [_display, "selection"] call REP_fnc_chat;
    }];

    private _resetChatButton = _display displayCtrl REP_CHAT_RESET_IDC;
    _resetChatButton ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];

        private _display = ctrlParent _control;
        [_display, "reset"] call REP_fnc_chat;
    }];
};

{
    _x params ["_idc", "_action"];

    private _control = _display displayCtrl _idc;
    _control setVariable ["REP_action", _action];
    _control ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];

        private _display = ctrlParent _control;
        private _action = _control getVariable "REP_action";

        playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
        [_display, _action] spawn REP_fnc_action;
    }];
} forEach _actions;

[_display] call REP_fnc_refresh;
ctrlSetFocus _searchControl;

[_display] spawn {
    params ["_display"];
    disableSerialization;

    while { !isNull _display } do {
        uiSleep REP_REFRESH_INTERVAL;

        if (!isNull _display) then {
            [_display] call REP_fnc_refresh;
        };
    };
};
