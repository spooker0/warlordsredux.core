#include "includes.inc"
// Ongoing checks for sector target
0 spawn {
    private _lastTargetFriendly = objNull;
    private _lastTargetEnemy = objNull;
    private _lastTargetReset = false;

    private _display = uiNamespace getVariable ["RscWLHintMenu", displayNull];
    if (isNull _display) then {
        "hintLayer" cutRsc ["RscWLHintMenu", "PLAIN", -1, true, true];
        _display = uiNamespace getVariable "RscWLHintMenu";
    };
    private _texture = _display displayCtrl 5502;

    while { !BIS_WL_missionEnd } do {
        if (!(BIS_WL_playerSide in BIS_WL_competingSides) || WL_IsSpectator) exitWith {
            WL_VotePhase = 0;
            _texture ctrlWebBrowserAction ["ExecJS", "hideSectorVote();"];
        };

        private _targetReset = missionNamespace getVariable [format ["WL_targetReset_%1", BIS_WL_playerSide], false];
        if (isNull WL_TARGET_FRIENDLY || _targetReset) then {
            private _mostVotedVar = format ["BIS_WL_mostVoted_%1", BIS_WL_playerSide];
            private _voteTallyDisplayVar = format ["BIS_WL_sectorVoteTallyDisplay_%1", BIS_WL_playerSide];
            private _sortedVoteList = missionNamespace getVariable [_voteTallyDisplayVar, []];
            private _mostVoted = missionNamespace getVariable [_mostVotedVar, []];

            private _eta = if (count _mostVoted > 0) then {
                round (_mostVoted # 1 - serverTime);
            } else {
                -1;
            };
            private _etaDisplay = if (_eta >= 0) then {
                format ["TIME LEFT: %1", _eta];
            } else {
                "WAITING...";
            };

            private _captureSectors = _sortedVoteList apply {
                private _vote = _x # 0;
                private _voteCount = _x # 1;

                private _sectorName = _vote getVariable ["WL2_name", "Sector"];
                private _isSectorRevealed = BIS_WL_playerSide in (_vote getVariable ["BIS_WL_revealedBy", []]);

                private _owner = if (_isSectorRevealed) then {
                    private _sectorOwner = _vote getVariable ["BIS_WL_owner", independent];
                    ["BLUFOR", "OPFOR", "INDEP"] # ([west, east, independent] find _sectorOwner);
                } else {
                    "UNKNOWN";
                };
                [_sectorName, _voteCount, _owner]
            };

            private _script = format ["updateSectorVote(""%1"", %2);", _etaDisplay, toJSON _captureSectors];
            _texture ctrlWebBrowserAction ["ExecJS", _script];

            private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
            private _voteVolume = _settingsMap getOrDefault ["voteVolume", 1];
            if (_voteVolume > 0) then {
                if (_eta <= 10 && _eta >= 0) then {
                    private _volume = 6 - (_eta / 2);
                    playSoundUI ["a3\ui_f\data\sound\readout\readouthideclick1.wss", _volume * _voteVolume];
                };
            };
        };

        if (_lastTargetFriendly != WL_TARGET_FRIENDLY || _targetReset != _lastTargetReset) then {
            ["client"] call WL2_fnc_updateSectorArrays;

            if (!isNull WL_TARGET_FRIENDLY && !_targetReset) then {
                _texture ctrlWebBrowserAction ["ExecJS", "hideSectorVote();"];
                "Selected" call WL2_fnc_announcer;
                [toUpper format [localize "STR_A3_WL_popup_voting_done", WL_TARGET_FRIENDLY getVariable "WL2_name"]] spawn WL2_fnc_smoothText;
            };
        };

        if (_lastTargetEnemy != WL_TARGET_ENEMY) then {
            private _enemySectorKnowers = _lastTargetEnemy getVariable ["BIS_WL_revealedBy", []];
            if (BIS_WL_playerSide in _enemySectorKnowers) then {
                systemChat "Enemy target sector changed.";
            };
        };

        _lastTargetFriendly = WL_TARGET_FRIENDLY;
        _lastTargetEnemy = WL_TARGET_ENEMY;
        _lastTargetReset = _targetReset;
        uiSleep 1;
    };
};

// Checks for voting phase
while { !BIS_WL_missionEnd } do {
    if (!(BIS_WL_playerSide in BIS_WL_competingSides) || WL_IsSpectator) exitWith {
        WL_VotePhase = 0;
    };

    private _isTargetReset = missionNamespace getVariable [format ["WL_targetReset_%1", BIS_WL_playerSide], false];
    private _isVoting = isNull WL_TARGET_FRIENDLY || _isTargetReset;
    private _isVoted = !isNull BIS_WL_targetVote;
    private _isRegularSquadMember = ["isRegularSquadMember", [getPlayerID player]] call SQD_fnc_client;

    private _newPhase = if (_isRegularSquadMember || !_isVoting) then {
        0
    } else {
        if (!_isVoted) then {
            1
        } else {
            2
        };
    };

    if (WL_VotePhase != _newPhase) then {
        WL_VotePhase = _newPhase;

        ["client"] call WL2_fnc_updateSectorArrays;
        switch (WL_VotePhase) do {
            // Stopped voting
            case 0: {
                BIS_WL_targetVote = objNull;
                // missionNamespace setVariable [format ["BIS_WL_targetVote_%1", getPlayerID player], objNull, 2];
                private _currentOwner = WL_TARGET_FRIENDLY getVariable ["BIS_WL_owner", independent];
                [WL_TARGET_FRIENDLY, _currentOwner] call WL2_fnc_sectorMarkerUpdate;
            };
            // Started voting
            case 1: {
                if (_isTargetReset) then {
                    "Reset" call WL2_fnc_announcer;

                    private _enemySectorPreviousOwners = WL_TARGET_ENEMY getVariable ["BIS_WL_previousOwners", []];
                    if !(BIS_WL_playerSide in _enemySectorPreviousOwners) then {
                        "BIS_WL_targetEnemy" setMarkerAlphaLocal 0;
                    };
                } else {
                    "Voting" call WL2_fnc_announcer;
                    [toUpper localize "STR_A3_WL_popup_voting"] spawn WL2_fnc_smoothText;
                };
            };
            // Voted
            case 2: {};
        };
    };

    uiSleep WL_TIMEOUT_SHORT;
};