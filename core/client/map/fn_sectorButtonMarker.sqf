params ["_sector", "_side"];

private _sectorMarker = _sector getVariable [format ["WL2_MapMarker_%1", _side], "unknown"];

private _sectorSide = switch (_sectorMarker) do {
    case "unknown": { "NONE" };
    case "enemy": { "ENEMY" };
    case "enemyhome": { "ENEMY BASE" };
    case "green": { "INDEPENDENT" };
    case "attack": { "ATTACK" };
    case "attack2": { "ATTACK 2" };
    case "camped": { "CAMPED" };
    default { "NONE" };
};

private _enemyColor = if (BIS_WL_playerSide == west) then {
    "#800000";
} else {
    "#004C99";
};

private _sectorColor = switch (_sectorMarker) do {
    case "unknown": { "#FFFFFF" };
    case "enemy": { _enemyColor };
    case "enemyhome": { _enemyColor };
    case "green": { "#008000" };
    case "attack": { "#FFFFFF" };
    case "attack2": { "#CCCCCC" };
    case "camped": { "#FF0000" };
    default { "#FFFFFF" };
};

private _text = format ["MARK SECTOR: <t color='%1'>%2</t>", _sectorColor, _sectorSide];
[_text, _sectorSide]