#include "includes.inc"
params ["_display"];

private _squadNameEdit = _display getVariable ["SQD_squadNameEdit", controlNull];
if (!isNull _squadNameEdit) exitWith {};

private _side = BIS_WL_playerSide;

private _gridBackgroundColor = [SQD_RGBA_DARKER];

private _squadListY = 0;
private _squadSlotW = (SQD_LAYOUT_PANEL_W - ((SQD_LAYOUT_SQUAD_COLUMNS + 1) * SQD_LAYOUT_GRID_BORDER)) / SQD_LAYOUT_SQUAD_COLUMNS;
private _squadSlotInnerH = SQD_LAYOUT_SQUAD_SLOT_H - SQD_LAYOUT_GRID_BORDER;
private _squadSlotStepX = _squadSlotW + SQD_LAYOUT_GRID_BORDER;
private _squadSlotStepY = _squadSlotInnerH + SQD_LAYOUT_GRID_BORDER;

private _teamTextColor = switch (_side) do {
    case west: { "#004C99" };
    case east: { "#800000" };
    default { "#008000" };
};

// Mock data for testing
// private _squads = [
//     createHashMapFromArray [
//         ["name", "Alpha Squad"],
//         ["leader", "1"],
//         ["members", ["1", "3", "4", "5", "6", "7", "8", "9", "10"]],
//         ["side", west],
//         ["locked", false],
//         ["channel", -1]
//     ],
//     createHashMapFromArray [
//         ["name", "Bravo Squad"],
//         ["leader", "6"],
//         ["members", ["6", "7", "8"]],
//         ["side", west],
//         ["locked", false],
//         ["channel", -1]
//     ],
//     createHashMapFromArray [
//         ["name", "Charlie Squad"],
//         ["leader", "100"],
//         ["members", ["9", "10", "100"]],
//         ["side", west],
//         ["locked", true],
//         ["channel", -1]
//     ],
//     createHashMapFromArray [
//         ["name", "Delta Squad"],
//         ["leader", "11"],
//         ["members", ["11", "12", "13", "14", "15"]],
//         ["side", west],
//         ["locked", false],
//         ["channel", -1]
//     ],
//     createHashMapFromArray [
//         ["name", "Echo Squad"],
//         ["leader", "16"],
//         ["members", ["16", "17"]],
//         ["side", west],
//         ["locked", false],
//         ["channel", -1]
//     ]
// ];
// private _playerId = "100";

// Actual
private _playerId = getPlayerID player;
private _squads = missionNamespace getVariable ["SQUAD_MANAGER", []];
_squads = _squads select {
    _x getOrDefault ["side", west] == _side
} select {
    private _members = _x getOrDefault ["members", []];
    count _members > 0
};

private _badgeConfigs = call RWD_fnc_getBadgeConfigs;

_squads = [_squads, [], {
    private _squadLeader = _x getOrDefault ["leader", ""];
    private _squadVotingPower = ["getSquadVotingPower", [_squadLeader]] call SQD_fnc_query;
    _squadVotingPower
}, "DESCEND"] call BIS_fnc_sortBy;

private _squadsForMenu = [_squads, [_playerId], {
    private _members = _x getOrDefault ["members", []];

    if (_playerId in _members) then {
        -1
    } else {
        1
    };
}, "ASCEND"] call BIS_fnc_sortBy;

private _unassignedPlayerText = _display displayCtrl SQD_UNASSIGNED_TEXT_IDC;
private _unassignedPlayers = ["getUnsquaddedPlayers", [side group player]] call SQD_fnc_query;
_unassignedPlayerText ctrlSetText format [" UNASSIGNED PLAYERS: %1", count _unassignedPlayers];

private _squadCreateButton = _display displayCtrl SQD_CREATE_SQUAD_IDC;
_squadCreateButton ctrlRemoveAllEventHandlers "ButtonClick";

