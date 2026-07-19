#include "includes.inc"

private _teamSectorsData = WL_SECTORS_DATA(BIS_WL_playerSide);
private _voteableSectors = _teamSectorsData getOrDefault ["voteable", []];

if !(WL_TARGET_FRIENDLY in _voteableSectors) then {
    [false, localize "STR_A3_WL_fasttravel_restr5"];
} else {
    [true, ""];
};