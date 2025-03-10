params ["_forwardBase", "_startTime", "_endTime", "_caller", "_upgrading"];

if (!_upgrading) then {
    [_forwardBase] call WL2_fnc_demolish;
    _forwardBase animateSource ["Terminal_source", 100, true];
    _forwardBase setVariable ["WL2_forwardBaseOwner", side group _caller];
    _forwardBase setVariable ["WL2_forwardBaseLevel", 0];

    private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
    _currentForwardBases pushBack _forwardBase;
    missionNamespace setVariable ["WL2_forwardBases", _currentForwardBases];
};

_forwardBase setVariable ["WL2_forwardBaseTime", _endTime];
_forwardBase setVariable ["WL_spawnedAsset", true];

playSound3D ["a3\data_f_curator\sound\cfgsounds\air_raid.wss", _forwardBase, false, getPosASL _forwardBase, 5, 0.375, 2500];

waitUntil {
    sleep 1;
    private _timeRemaining = _endTime - serverTime;
    private _totalTime = _endTime - _startTime;
    private _progress = 1 - (_timeRemaining / _totalTime);
    _forwardBase animateSource ["Progress_source", _progress * 100, true];
    serverTime >= _endTime || !alive _forwardBase
};

private _previousLevel = _forwardBase getVariable ["WL2_forwardBaseLevel", 0];
_forwardBase setVariable ["WL2_forwardBaseLevel", (_previousLevel + 1) min 3];