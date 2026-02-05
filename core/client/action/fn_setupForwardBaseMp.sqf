#include "includes.inc"
params ["_forwardBase", "_side"];

waitUntil {
    uiSleep 1;
    !isNil "BIS_WL_allSectors";
};

_forwardBase setVariable ["WL2_canDemolish", true];
_forwardBase setVariable ["WL2_forwardBaseOwner", _side];
_forwardBase setVariable ["WL2_mapCircleRadius", WL_FOB_MIN_DISTANCE];

private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
_currentForwardBases pushBack _forwardBase;
_currentForwardBases = _currentForwardBases select {
    alive _x;
};
missionNamespace setVariable ["WL2_forwardBases", _currentForwardBases];

_forwardBase setVariable ["WL_spawnedAsset", true];
_forwardBase setVariable ["BIS_WL_ownerAssetSide", _side];