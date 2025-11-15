#include "includes.inc"
params ["_sector", "_side"];

private _sectorMarker = _sector getVariable [format ["WL2_MapMarker_%1", _side], "unknown"];

private _sectorSide = switch (_sectorMarker) do {
    case "unknown": { "None" };
    case "enemy": { "Enemy" };
    case "enemyhome": { "Enemy base" };
    case "green": { "Independent" };
    case "attack": { "Attack" };
    case "attack2": { "Attack 2" };
    case "camped": { "Camped" };
    default { "None" };
};

private _enemyColor = if (BIS_WL_playerSide == west) then {
    "red";
} else {
    "blue";
};

private _sectorColorClass = switch (_sectorMarker) do {
    case "unknown": { "" };
    case "enemy": { _enemyColor };
    case "enemyhome": { _enemyColor };
    case "green": { "green" };
    case "attack": { "red" };
    case "attack2": { "red" };
    case "camped": { "red" };
    default { "" };
};

private _sectorText = format ["<span class='%1'>Mark sector: %2</span>", _sectorColorClass, _sectorSide];
[_sectorText, _sectorSide]