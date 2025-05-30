#include "..\..\warlords_constants.inc"

BIS_WL_highlightedSector = objNull;
BIS_WL_hoverSamplePlayed = false;
WL_SectorActionTarget = objNull;

((ctrlParent WL_CONTROL_MAP) getVariable "BIS_sectorInfoBox") ctrlShow false;
((ctrlParent WL_CONTROL_MAP) getVariable "BIS_sectorInfoBox") ctrlEnable false;

call WL2_fnc_updateSelectionState;