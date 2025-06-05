#include "includes.inc"
params ["_sectorMarkerPair", "_drawSide"];
private _sector = _sectorMarkerPair # 0;
private _marker = _sectorMarkerPair # 1;

private _sectorMarker = _marker # 1;

private _sectorIcon = switch (_sectorMarker) do {
    case "ENEMY": {
        private _sectorServices = _sector getVariable ["WL2_services", []];
        if ("A" in _sectorServices) then {
            "\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa"
        } else {
            if ("H" in _sectorServices) then {
                "\a3\ui_f\data\igui\cfg\simpletasks\types\Heli_ca.paa"
            } else {
                "\A3\ui_f\data\map\markers\handdrawn\flag_CA.paa"
            };
        };
    };
    case "INDEPENDENT": { "\A3\ui_f\data\map\markers\handdrawn\flag_CA.paa" };
    case "ENEMY BASE": { "\A3\ui_f_orange\data\cfgmarkers\redcrystal_ca.paa" };
    case "ATTACK";
    case "ATTACK 2": { "\a3\ui_f\data\igui\cfg\simpletasks\types\attack_ca.paa" };
    case "CAMPED": { "\A3\ui_f\data\map\markers\handdrawn\warning_CA.paa" };
    default { "" };
};

private _sectorColorRGB = switch (_sectorMarker) do {
    case "ENEMY";
    case "ENEMY BASE": {
        if (_drawSide == west) then {
            [0.5, 0, 0, 1]
        } else {
            [0, 0.3, 0.6, 1]
        }
    };
    case "INDEPENDENT": { [0, 0.5, 0, 1] };
    case "ATTACK": { [1, 1, 1, 1] };
    case "ATTACK 2": { [0.1, 0.1, 0.1, 1] };
    case "CAMPED": { [1, 0, 0, 1] };
    default { [1, 1, 1] };
};

private _sectorPosition = getPosASL _sector;
_sectorPosition set [1, (_sectorPosition # 1) + 50];

private _sectorMarkedByVar = format ["WL2_MapMarkedBy_%1", _drawSide];
private _sectorMarkedBy = _sector getVariable [_sectorMarkedByVar, ""];
private _sectorMarkedTimeVar = format ["WL2_MapMarkedTime_%1", _drawSide];
private _sectorMarkedTime = _sector getVariable [_sectorMarkedTimeVar, ""];

[
    _sectorIcon,
    _sectorColorRGB,
    _sectorPosition,
    32,
    32,
    0,
    if (_drawSectorMarkerText) then {
        format ["%1 (Marked by %2 %3)", _sectorMarker, _sectorMarkedBy, _sectorMarkedTime]
    } else {""},
    true,
    0.04,
    "PuristaBold",
    "right"
];