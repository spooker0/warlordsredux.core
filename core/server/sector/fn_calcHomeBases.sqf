#include "..\..\warlords_constants.inc"

params [["_overrideFirstBase", objNull]];

private _canBeBase = {
    params ["_sector"];
#if WL_AIRPORT_BASES
    "A" in (_sector getVariable ["WL2_services", []]);
#else
    _sector getVariable ["WL2_canBeBase", true];
#endif
};

// Eliminate last bases
// _potBases = _potBases - (profileNamespace getVariable ["BIS_WL_lastBases", []]);

private _firstBase = if (isNull _overrideFirstBase) then {
    selectRandom (BIS_WL_allSectors select {
        [_x] call _canBeBase;
    })
} else {
    _overrideFirstBase
};
private _baseMap = createHashMap;
{
    _baseMap set [hashValue _x, true];
} forEach BIS_WL_allSectors;

private _basesToRemove = createHashMapFromArray [
    [hashValue _firstBase, _firstBase]
];

private _iterations = 0;
private _maxIterations = getMissionConfigValue ["WL2_MinBaseDistance", 6];
while { _iterations <= _maxIterations } do {
    private _nextBasesToRemove = createHashMap;
    {
        private _neighbors = _y getVariable ["WL2_connectedSectors", []];
        {
            private _neighbor = hashValue _x;
            if  (_baseMap getOrDefault [_neighbor, false]) then {
                _nextBasesToRemove set [_neighbor, _x];
            };
        } forEach _neighbors;
        _baseMap set [_x, false];
    } forEach _basesToRemove;

    private _hasRemaining = false;
    {
        if (_y && {!(_x in _nextBasesToRemove)}) then {
            _hasRemaining = true;
            break;
        };
    } forEach _baseMap;
    if (!_hasRemaining) then {
        break;
    };

    _basesToRemove = _nextBasesToRemove;
    _iterations = _iterations + 1;
};

private _finalPot = BIS_WL_allSectors select {
    _baseMap getOrDefault [hashValue _x, false] &&
    [_x] call _canBeBase;
};

// diag_log format ["Iterations: %1, Final bases: %2", _iterations, _potBases apply { _x getVariable ["WL2_name", ""] }];

private _secondBase = selectRandom _finalPot;

if (random 1 > 0.5) then {
    [_firstBase, _secondBase, _finalPot]
} else {
    [_secondBase, _firstBase, _finalPot]
};