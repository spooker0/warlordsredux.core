#include "includes.inc"
if (side group player == independent) exitWith {};

0 spawn {
    private _playerID = getPlayerID player;

    private _voiceChannels = missionNamespace getVariable ["SQD_VoiceChannels", [-1, -1]];
    private _sideCustomChannel = if (side player == WEST) then {
        _voiceChannels # 0
    } else {
        _voiceChannels # 1
    };
    _sideCustomChannel radioChannelAdd [player];

    0 spawn SQD_fnc_voice;

    while { !BIS_WL_missionEnd } do {
        if (getPlayerChannel player > 5 && !(["isInSquad", [_playerID]] call SQD_fnc_client)) then {
            [true] call SQD_fnc_menu;
        };

        uiSleep 0.5;
    };
};

0 spawn {
    private _squadManagerLastValue = [];
    while { !BIS_WL_missionEnd } do {
        uiSleep 0.1;
        private _dialog = findDisplay 5500;
        if (isNull _dialog) then{
            continue;
        };
        private _squadManager = missionNamespace getVariable ["SQUAD_MANAGER", []];
        if !(_squadManager isEqualTo _squadManagerLastValue) then {
            private _texture = _dialog displayCtrl 5501;
            [_texture] call SQD_fnc_sendData;
            _squadManagerLastValue = +_squadManager;
        };
    };
};