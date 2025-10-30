#include "includes.inc"
params ["_dikCode", "_key", "_shift", "_ctrl", "_alt"];

private _dikNumStringToKeyMod = {
    params ["_inputString"];

    private _isNegative = false;
    if ((_inputString select [0, 1]) == "-") then {
        _isNegative = true;
        _inputString = _inputString select [1];
    };

    private _hexCharacters = "0123456789ABCDEF" splitString "";

    private _divideDecimalStringBy16 = {
        params ["_decimalString"];
        private _quotientString = "";
        private _carryValue = 0;

        {
            private _digitValue = _x - 48;
            private _combinedValue = _carryValue * 10 + _digitValue;
            private _quotientDigit = floor (_combinedValue / 16);
            _carryValue = _combinedValue mod 16;

            if (_quotientString != "" || _quotientDigit > 0) then {
                _quotientString = _quotientString + str _quotientDigit;
            };
        } forEach (toArray _decimalString);

        if (_quotientString == "") then {
            _quotientString = "0";
        };

        [_quotientString, _carryValue]
    };

    private _convertDecimalStringToHex = {
        params ["_decimalString"];
        private _hexString = "";
        private _currentString = _decimalString;

        while {_currentString != "0"} do {
            private _divisionResult = [_currentString] call _divideDecimalStringBy16;
            _currentString = _divisionResult select 0;
            private _remainderValue = _divisionResult select 1;
            _hexString = (_hexCharacters select _remainderValue) + _hexString;
        };

        _hexString
    };

    private _padHexStringToEightDigits = {
        params ["_hexString"];
        private _upperHex = toUpper _hexString;
        private _missingCount = 8 - (count _upperHex);

        if (_missingCount > 0) then {
            private _padding = "";
            for "_i" from 1 to _missingCount do {
                _padding = _padding + "0";
            };
            _upperHex = _padding + _upperHex;
        };

        _upperHex
    };

    private _subtractHexStrings = {
        params ["_leftHexString", "_rightHexString"];

        private _leftArray = toArray _leftHexString;
        private _rightArray = toArray _rightHexString;
        private _lastIndex = (count _leftArray) - 1;
        private _borrowFlag = 0;
        private _resultString = "";

        for "_index" from _lastIndex to 0 step -1 do {
            private _leftCharacter = _leftArray select _index;
            private _rightCharacter = _rightArray select _index;

            private _leftValue = 0;
            if (_leftCharacter >= 65) then {
                _leftValue = 10 + (_leftCharacter - 65);
            } else {
                _leftValue = _leftCharacter - 48;
            };

            private _rightValue = 0;
            if (_rightCharacter >= 65) then {
                _rightValue = 10 + (_rightCharacter - 65);
            } else {
                _rightValue = _rightCharacter - 48;
            };

            private _differenceValue = _leftValue - _rightValue - _borrowFlag;
            if (_differenceValue < 0) then {
                _differenceValue = _differenceValue + 16;
                _borrowFlag = 1;
            } else {
                _borrowFlag = 0;
            };

            private _hexCharacter = "";
            if (_differenceValue < 10) then {
                _hexCharacter = toString [48 + _differenceValue];
            } else {
                _hexCharacter = toString [65 + _differenceValue - 10];
            };

            _resultString = _hexCharacter + _resultString;
        };

        private _characterArray = toArray _resultString;
        private _startIndex = 0;

        while {_startIndex < count _characterArray && (_characterArray select _startIndex) == 48} do {
            _startIndex = _startIndex + 1;
        };

        if (_startIndex >= count _characterArray) then {
            "0"
        } else {
            toString (_characterArray select [_startIndex, (count _characterArray) - _startIndex])
        };
    };

    private _convertHexByteToDecimal = {
        params ["_hexByte"];
        private _upperHex = toUpper _hexByte;
        private _characters = toArray _upperHex;
        private _decimalValue = 0;

        {
            private _digitValue = 0;
            if (_x >= 65) then {
                _digitValue = 10 + (_x - 65);
            } else {
                _digitValue = _x - 48;
            };
            _decimalValue = _decimalValue * 16 + _digitValue;
        } forEach _characters;

        _decimalValue
    };

    private _hexString = "";

    if (!_isNegative) then {
        if (_inputString == "0") then {
            _hexString = "00000000";
        } else {
            _hexString = [_inputString] call _convertDecimalStringToHex;
            _hexString = [_hexString] call _padHexStringToEightDigits;
        };
    } else {
        private _absoluteHex = [_inputString] call _convertDecimalStringToHex;
        private _absoluteLength = count _absoluteHex;
        private _remainderHex = "";

        if (_absoluteLength > 8) then {
            _remainderHex = toUpper (_absoluteHex select [_absoluteLength - 8, 8]);
        } else {
            _remainderHex = toUpper _absoluteHex;
        };

        if (!(_remainderHex in ["0", "00000000"])) then {
            private _rightHex = "0" + ([_remainderHex] call _padHexStringToEightDigits);
            private _leftHex = "100000000";
            private _twoComplementHex = [_leftHex, _rightHex] call _subtractHexStrings;
            _hexString = [_twoComplementHex] call _padHexStringToEightDigits;
        } else {
            _hexString = "00000000";
        };
    };

    private _modifierHex = _hexString select [0, 2];
    private _keyHex = _hexString select [6, 2];

    private _modifierValue = [_modifierHex] call _convertHexByteToDecimal;
    private _keyValue = [_keyHex] call _convertHexByteToDecimal;

    private _modifiers = [];

    if (_modifierHex in ["1D","9D"]) then {
        _modifiers pushBack "ctrl";
    };

    if (_modifierHex in ["38","B8"]) then {
        _modifiers pushBack "alt";
    };

    if (_modifierHex in ["2A","36"]) then {
        _modifiers pushBack "shift";
    };

    [_modifiers, _keyValue]
};

if (count _dikCode <= 4) exitWith {
    _dikCode == str _key && !_shift && !_ctrl && !_alt;
};

private _dikNumStringCache = uiNamespace getVariable ["WL2_dikNumStringCache", createHashMap];
private _result = if (_dikCode in _dikNumStringCache) then {
    _dikNumStringCache get _dikCode;
} else {
    private _calcResult = [_dikCode] call _dikNumStringToKeyMod;
    _dikNumStringCache set [_dikCode, _calcResult];
    uiNamespace setVariable ["WL2_dikNumStringCache", _dikNumStringCache];
    _calcResult;
};

private _keyCode = _result # 1;
if (_keyCode != _key) exitWith {
    false
};

private _modifiers = _result # 0;

if (("shift" in _modifiers) != _shift) exitWith {
    false
};
if (("ctrl" in _modifiers) != _ctrl) exitWith {
    false
};
if (("alt" in _modifiers) != _alt) exitWith {
    false
};

true;