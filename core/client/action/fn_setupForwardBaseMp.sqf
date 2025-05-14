#include "..\..\warlords_constants.inc"

params ["_forwardBase", "_startTime", "_endTime", "_side"];

_forwardBase setVariable ["WL2_canDemolish", true];
_forwardBase animateSource ["Terminal_source", 100, true];
_forwardBase setVariable ["WL2_forwardBaseOwner", _side];

private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
_currentForwardBases pushBack _forwardBase;
_currentForwardBases = _currentForwardBases select {
    alive _x;
};
missionNamespace setVariable ["WL2_forwardBases", _currentForwardBases];

_forwardBase setVariable ["WL2_forwardBaseTime", _endTime];
_forwardBase setVariable ["WL_spawnedAsset", true];
_forwardBase setVariable ["WL2_forwardBaseSupplies", -1];

waitUntil {
    sleep 1;
    if (isServer) then {
        private _timeRemaining = _endTime - serverTime;
        private _totalTime = _endTime - _startTime;
        private _progress = 1 - (_timeRemaining / _totalTime);
        _forwardBase animateSource ["Progress_source", _progress * 100, true];
    };
    serverTime >= _endTime || !alive _forwardBase
};

_forwardBase setVariable ["WL2_forwardBaseSupplies", 2000];

private _sectorsInRange = BIS_WL_allSectors select {
    _x distance2D _forwardBase < WL_FOB_CAPTURE_RANGE
};
_forwardBase setVariable ["WL2_forwardBaseSectors", _sectorsInRange];