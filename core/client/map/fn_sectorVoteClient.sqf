#include "includes.inc"
// Ongoing checks for sector target
0 spawn {
    private _lastTargetFriendly = objNull;
    private _lastTargetEnemy = objNull;
    private _lastTargetReset = false;
    while { !BIS_WL_missionEnd } do {
        if (!(BIS_WL_playerSide in BIS_WL_competingSides) || WL_IsSpectator) exitWith {
            WL_VotePhase = 0;
            private _voteDisplay = uiNamespace getVariable ["RscWLVoteDisplay", objNull];
            if (!isNull _voteDisplay) then {
                private _indicator = _voteDisplay displayCtrl 7002;
                private _indicatorBackground = _voteDisplay displayCtrl 7003;
                _indicator ctrlSetText "";
                _indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0];
            };
        };

        private _targetReset = missionNamespace getVariable [format ["WL_targetReset_%1", BIS_WL_playerSide], false];
        if (isNull WL_TARGET_FRIENDLY || _targetReset) then {
            call WL2_fnc_sectorVoteDisplay;
        };

        if (_lastTargetFriendly != WL_TARGET_FRIENDLY || _targetReset != _lastTargetReset) then {
            ["client"] call WL2_fnc_updateSectorArrays;

            if (!isNull WL_TARGET_FRIENDLY && !_targetReset) then {
                call WL2_fnc_refreshCurrentTargetData;
                private _voteDisplay = uiNamespace getVariable ["RscWLVoteDisplay", objNull];
                if (!isNull _voteDisplay) then {
                    private _indicator = _voteDisplay displayCtrl 7002;
                    private _indicatorBackground = _voteDisplay displayCtrl 7003;
                    _indicator ctrlSetText "";
                    _indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0];
                };

                "Selected" call WL2_fnc_announcer;
                [toUpper format [localize "STR_A3_WL_popup_voting_done", WL_TARGET_FRIENDLY getVariable "WL2_name"]] spawn WL2_fnc_smoothText;
            };
        };

        if (_lastTargetEnemy != WL_TARGET_ENEMY) then {
            private _enemySectorKnowers = _lastTargetEnemy getVariable ["BIS_WL_revealedBy", []];
            if (BIS_WL_playerSide in _enemySectorKnowers) then {
                systemChat "Enemy target sector reset.";
            };
        };

        _lastTargetFriendly = WL_TARGET_FRIENDLY;
        _lastTargetEnemy = WL_TARGET_ENEMY;
        _lastTargetReset = _targetReset;
        sleep 1;
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
                missionNamespace setVariable [format ["BIS_WL_targetVote_%1", getPlayerID player], objNull, 2];
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

                private _voteDisplay = uiNamespace getVariable ["RscWLVoteDisplay", objNull];
                if (isNull _voteDisplay) then {
                    "VoteDisplay" cutRsc ["RscWLVoteDisplay", "PLAIN", -1, true, true];
                    _voteDisplay = uiNamespace getVariable "RscWLVoteDisplay";
                };

                private _indicator = _voteDisplay displayCtrl 7002;
                private _indicatorBackground = _voteDisplay displayCtrl 7003;
                _indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0.7];
            };
            // Voted
            case 2: {};
        };
    };

    sleep WL_TIMEOUT_SHORT;
};