#include "constants.inc"

params ["_display"];
private _chatHistoryList = _display displayCtrl MODR_CHAT_HISTORY;
while { !isNull _display } do {
    private _chatHistory = uiNamespace getVariable ["WL2_chatHistory", []];
    private _squadChannels = missionNamespace getVariable ["SQD_VoiceChannels", [-1, -1]];
    private _chatHistoryText = _chatHistory apply {
        private _channel = _x # 0;
        private _name = _x # 1;
        private _text = _x # 2;
        private _systemTime = _x # 3;

        private _channelDisplay = switch (_channel) do {
            case 0: { "GLOBAL" };
            case 1: { "SIDE" };
            case 2: { "COMMAND" };
            case 3: { "GROUP" };
            case 4: { "VEHICLE" };
            case 5: { "DIRECT" };
            case 6;
            case 16: { "SYSTEM" };
            case (_squadChannels # 0 + 5);
            case (_squadChannels # 1 + 5): { "SQUAD" };
            default { "UNKNOWN" };
        };
        private _systemTimeDisplay = [_systemTime] call MENU_fnc_printSystemTime;
        private _chatHistoryEntry = format ["[%1 (%2)] %3: %4", _systemTimeDisplay, _channelDisplay, _name, _text];
        _chatHistoryEntry
    };

    private _chatDisplay = _chatHistoryText joinString endl;
    _chatHistoryList ctrlSetText _chatDisplay;

    if (focusedCtrl _display != _chatHistoryList) then {
        _chatHistoryList ctrlSetTextSelection [count _chatDisplay, 0];
    };

    sleep 1;
};