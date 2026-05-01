#include "includes.inc"
private _conditions = {
	params ["_sector", "_arguments"];
    if (isNull _sector) exitWith {
        false
    };

	if !(_sector in BIS_WL_sectorsArray # 1) exitWith {
        false
    };

    true;
};

private _successCallback = {
	params ["_sector", "_arguments"];
    BIS_WL_targetVote = _sector;
    BIS_WL_highlightedSector = _sector;
    private _targetVoteVar = format ["BIS_WL_targetVote_%1", getPlayerID player];
    missionNamespace setVariable [_targetVoteVar, _sector, 2];

    0 spawn {
        uiSleep 0.001;

        if (WL_VotePhase != 0) then {
            call WL2_fnc_requestVote;
        };
    };
};

private _cancelCallback = {
    BIS_WL_highlightedSector = objNull;
};

[
	"vote",
	_conditions,
	{},
	_successCallback,
	_cancelCallback,
	[],
    true
] spawn WL2_fnc_orderMapSelection;