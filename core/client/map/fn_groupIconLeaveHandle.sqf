#include "includes.inc"
params ["_is3D", "_group"];
BIS_WL_highlightedSector = objNull;
BIS_WL_hoverSamplePlayed = false;
WL_SectorActionTarget = objNull;
_group setVariable ["WL2_groupNextRenderTime", 0];
call WL2_fnc_updateSelectionState;