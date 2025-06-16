#include "includes.inc"
params ["_op"];

private _ret = 0;

if (isNil "WLC_ScoreTable") then {
    private _levelRequirements = [];
    for "_i" from 1 to 5 do {
        for "_j" from 1 to 10 do {
            _levelRequirements pushBack (_i * 1000);
        };
    };
    for "_i" from 1 to 50 do {  // 60-100
        _levelRequirements pushBack 5000;
    };
    for "_i" from 1 to 100 do { // 100-200
        _levelRequirements pushBack 100000;
    };
    for "_i" from 1 to 100 do { // 200-300
        _levelRequirements pushBack 1000000;
    };
    for "_i" from 1 to 100 do { // 300-400
        _levelRequirements pushBack 10000000;
    };
    for "_i" from 1 to 100 do { // 400-500
        _levelRequirements pushBack 100000000;
    };
    WLC_ScoreTable = _levelRequirements;
};

switch (_op) do {
    case "getScore": {
        _ret = profileNamespace getVariable ["WLC_Score", 0];
    };
    case "getLevel": {
        private _score = ["getScore"] call WLC_fnc_getLevelInfo;
        private _level = 0;
        while { _score > 0 } do {
            private _nextLevelReq = if (_level < count WLC_ScoreTable) then {
                WLC_ScoreTable # _level;
            } else {
                100000000;
            };
            _score = _score - _nextLevelReq;
            if (_score >= 0) then {
                _level = _level + 1;
            };
        };
        _ret = _level min 500;
    };
    case "getNextLevelScore": {
        private _level = ["getLevel"] call WLC_fnc_getLevelInfo;
        if (_level == 500) then {
            _ret = 0;
        } else {
            private _score = 0;
            for "_i" from 0 to _level do {
                private _nextLevelReq = if (_i < count WLC_ScoreTable) then {
                    WLC_ScoreTable # _i;
                } else {
                    100000000;
                };
                _score = _score + _nextLevelReq;
            };
            _ret = _score;
        };
    };
};

_ret;