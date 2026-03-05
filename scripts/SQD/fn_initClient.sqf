#include "includes.inc"
if (side group player == independent) exitWith {};

0 spawn {
    private _playerID = getPlayerID player;
    while { !BIS_WL_missionEnd } do {
        if (getPlayerChannel player > 5 && !(["isInASquad", [_playerID]] call SQD_fnc_query)) then {
            0 spawn SQD_fnc_menu;
        };

        private _isSquadLeaderOfSize = ["isSquadLeaderOfSize", [_playerID, SQD_MIN_COMMAND_CHAT]] call SQD_fnc_query;
        if (_isSquadLeaderOfSize) then {
            2 enableChannel [true, true];
        } else {
            2 enableChannel [false, false];
        };

        uiSleep 0.5;
    };
};