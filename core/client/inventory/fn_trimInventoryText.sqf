#include "includes.inc"
params ["_loadout"];
private _text = "";
{
    if (_x == "") then {
        continue;
    };
    private _weapon = _x;
    private _maxLetters = 0;
    for "_i" from 0 to count _weapon do {
        private _fragment = _weapon select [0, _i];
        _fragment = format ["%1<br/>", _fragment];
        private _width = _fragment getTextWidth ["PuristaMedium", INV_BUTTON_FONT];
        _width = _width - 0.016;
        if (_width > INV_BUTTON_WIDTH) then {
            break;
        };
        _maxLetters = _i;
    };
    private _weaponDisplay = _weapon select [0, _maxLetters];
    if (_weaponDisplay != "") then {
        _text = format ["%1%2<br/>", _text, _weaponDisplay];
    };
} forEach _loadout;
if (_text == "") then {
    _text = "(Empty)";
};
_text