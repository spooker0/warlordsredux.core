#include "includes.inc"
params [["_overrideFirstBase", objNull]];

private _canBeBase = {
    params ["_sector"];
#if WL_AIRPORT_BASES
    "A" in (_sector getVariable ["WL2_services", []]);
#else
    _sector getVariable ["WL2_canBeBase", true];
#endif
};

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

private _lastViablePot = BIS_WL_allSectors select {
    _x != _firstBase &&
    [_x] call _canBeBase
};

private _iterations = 0;
private _maxIterations = WL_BASE_MINDISTANCE;
while { _iterations <= _maxIterations } do {
    private _nextBasesToRemove = createHashMap;
    {
        private _neighbors = _y getVariable ["WL2_connectedSectors", []];

        {
            private _neighbor = hashValue _x;

            if (_baseMap getOrDefault [_neighbor, false]) then {
                _nextBasesToRemove set [_neighbor, _x];
            };
        } forEach _neighbors;

        _baseMap set [_x, false];
    } forEach _basesToRemove;

    private _currentViablePot = BIS_WL_allSectors select {
        _x != _firstBase &&
        _baseMap getOrDefault [hashValue _x, false] &&
        [_x] call _canBeBase
    };

    if (count _currentViablePot == 0) then {
        break;
    };
    _lastViablePot = _currentViablePot;

    _basesToRemove = _nextBasesToRemove;
    _iterations = _iterations + 1;
};

private _finalPot = BIS_WL_allSectors select {
    _x != _firstBase &&
    _baseMap getOrDefault [hashValue _x, false] &&
    [_x] call _canBeBase
};

private _secondBase = if (count _finalPot == 0) then {
#if WL_BASE_SELECTION_DEBUG
    diag_log format [
        "No valid second base found for %1 at minimum distance %2. Falling back to last viable pot %3.",
        _firstBase getVariable ["WL2_name", ""],
        WL_BASE_MINDISTANCE,
        _lastViablePot apply { _x getVariable ["WL2_name", ""] }
    ];
#endif
    selectRandom _lastViablePot
} else {
    selectRandom _finalPot
};

if (random 1 > 0.5) then {
    [_firstBase, _secondBase, _finalPot]
} else {
    [_secondBase, _firstBase, _finalPot]
};