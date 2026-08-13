#include "includes.inc"
private _playerSide = BIS_WL_playerSide;
private _friendlyTargetMarker = "BIS_WL_targetFriendly";
private _enemyTargetMarker = "BIS_WL_targetEnemy";

private _friendlyColor = if (_playerSide == west) then { "colorBLUFOR" } else { "colorOPFOR" };
private _enemyColor = if (_playerSide == west) then { "colorOPFOR" } else { "colorBLUFOR" };

_friendlyTargetMarker setMarkerColorLocal _friendlyColor;
_enemyTargetMarker setMarkerColorLocal _enemyColor;

{
	_x setMarkerSizeLocal [2, 2];
	_x setMarkerTypeLocal "selector_selectedMission";
} forEach [_friendlyTargetMarker, _enemyTargetMarker];