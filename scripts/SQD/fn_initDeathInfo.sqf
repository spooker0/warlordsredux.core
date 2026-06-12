#include "includes.inc"

private _existingDisplay = findDisplay SQD_DEATHINFO_IDD;
if (!isNull _existingDisplay) exitWith { _existingDisplay };

private _display = (findDisplay 46) createDisplay "SQD_DeathInfo";
uiNamespace setVariable ["SQD_DeathInfo", _display];

_display displayAddEventHandler ["KeyUp", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    private _isPressed = false;
    {
        _isPressed = _isPressed || [_x, _key, _shift, _ctrl, _alt] call WL2_fnc_isKeyPressed;
    } forEach actionKeys ["watch"];
    if (_isPressed) then {
        _display closeDisplay 0;
    };
}];

private _killStatusText = _display displayCtrl SQD_DEATHINFO_STATUS_IDC;

private _gameData = uiNamespace getVariable ["WL2_deathInfoData", []];
if (count _gameData >= 5) then {
    _gameData params [
        "_responsiblePlayerName",
        "_killerText",
        "_ratioYou",
        "_ratioThem",
        "_projectileHitArray"
    ];

    private _projectileHits = _projectileHitArray select [0, 8];
    _projectileHits = _projectileHits apply {
        _x params ["_hitTime", "_hitText"];
        format ["<t color='%1'>%2 (%3 ms)</t>", SQD_COLOR_LOCKED, _hitText, _hitTime]
    };

    private _statusInfoArr = [
        "<t size='2'>DOWNED</t>",
        "",
        "<t size='0.6'>KILLED BY</t>",
        "<t size='0.6'>%1</t>",
        "<t size='0.8'><t size='0.5'>YOU</t> %2 - %3 <t size='0.5'>THEM</t></t>",
        "",
        "<t size='0.6'>%4</t>",
        "<t size='0.4'>%5</t>"
    ];

    private _statusInfo = format [
        _statusInfoArr joinString "<br/>",
        _responsiblePlayerName,
        _ratioYou,
        _ratioThem,
        _killerText,
        _projectileHits joinString "<br/>"
    ];
    _statusInfo = format [
        "<t shadow='2'>%1</t>",
        _statusInfo
    ];

    _killStatusText ctrlSetStructuredText parseText _statusInfo;
} else {
    _killStatusText ctrlSetStructuredText parseText "<t size='2' shadow='2'>DOWNED</t>";
};

uiNamespace setVariable ["WL2_deathInfoData", []];

private _tipsControl = _display displayCtrl SQD_DEATHINFO_TIPS_IDC;

private _randomTipIndex = floor (random 29) + 1;
private _randomTipIndexStr = str _randomTipIndex;
if (_randomTipIndex < 100) then {
    _randomTipIndexStr = "0" + _randomTipIndexStr;
};
if (_randomTipIndex < 10) then {
    _randomTipIndexStr = "0" + _randomTipIndexStr;
};
private _tip = localize format ["STR_WL_deathTip_%1", _randomTipIndexStr];
_tipsControl ctrlSetStructuredText parseText format ["<t size='0.6' shadow='2'>Tip: %1</t>", _tip];

_display;