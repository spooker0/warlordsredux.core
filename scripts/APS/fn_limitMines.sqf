#include "includes.inc"
params ["_projectile", "_isExplosive"];

private _ownedMineVar = if (_isExplosive) then {
    format ["WL2_ownedExplosives_%1", getPlayerUID player]
} else {
    format ["WL2_ownedMines_%1", getPlayerUID player]
};

private _maxAmount = if (_isExplosive) then {
    WL_MAX_EXPLOSIVES
} else {
    WL_MAX_MINES
};

private _allOwnedMines = missionNamespace getVariable [_ownedMineVar, []];
_allOwnedMines = _allOwnedMines select { alive _x };

private _currentCount = count _allOwnedMines;
if (_currentCount >= _maxAmount) then {
    private _overflowAmount = _currentCount - _maxAmount + 1;
    private _overflowMines = _allOwnedMines select [0, _overflowAmount];
    {
        private _oldestMine = _x;
        private _oldestMineDefaultMag = getText (configFile >> "CfgAmmo" >> typeOf _oldestMine >> "defaultMagazine");
        private _oldestMineType = getText (configFile >> "CfgMagazines" >> _oldestMineDefaultMag >> "displayName");

        if (_oldestMineType == "") then {
            _oldestMineType = "Deployed Mine";
        };

        [format ["Maximum of %1 deployed explosives reached. Removing oldest %2", _maxAmount, _oldestMineType]] call WL2_fnc_smoothText;

        deleteVehicle _x;
    } forEach _overflowMines;
};

BIS_WL_playerSide revealMine _projectile;

_allOwnedMines pushBack _projectile;
_allOwnedMines = _allOwnedMines select { alive _x };
missionNamespace setVariable [_ownedMineVar, _allOwnedMines, true];