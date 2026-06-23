#include "includes.inc"

private _playerId = getPlayerID player;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

private _lastTargetFriendly = objNull;
private _lastTargetEnemy = objNull;
private _lastTargetReset = false;
private _lastSoundTime = -1;

private _playerSide = BIS_WL_playerSide;
private _targetResetVar = format ["WL_targetReset_%1", _playerSide];
private _voteEndVariable = format ["WL2_voteEnd_%1", _playerSide];
private _voteTallyDisplayVariable = format ["BIS_WL_sectorVoteTallyDisplay_%1", _playerSide];

while { !BIS_WL_missionEnd } do {
    if !(_playerSide in BIS_WL_competingSides) exitWith {};

    private _targetReset = missionNamespace getVariable [_targetResetVar, false];

    private _isVoting = isNull WL_TARGET_FRIENDLY || _targetReset;
    private _isVoted = !isNull BIS_WL_targetVote;
    private _isRegularSquadMember = ["isRegularSquadMember", [_playerId]] call SQD_fnc_query;

    private _newPhase = if (_isRegularSquadMember || !_isVoting) then {
        0
    } else {
        if (!_isVoted) then { 1 } else { 2 };
    };

    if (WL_VotePhase != _newPhase) then {
        WL_VotePhase = _newPhase;

        ["client"] call WL2_fnc_updateSectorArrays;

        switch (WL_VotePhase) do {
            // Stopped voting
            case 0: {
                BIS_WL_targetVote = objNull;

                if (!isNull WL_TARGET_FRIENDLY) then {
                    private _currentOwner = WL_TARGET_FRIENDLY getVariable ["BIS_WL_owner", independent];
                    [WL_TARGET_FRIENDLY, _currentOwner] call WL2_fnc_sectorMarkerUpdate;
                };

                {
                    private _sector = _x;
                    _sector setVariable ["WL2_sectorSelectionAvailable", false];
                } forEach BIS_WL_allSectors;
            };

            // Started voting
            case 1: {
                if (_targetReset) then {
                    "Reset" call WL2_fnc_announcer;

                    private _enemySectorPreviousOwners = WL_TARGET_ENEMY getVariable ["BIS_WL_previousOwners", []];

                    if !(_playerSide in _enemySectorPreviousOwners) then {
                        "BIS_WL_targetEnemy" setMarkerAlphaLocal 0;
                    };
                } else {
                    "Voting" call WL2_fnc_announcer;
                    [localize "STR_A3_WL_popup_voting"] call WL2_fnc_smoothText;
                };
            };

            // Voted
            case 2: {};
        };
    };

    if (WL_VotePhase != 0) then {
        private _eligibleSectors = BIS_WL_sectorsArray # 1;

        {
            private _sector = _x;
            _sector setVariable ["WL2_sectorSelectionAvailable", _sector in _eligibleSectors];
        } forEach BIS_WL_allSectors;
    };

    private _sectorsBeingCaptured = [];
    private _showAllSectors = _playerSide == independent || WL_IsSpectator || WL_IsReplaying;

    {
        if (_x getVariable ["BIS_WL_captureProgress", 0] <= 0) then {
            _x setVariable ["WL2_lastCaptureProgress", 0];
            _x setVariable ["WL2_lastCaptureProgressDirection", ""];
            continue;
        };

        private _revealedSides = _x getVariable ["BIS_WL_revealedBy", []];
        if (_playerSide in _revealedSides) then {
            _sectorsBeingCaptured pushBack _x;
            continue;
        };

        if (_showAllSectors) then {
            _sectorsBeingCaptured pushBack _x;
        };
    } forEach BIS_WL_allSectors;

    private _sectorCaptureList = _sectorsBeingCaptured apply {
        private _sector = _x;

        private _sectorName = _sector getVariable ["WL2_name", "Sector"];
        private _sectorOwner = _sector getVariable ["BIS_WL_owner", independent];
        private _sectorReinforcements = if (_sectorOwner == independent) then {
            _sector getVariable ["WL2_sectorPop", 0];
        } else {
            _sector getVariable ["WL2_defenders", 0];
        };
        private _sectorNameDisplay = format ["%1 (%2)", _sectorName, _sectorReinforcements];

        private _captureProgress = _sector getVariable ["BIS_WL_captureProgress", 0];
        private _captureProgressPercent = round (_captureProgress * 1000) / 10;

        private _lastCaptureProgress = _sector getVariable ["WL2_lastCaptureProgress", _captureProgress];
        private _lastCaptureProgressDirection = _sector getVariable ["WL2_lastCaptureProgressDirection", ""];

        private _captureProgressDelta = _captureProgress - _lastCaptureProgress;
        private _captureProgressDirection = _lastCaptureProgressDirection;

        if (_captureProgressDelta > 0) then {
            _captureProgressDirection = switch (true) do {
                case (_captureProgressDelta > 0.01): { "&gt;&gt;&gt;" };
                case (_captureProgressDelta > 0.005): { "&gt;&gt;" };
                default { "&gt;" };
            };
        };

        if (_captureProgressDelta < 0) then {
            _captureProgressDirection = switch (true) do {
                case (_captureProgressDelta < -0.01): { "&lt;&lt;&lt;" };
                case (_captureProgressDelta < -0.005): { "&lt;&lt;" };
                default { "&lt;" };
            };
        };

        _sector setVariable ["WL2_lastCaptureProgress", _captureProgress];
        _sector setVariable ["WL2_lastCaptureProgressDirection", _captureProgressDirection];

        private _captureProgressDirectionSide = if (_captureProgressDirection find "&lt;" >= 0) then {
            "left"
        } else {
            if (_captureProgressDirection find "&gt;" >= 0) then {
                "right"
            } else {
                ""
            };
        };

        private _captureProgressDisplay = format ["%1%%", round _captureProgressPercent];

        private _capturingTeam = _sector getVariable ["BIS_WL_capturingTeam", independent];
        private _defendingTeam = _sector getVariable ["BIS_WL_owner", independent];

        private _captureDetails = _sector getVariable ["WL_captureDetails", []];

        private _capturingTeamDetails = _captureDetails select {
            _x # 0 == _capturingTeam
        };

        private _defendingTeamDetails = _captureDetails select {
            _x # 0 == _defendingTeam
        };

        private _capturingTeamCap = if (count _capturingTeamDetails > 0) then {
            (_capturingTeamDetails # 0) # 1
        } else {
            0
        };

        private _defendingTeamCap = if (count _defendingTeamDetails > 0) then {
            (_defendingTeamDetails # 0) # 1
        } else {
            0
        };

        [
            _sectorNameDisplay,
            _capturingTeamCap,
            _defendingTeamCap,
            _captureProgressPercent,
            _captureProgressDisplay,
            _captureProgressDirection,
            _captureProgressDirectionSide,
            _capturingTeam,
            _defendingTeam
        ]
    };

    private _shouldShowVote = isNull WL_TARGET_FRIENDLY || _targetReset;
    private _shouldShowCapture = count _sectorCaptureList > 0;

    if (_shouldShowVote || _shouldShowCapture) then {
        private _display = uiNamespace getVariable ["RscWLSectorDisplay", displayNull];

        if (isNull _display) then {
            "vote" cutRsc ["RscWLSectorDisplay", "PLAIN", -1, true, true];
            _display = uiNamespace getVariable ["RscWLSectorDisplay", displayNull];
        };

        if (!isNull _display) then {
            private _captureSectionHeight = [_display, _sectorCaptureList, _shouldShowVote] call WL2_fnc_renderCaptureDisplay;

            if (_shouldShowVote) then {
                private _titleControl = _display displayCtrl 4002;

                private _voteEndTime = missionNamespace getVariable [_voteEndVariable, -1];
                private _sortedVoteList = missionNamespace getVariable [_voteTallyDisplayVariable, []];

                private _eta = if (count _sortedVoteList > 0) then {
                    _voteEndTime - serverTime
                } else {
                    -1
                };

                private _etaDisplay = if (_eta >= 0) then {
                    format ["TIME LEFT: %1", _eta toFixed 1]
                } else {
                    "WAITING..."
                };

                if (!isNull _titleControl) then {
                    _titleControl ctrlSetStructuredText parseText format [
                        "<t align='center'>VOTE IN PROGRESS</t><br/><t align='center' size='0.8'>%1</t>",
                        _etaDisplay
                    ];
                };

                private _voteSectors = _sortedVoteList apply {
                    private _vote = _x # 0;
                    private _voteCount = _x # 1;

                    private _sectorName = _vote getVariable ["WL2_name", "Sector"];
                    private _isSectorRevealed = _playerSide in (_vote getVariable ["BIS_WL_revealedBy", []]);

                    private _ownerColor = if (_isSectorRevealed) then {
                        private _sectorOwner = _vote getVariable ["BIS_WL_owner", independent];

                        switch (_sectorOwner) do {
                            case west: { [0, 0.3, 0.6, 1] };
                            case east: { [0.5, 0, 0, 1] };
                            case independent: { [0, 0.5, 0, 1] };
                            default { [0.7, 0.6, 0, 1] };
                        };
                    } else {
                        [0.7, 0.6, 0, 1]
                    };

                    [_sectorName, _voteCount, _ownerColor]
                };

                [_display, _voteSectors, _captureSectionHeight, true] call WL2_fnc_renderVoteDisplay;

                private _voteVolume = _settingsMap getOrDefault ["voteVolume", 1];

                if (_voteVolume > 0) then {
                    private _now = diag_tickTime;

                    if (_eta <= 10 && _eta >= 0 && _now - _lastSoundTime >= 1) then {
                        private _volume = 6 - (_eta / 2);
                        playSoundUI ["a3\ui_f\data\sound\readout\readouthideclick1.wss", _volume * _voteVolume];
                        _lastSoundTime = _now;
                    };
                };
            } else {
                [_display, [], _captureSectionHeight, false] call WL2_fnc_renderVoteDisplay;
            };
        };
    } else {
        "vote" cutText ["", "PLAIN"];
    };

    if (_lastTargetFriendly isNotEqualTo WL_TARGET_FRIENDLY || _targetReset isNotEqualTo _lastTargetReset) then {
        ["client"] call WL2_fnc_updateSectorArrays;

        if (!isNull WL_TARGET_FRIENDLY && !_targetReset) then {
            if (count _sectorCaptureList == 0) then {
                "vote" cutText ["", "PLAIN"];
            };

            "Selected" call WL2_fnc_announcer;

            private _votedText = format [
                localize "STR_A3_WL_popup_voting_done",
                WL_TARGET_FRIENDLY getVariable ["WL2_name", "Sector"]
            ];

            [_votedText] call WL2_fnc_smoothText;
        };
    };

    if (_lastTargetEnemy isNotEqualTo WL_TARGET_ENEMY) then {
        if (!isNull _lastTargetEnemy) then {
            private _enemySectorKnowers = _lastTargetEnemy getVariable ["BIS_WL_revealedBy", []];

            if (_playerSide in _enemySectorKnowers) then {
                ["Enemy target sector changed."] call WL2_fnc_smoothText;
            };
        };
    };

    _lastTargetFriendly = WL_TARGET_FRIENDLY;
    _lastTargetEnemy = WL_TARGET_ENEMY;
    _lastTargetReset = _targetReset;

    sleep WL_TIMEOUT_MIN;
};

WL_VotePhase = 0;
"vote" cutText ["", "PLAIN"];

{
    private _sector = _x;
    _sector setVariable ["WL2_sectorSelectionAvailable", false];
} forEach BIS_WL_allSectors;