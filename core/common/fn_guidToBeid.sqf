#include "includes.inc"
params ["_uid"];

if (_uid isEqualTo "") exitWith { "" };
private _uidChars = toArray _uid;

if ((_uidChars findIf { _x < 48 || _x > 57 }) >= 0) exitWith { "" };

private _divMod256 = {
    params ["_value"];

    private _quotient = [];
    private _remainder = 0;
    private _started = false;

    {
        private _partialDividend = (_remainder * 10) + (_x - 48);
        private _digit = floor (_partialDividend / 256);
        _remainder = _partialDividend - (_digit * 256);

        if ((_digit > 0) || _started) then {
            _quotient pushBack (_digit + 48);
            _started = true;
        };
    } forEach (toArray _value);

    if (!_started) then {
        _quotient pushBack 48;
    };

    [toString _quotient, _remainder]
};

private _remainingUid = _uid;
private _uidBytes = [];

for "_byteIndex" from 0 to 7 do {
    private _result = [_remainingUid] call _divMod256;
    _remainingUid = _result # 0;
    _uidBytes pushBack (_result # 1);
};

private _messageBlock = [66, 69];
_messageBlock append _uidBytes;
_messageBlock pushBack 128;

while { count _messageBlock < 56 } do {
    _messageBlock pushBack 0;
};
_messageBlock append [80, 0, 0, 0, 0, 0, 0, 0];

private _add32 = {
    params ["_leftWord", "_rightWord"];

    private _lowHalf = (_leftWord # 0) + (_rightWord # 0);
    private _carry = 0;

    if (_lowHalf >= 65536) then {
        _lowHalf = _lowHalf - 65536;
        _carry = 1;
    };

    private _highHalf = (_leftWord # 1) + (_rightWord # 1) + _carry;

    if (_highHalf >= 65536) then {
        _highHalf = _highHalf - 65536;
    };

    [_lowHalf, _highHalf]
};

private _powersOfTwo = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536];

private _rotateLeft32 = {
    params ["_word", "_shift", "_powers"];

    private _lowHalf = _word # 0;
    private _highHalf = _word # 1;

    if (_shift >= 16) then {
        private _savedLowHalf = _lowHalf;
        _lowHalf = _highHalf;
        _highHalf = _savedLowHalf;
        _shift = _shift - 16;
    };

    if (_shift isEqualTo 0) exitWith { [_lowHalf, _highHalf] };

    private _multiplier = _powers # _shift;
    private _divisor = _powers # (16 - _shift);

    private _rotatedLowHalf = ((_lowHalf * _multiplier) % 65536) + floor (_highHalf / _divisor);
    private _rotatedHighHalf = ((_highHalf * _multiplier) % 65536) + floor (_lowHalf / _divisor);

    [_rotatedLowHalf, _rotatedHighHalf]
};

private _md5Boolean = {
    params ["_stateB", "_stateC", "_stateD", "_round"];

    private _result = [0, 0];

    for "_half" from 0 to 1 do {
        private _remainingBitsB = _stateB # _half;
        private _remainingBitsC = _stateC # _half;
        private _remainingBitsD = _stateD # _half;

        private _value = 0;
        private _place = 1;

        for "_bit" from 0 to 15 do {
            private _bitB = _remainingBitsB % 2;
            private _bitC = _remainingBitsC % 2;
            private _bitD = _remainingBitsD % 2;

            private _booleanBit = switch (_round) do {
                case 0: {
                    (_bitB * _bitC) + ((1 - _bitB) * _bitD);
                };
                case 1: {
                    (_bitD * _bitB) + ((1 - _bitD) * _bitC);
                };
                case 2: {
                    (_bitB + _bitC + _bitD) % 2;
                };
                default {
                    private _invertedBitD = 1 - _bitD;
                    private _orBit = _bitB + _invertedBitD - (_bitB * _invertedBitD);

                    (_bitC + _orBit) % 2;
                };
            };

            if (_booleanBit isEqualTo 1) then {
                _value = _value + _place;
            };

            _place = _place * 2;
            _remainingBitsB = floor (_remainingBitsB / 2);
            _remainingBitsC = floor (_remainingBitsC / 2);
            _remainingBitsD = floor (_remainingBitsD / 2);
        };

        _result set [_half, _value];
    };

    _result
};

private _messageWords = [];

for "_wordIndex" from 0 to 15 do {
    private _offset = _wordIndex * 4;

    private _lowHalf = (_messageBlock # _offset) + (256 * (_messageBlock # (_offset + 1)));
    private _highHalf = (_messageBlock # (_offset + 2)) + (256 * (_messageBlock # (_offset + 3)));

    _messageWords pushBack [_lowHalf, _highHalf];
};

private _initialStateA = [8961, 26437];
private _initialStateB = [43913, 61389];
private _initialStateC = [56574, 39098];
private _initialStateD = [21622, 4146];

private _stateA = +_initialStateA;
private _stateB = +_initialStateB;
private _stateC = +_initialStateC;
private _stateD = +_initialStateD;

private _rotationAmounts = [
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
];

private _roundConstants = [
    [42104, 55146], [46934, 59591], [28891, 9248], [52974, 49597],
    [4015, 62844], [50730, 18311], [17939, 43056], [38145, 64838],
    [39128, 27008], [63407, 35652], [23473, 65535], [55230, 35164],
    [4386, 27536], [29075, 64920], [17294, 42617], [2081, 18868],

    [9570, 63006], [45888, 49216], [23121, 9822], [51114, 59830],
    [4189, 54831], [5203, 580], [59009, 55457], [64456, 59347],
    [52710, 8673], [2006, 49975], [3463, 62677], [5357, 17754],
    [59653, 43491], [41976, 64751], [729, 26479], [19594, 36138],

    [14658, 65530], [63105, 34673], [24866, 28061], [14348, 64997],
    [59972, 42174], [53161, 19422], [19296, 63163], [48240, 48831],
    [32454, 10395], [10234, 60065], [12421, 54511], [7429, 1160],
    [53305, 55764], [39397, 59099], [31992, 8098], [22117, 50348],

    [8772, 62505], [65431, 17194], [9127, 43924], [41017, 64659],
    [22979, 25947], [52370, 36620], [62589, 65519], [24017, 34180],
    [32335, 28584], [59104, 65068], [17172, 41729], [4513, 19976],
    [32386, 63315], [62005, 48442], [53947, 10967], [54161, 60294]
];

for "_stepIndex" from 0 to 63 do {
    private _round = 0;
    private _messageWordIndex = switch true do {
        case (_stepIndex < 16): {
            _round = 0;
            _stepIndex;
        };
        case (_stepIndex < 32): {
            _round = 1;
            ((5 * _stepIndex) + 1) % 16;
        };
        case (_stepIndex < 48): {
            _round = 2;
            ((3 * _stepIndex) + 5) % 16;
        };
        default {
            _round = 3;
            (7 * _stepIndex) % 16;
        };
    };

    private _booleanWord = [_stateB, _stateC, _stateD, _round] call _md5Boolean;

    private _sum = [_stateA, _booleanWord] call _add32;
    _sum = [_sum, _roundConstants # _stepIndex] call _add32;
    _sum = [_sum, _messageWords # _messageWordIndex] call _add32;

    private _rotated = [_sum, _rotationAmounts # _stepIndex, _powersOfTwo] call _rotateLeft32;
    private _nextStateB = [_stateB, _rotated] call _add32;

    _stateA = _stateD;
    _stateD = _stateC;
    _stateC = _stateB;
    _stateB = _nextStateB;
};

_stateA = [_stateA, _initialStateA] call _add32;
_stateB = [_stateB, _initialStateB] call _add32;
_stateC = [_stateC, _initialStateC] call _add32;
_stateD = [_stateD, _initialStateD] call _add32;

private _digestBytes = [];

{
    private _lowHalf = _x # 0;
    private _highHalf = _x # 1;

    _digestBytes append [_lowHalf % 256, floor (_lowHalf / 256), _highHalf % 256, floor (_highHalf / 256)];
} forEach [_stateA, _stateB, _stateC, _stateD];

private _hexChars = toArray "0123456789abcdef";
private _output = [];

{
    _output pushBack (_hexChars # floor (_x / 16));
    _output pushBack (_hexChars # (_x % 16));
} forEach _digestBytes;

toString _output