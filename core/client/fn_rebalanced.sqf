#include "includes.inc"
params ["_rebalancedPlayer", "_newSide"];
if (player != _rebalancedPlayer) exitWith {};

setPlayerRespawnTime 5;
forceRespawn player;

private _lockTeamName = if (_newSide == west) then { "BLUFOR" } else { "OPFOR" };
private _message = format ["You have been rebalanced to %1.", _lockTeamName];
[_message] call WL2_fnc_smoothText;

waitUntil {
    alive player || isNull player;
};

BIS_WL_playerSide = _newSide;
BIS_WL_enemySide = (BIS_WL_competingSides - [_newSide]) # 0;

call WL2_fnc_updateSectorsData;
{
	[_x, _x getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
} forEach BIS_WL_allSectors;
call WL2_fnc_drawTargetMarker;

BIS_WL_colorFriendly = BIS_WL_colorsArray # (BIS_WL_sidesArray find BIS_WL_playerSide);
WL_MoneySign = [BIS_WL_playerSide] call WL2_fnc_getMoneySign;

missionNamespace setVariable ["WL2_prevSectorFriendly", objNull];
missionNamespace setVariable ["WL2_prevSectorEnemy", objNull];
private _friendlyTargetMarker = "BIS_WL_targetFriendly";
private _enemyTargetMarker = "BIS_WL_targetEnemy";
{
    _x setMarkerAlphaLocal 0;
} forEach [_friendlyTargetMarker, _enemyTargetMarker];

WL_VotePhase = -1;
["leave", []] spawn SQD_fnc_client;