#include "includes.inc"
private _target = WL_TARGET_FRIENDLY;
private _revealedBy = _target getVariable ["BIS_WL_revealedBy", []];
if !(BIS_WL_playerSide in _revealedBy) exitWith {
    [false, "Cannot air assault into unknown sector. Scout the area first."];
};

if (_target in WL_BASES) then {
    [false, localize "STR_A3_WL_fasttravel_restr1"];
} else {
    [true, ""];
};