private _playerSquad = ["getSquadForPlayer", [getPlayerID player]] call SQD_fnc_query;
if (count _playerSquad == 0) then {
    private _squadCreateText = ["CREATE SQUAD", SQD_LAYOUT_BUTTON_TEXT_SIZE, SQD_COLOR_TEXT, "center"] call SQD_fnc_renderText;
    _squadCreateButton ctrlSetStructuredText _squadCreateText;

    _squadCreateButton ctrlAddEventHandler ["ButtonClick", {
        params ["_button"];
        ["create"] spawn SQD_fnc_client;
        private _display = ctrlParent _button;
        private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
        ctrlSetFocus _dummyButton;
    }];
} else {
    private _squadInviteText = ["INVITE TO SQUAD", SQD_LAYOUT_BUTTON_TEXT_SIZE, SQD_COLOR_TEXT, "center"] call SQD_fnc_renderText;
    _squadCreateButton ctrlSetStructuredText _squadInviteText;

    _squadCreateButton ctrlAddEventHandler ["ButtonClick", SQD_fnc_contextInvite];
};

private _squadListGroup = _display displayCtrl SQD_SQUAD_LIST_IDC;

private _squadControls = _display getVariable ["SQD_squadControls", createHashMap];
_display setVariable ["SQD_squadControls", _squadControls];

private _seenSquadKeys = createHashMap;
private _playerContributions = missionNamespace getVariable ["WL_PlayerSquadContribution", createHashMap];

