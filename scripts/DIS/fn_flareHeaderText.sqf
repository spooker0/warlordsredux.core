#include "includes.inc"
params ["_bursts", "_capacity", "_reload", "_immunity", "_singlesMode", "_key", "_modeKey"];

private _status = if (_bursts <= 0) then {
    format ["<t color='#ff0000'>%1</t>", localize "STR_WL_flareEmpty"];
} else {
    if (_reload > 0) then {
        private _reloadText = format [localize "STR_WL_flareReload", _reload toFixed 1];
        format ["<t color='#ff0000'>%1</t>", _reloadText];
    } else {
        localize "STR_WL_flareReady";
    };
};

if (_immunity > 0) then {
    private _jamText = format [localize "STR_WL_flareJam", _immunity toFixed 1];
    private _immunityText = format ["<t color='#0080ff'>%1</t>", _jamText];
    _status = if (_bursts <= 0) then {
        format ["%1 - %2", _status, _immunityText];
    } else {
        _immunityText;
    };
};

private _modeText = if (_singlesMode) then {
    localize "STR_WL_flareSingles";
} else {
    localize "STR_WL_flareBurst";
};
private _headerText = format [
    localize "STR_WL_flareHeader",
    _modeKey,
    _modeText,
    _bursts,
    _capacity,
    _key,
    _status
];
format ["<t shadow='2'>%1</t>", _headerText];
