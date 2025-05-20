private _playersWest = allPlayers select { side group _x == west } select { !(_x getVariable ["WL2_afk", false]) };
private _playersEast = allPlayers select { side group _x == east } select { !(_x getVariable ["WL2_afk", false]) };
_playersWest = (count _playersWest) max 1;
_playersEast = (count _playersEast) max 1;
private _multiplier = _playersWest / (_playersWest + _playersEast) * 2;

private _incomeWest = round ((west call WL2_fnc_income) * (2 - _multiplier));
private _incomeEast = round ((east call WL2_fnc_income) * _multiplier);
missionNamespace setVariable ["WL2_actualIncome_west", _incomeWest max 50, true];
missionNamespace setVariable ["WL2_actualIncome_east", _incomeEast max 50, true];