{
    private _squad = _x;

    private _members = _squad getOrDefault ["members", []];
    private _squadLeader = _squad getOrDefault ["leader", ""];
    private _locked = _squad getOrDefault ["locked", false];

    private _playerCount = count _members;
    if (_playerCount == 0) then {
        continue;
    };

    private _squadKey = _squadLeader;
    _seenSquadKeys set [_squadKey, true];

    private _isPlayerSquad = _playerId in _members;
    private _isPlayerThisSquadLeader = _squadLeader == _playerId;

    private _rowCount = ceil (_playerCount / SQD_LAYOUT_SQUAD_COLUMNS);
    private _playersH = SQD_LAYOUT_GRID_BORDER + (_rowCount * _squadSlotStepY);
    private _squadBarH = SQD_LAYOUT_HEADER_H + _playersH;

    private _squadEntry = _squadControls getOrDefault [_squadKey, createHashMap];

    private _squadBar = _squadEntry getOrDefault ["bar", controlNull];

    if (isNull _squadBar) then {
        _squadBar = _display ctrlCreate ["SQD_Menu_SquadBar", -1, _squadListGroup];

        private _playerGridBorder = _display ctrlCreate ["RscText", -1, _squadBar];
        _playerGridBorder ctrlSetBackgroundColor _gridBackgroundColor;
        _playerGridBorder ctrlCommit 0;

        _squadEntry set ["bar", _squadBar];
        _squadEntry set ["gridBorder", _playerGridBorder];
        _squadEntry set ["playerSlots", createHashMap];

        _squadControls set [_squadKey, _squadEntry];
    };

    _squadBar ctrlSetPosition [
        0,
        _squadListY,
        SQD_LAYOUT_PANEL_W,
        _squadBarH
    ];
    _squadBar ctrlCommit 0;

    private _playerGridBorder = _squadEntry getOrDefault ["gridBorder", controlNull];

    if (!isNull _playerGridBorder) then {
        _playerGridBorder ctrlSetPosition [
            0,
            SQD_LAYOUT_HEADER_H,
            SQD_LAYOUT_PANEL_W,
            _playersH
        ];
        _playerGridBorder ctrlSetBackgroundColor _gridBackgroundColor;
        _playerGridBorder ctrlCommit 0;
    };

    private _squadNumberText = _squadBar controlsGroupCtrl SQD_NUMBER_IDC;

    private _squadIndex = -1;
    {
        if ((_x getOrDefault ["leader", ""]) == _squadLeader) then {
            _squadIndex = _forEachIndex + 1;
        };
    } forEach _squads;

    if (_squadIndex == -1) then {
        _squadIndex = 0;
    };

    private _squadNumber = if (_squadIndex < 10) then {
        format ["0%1", _squadIndex]
    } else {
        str _squadIndex
    };

    _squadNumberText ctrlSetText _squadNumber;

    private _squadNameText = _squadBar controlsGroupCtrl SQD_NAME_IDC;
    private _squadName = _squad getOrDefault ["name", "Squad"];
    _squadNameText ctrlShow true;

    private _squadNameColor = if (_locked) then {
        SQD_COLOR_LOCKED
    } else {
        SQD_COLOR_TEXT
    };

    private _squadNameTextStructured = [toUpper _squadName, SQD_LAYOUT_LABEL_TEXT_SIZE, _squadNameColor, "left"] call SQD_fnc_renderText;
    _squadNameText ctrlSetStructuredText _squadNameTextStructured;

    private _squadVotingPower = ["getSquadVotingPower", [_squadLeader]] call SQD_fnc_query;
    _squadNameText ctrlSetTooltip format ["Vote Power: %1", round _squadVotingPower];

    _squadNameText ctrlRemoveAllEventHandlers "ButtonClick";

    if (_isPlayerThisSquadLeader) then {
        _squadNameText ctrlAddEventHandler ["ButtonClick", SQD_fnc_contextSquad];
    };

    private _squadNameEdit = _squadBar controlsGroupCtrl SQD_NAME_EDIT_IDC;
    _squadNameEdit ctrlShow false;
    _squadNameEdit ctrlRemoveAllEventHandlers "KeyDown";
    _squadNameEdit ctrlRemoveAllEventHandlers "KillFocus";

    private _squadCountText = _squadBar controlsGroupCtrl SQD_COUNT_IDC;
    _squadCountText ctrlSetText format ["%1/%2", _playerCount, SQD_MAX_SQUAD_SIZE];

    private _squadBarButton = _squadBar controlsGroupCtrl SQD_JOIN_IDC;
    private _lockedText = _squadBar controlsGroupCtrl SQD_LOCKED_IDC;

    _squadBarButton ctrlRemoveAllEventHandlers "ButtonClick";

    switch (true) do {
        case (_isPlayerSquad): {
            private _squadBarButtonText = ["LEAVE", SQD_LAYOUT_BUTTON_TEXT_SIZE, SQD_COLOR_TEXT, "center"] call SQD_fnc_renderText;
            _squadBarButton ctrlSetStructuredText _squadBarButtonText;

            _squadBarButton ctrlAddEventHandler ["ButtonClick", {
                params ["_button"];
                ["leave", []] spawn SQD_fnc_client;

                private _display = ctrlParent _button;
                private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
                ctrlSetFocus _dummyButton;
            }];

            _lockedText ctrlShow false;
            _squadBarButton ctrlShow true;
        };

        case (_locked): {
            _lockedText ctrlSetText "LOCKED";

            _lockedText ctrlShow true;
            _squadBarButton ctrlShow false;
        };

        case (_playerCount >= SQD_MAX_SQUAD_SIZE): {
            _lockedText ctrlSetText "FULL";

            _lockedText ctrlShow true;
            _squadBarButton ctrlShow false;
        };

        default {
            private _squadBarButtonText = ["JOIN", SQD_LAYOUT_BUTTON_TEXT_SIZE, SQD_COLOR_TEXT, "center"] call SQD_fnc_renderText;
            _squadBarButton ctrlSetStructuredText _squadBarButtonText;

            _squadBarButton setVariable ["SQD_squadLeader", _squadLeader];

            _squadBarButton ctrlAddEventHandler ["ButtonClick", {
                params ["_button"];

                private _squadLeader = _button getVariable ["SQD_squadLeader", ""];
                if (_squadLeader == "") exitWith {};

                ["join", [_squadLeader]] spawn SQD_fnc_client;

                private _display = ctrlParent _button;
                private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
                ctrlSetFocus _dummyButton;
            }];

            _lockedText ctrlShow false;
            _squadBarButton ctrlShow true;
        };
    };

    private _sortedMembers = [_members, [_squadLeader], {
        if (_x == _input0) then {
            -1
        } else {
            1
        };
    }, "ASCEND"] call BIS_fnc_sortBy;

    private _playerSlots = _squadEntry getOrDefault ["playerSlots", createHashMap];
    private _seenMembers = createHashMap;

    {
        private _member = _x;
        _seenMembers set [_member, true];

        private _column = _forEachIndex % SQD_LAYOUT_SQUAD_COLUMNS;
        private _row = floor (_forEachIndex / SQD_LAYOUT_SQUAD_COLUMNS);

        private _playerSlot = _playerSlots getOrDefault [_member, controlNull];

        if (isNull _playerSlot) then {
            _playerSlot = _display ctrlCreate ["SQD_Menu_SquadBar_Player", -1, _squadBar];
            _playerSlots set [_member, _playerSlot];
        };

        _playerSlot ctrlSetPosition [
            SQD_LAYOUT_GRID_BORDER + (_squadSlotStepX * _column),
            SQD_LAYOUT_HEADER_H + SQD_LAYOUT_GRID_BORDER + (_squadSlotStepY * _row),
            _squadSlotW,
            _squadSlotInnerH
        ];

        private _player = ["getPlayerForID", [_member]] call SQD_fnc_query;

        private _playerNameText = _playerSlot controlsGroupCtrl SQD_PLAYER_NAME_IDC;

        private _playerNameColor = if (_isPlayerSquad) then {
            if (_member == _playerId) then {
                SQD_COLOR_PLAYER
            } else {
                SQD_COLOR_SQUADMATE
            };
        } else {
            _teamTextColor
        };

        private _playerNameTextStructured = [name _player, SQD_LAYOUT_LABEL_TEXT_SIZE, _playerNameColor, "left"] call SQD_fnc_renderText;
        _playerNameText ctrlSetStructuredText _playerNameTextStructured;

        private _playerScore = _playerContributions getOrDefault [getPlayerUID _player, 0];
        _playerNameText ctrlSetTooltip format ["Score: %1", _playerScore];

        private _badgeIconCtrl = _playerSlot controlsGroupCtrl SQD_BADGE_ICON_IDC;
        _badgeIconCtrl ctrlSetText "";

        private _playerBadge = _player getVariable ["WL2_currentBadge", "Player"];

        if (_playerBadge in _badgeConfigs) then {
            private _badgeConfig = _badgeConfigs getOrDefault [_playerBadge, []];
            _badgeConfig params ["_badgeIcon", "_badgeLevel"];

            _badgeIconCtrl ctrlSetText _badgeIcon;
        };

        private _badgeButton = _playerSlot controlsGroupCtrl SQD_BADGE_BUTTON_IDC;
        _badgeButton setVariable ["SQD_player", _player];
        _badgeButton ctrlRemoveAllEventHandlers "ButtonClick";
        if (!isNull _player) then {
            _badgeButton ctrlAddEventHandler ["ButtonClick", SQD_fnc_contextBadge];
        };

        private _squadLeaderIcon = _playerSlot controlsGroupCtrl SQD_SQUAD_LEADER_ICON_IDC;
        private _baseNamePosition = _playerNameText getVariable [
            "SQD_baseNamePosition",
            ctrlPosition _playerNameText
        ];

        _playerNameText setVariable ["SQD_baseNamePosition", _baseNamePosition];

        if (_member == _squadLeader) then {
            _squadLeaderIcon ctrlShow true;

            _playerNameText ctrlSetPosition [
                (_baseNamePosition # 0) + SQD_LAYOUT_SQUAD_LEADER_NAME_OFFSET_X,
                _baseNamePosition # 1,
                (_baseNamePosition # 2) - SQD_LAYOUT_SQUAD_LEADER_NAME_OFFSET_X,
                _baseNamePosition # 3
            ];
        } else {
            _squadLeaderIcon ctrlShow false;
            _playerNameText ctrlSetPosition _baseNamePosition;
        };

        _playerNameText setVariable ["SQD_member", _player];

        _playerNameText ctrlRemoveAllEventHandlers "ButtonClick";

        if (_isPlayerThisSquadLeader) then {
            _playerNameText ctrlAddEventHandler ["ButtonClick", SQD_fnc_contextPlayer];
        };

        _playerNameText ctrlCommit 0;
        _playerSlot ctrlCommit 0;
    } forEach _sortedMembers;

    {
        private _memberId = _x;
        private _staleSlot = _y;

        if (_memberId in _seenMembers) then {
            continue;
        };

        if (!isNull _staleSlot) then {
            ctrlDelete _staleSlot;
        };

        _playerSlots deleteAt _memberId;
    } forEach _playerSlots;

    _squadEntry set ["playerSlots", _playerSlots];
    _squadControls set [_squadKey, _squadEntry];

    _squadListY = _squadListY + _squadBarH + SQD_LAYOUT_SECTION_GAP_Y;
} forEach _squadsForMenu;

{
    private _squadKey = _x;
    private _squadEntry = _y;

    if (_squadKey in _seenSquadKeys) then {
        continue;
    };

    private _squadBar = _squadEntry getOrDefault ["bar", controlNull];
    if (!isNull _squadBar) then {
        ctrlDelete _squadBar;
    };

    _squadControls deleteAt _squadKey;
} forEach _squadControls;

_display setVariable ["SQD_squadControls", _squadControls];