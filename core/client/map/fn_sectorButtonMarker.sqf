#include "includes.inc"
params ["_sector", "_side"];

private _sectorMarker = _sector getVariable [format ["WL2_MapMarker_%1", _side], "unknown"];

private _sectorSide = switch (_sectorMarker) do {
    case "unknown": { localize "STR_WL_none" };
    case "enemy": { localize "STR_WL_enemy" };
    case "enemyhome": { localize "STR_WL_enemyBase" };
    case "green": { localize "STR_WL_independent" };
    case "camped": { localize "STR_WL_camped" };
    default { localize "STR_WL_none" };
};

private _enemyColor = if (BIS_WL_playerSide == west) then {
    "#ff0000";
} else {
    "#0000ff";
};

private _sectorColorClass = switch (_sectorMarker) do {
    case "unknown": { "" };
    case "enemy": { _enemyColor };
    case "enemyhome": { _enemyColor };
    case "green": { "#00ff00" };
    case "camped": { "#ff0000" };
    default { "" };
};

private _sectorText = format ["<t color='%1'>%2: %3</t>", _sectorColorClass, localize "STR_WL_markSector", _sectorSide];
[_sectorText, _sectorMarker]