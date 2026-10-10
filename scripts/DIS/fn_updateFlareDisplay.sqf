#include "includes.inc"
params ["_display", "_header", "_controls", "_showIncoming"];

disableSerialization;

private _asset = cameraOn;
private _capacity = WL_UNIT(_asset, "flareBursts", 0);
private _missiles = [];

if (_capacity > 0 && alive _asset) then {
    private _bursts = _asset getVariable ["DIS_flareBursts", 0];
    private _readyAt = _asset getVariable ["DIS_flareReadyAt", 0];
    private _immunityUntil = _asset getVariable ["DIS_flareImmunityUntil", 0];
    private _reload = (_readyAt - serverTime) max 0;
    private _immunity = (_immunityUntil - serverTime) max 0;

    private _status = if (_bursts <= 0) then {
        "<t color='#ff0000'>EMPTY</t>";
    } else {
        if (_reload > 0) then {
            format ["<t color='#ff0000'>RELOAD %1</t>", _reload toFixed 1];
        } else {
            "READY";
        };
    };

    if (_immunity > 0) then {
        private _immunityText = format ["<t color='#0080ff'>JAM %1</t>", _immunity toFixed 1];
        _status = if (_bursts <= 0) then {
            format ["%1 - %2", _status, _immunityText];
        } else {
            _immunityText;
        };
    };

    private _key = (actionKeysNames ["launchCM", 1, "Keyboard"]) regexReplace ["""", ""];
    _header ctrlSetStructuredText parseText format ["<t shadow='2'>FLARE %1/%2 (%3) - %4</t>", _bursts, _capacity, _key, _status];

    if (_showIncoming) then {
        private _incomingMissiles = _asset getVariable ["WL_incomingMissiles", []];
        {
            private _missileDefeated = _x getVariable ["DIS_missileDefeated", false];
            if (!alive _x || _missileDefeated || !isNull attachedTo _x) then {
                continue;
            };

            private _window = [_asset, _x] call DIS_fnc_getFlareWindow;
            _missiles pushBack [_x, _window];
        } forEach _incomingMissiles;

        _missiles = [_missiles, [_asset], {
            (_x # 0) distance _input0;
        }, "ASCEND"] call BIS_fnc_sortBy;
    };
};

while { count _controls > count _missiles } do {
    {
        ctrlDelete _x;
    } forEach (_controls deleteAt (count _controls - 1));
};

if (count _missiles == 0) exitWith {
    _controls;
};

private _position = ctrlPosition _header;
private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
private _fontScale = (_settingsMap getOrDefault ["targetingMenuFontSize", 18]) / 18;
private _left = _position # 0;
private _top = (_position # 1) + ctrlTextHeight _header + 0.005;
private _width = _position # 2;
private _rowHeight = 0.07 * _fontScale;
private _missileTypes = call DIS_fnc_getMissileType;

{
    _x params ["_missile", "_window"];

    if (_forEachIndex >= count _controls) then {
        private _row = [];
        for "_i" from 0 to 4 do {
            private _control = _display ctrlCreate ["RscText", -1];
            _control ctrlEnable false;
            _row pushBack _control;
        };

        private _missileTick = _display ctrlCreate ["RscPictureKeepAspect", -1];
        _missileTick ctrlEnable false;
        _missileTick ctrlSetText "\A3\ui_f\data\map\markers\nato\o_unknown.paa";
        _row pushBack _missileTick;

        _controls pushBack _row;
    };

    private _row = _controls # _forEachIndex;
    _row params ["_label", "_line", "_band", "_minimumTick", "_maximumTick", "_missileTick"];

    private _rowTop = _top + _forEachIndex * _rowHeight;
    private _barTop = _rowTop + 0.043 * _fontScale;
    private _missileName = _missile getVariable ["WL2_missileNameOverride", _missileTypes getOrDefault [typeOf _missile, "MISSILE"]];
    private _distanceText = ((_missile distance _asset) / 1000) toFixed 1;
    _label ctrlSetText format ["%1 - %2 KM", _missileName, _distanceText];
    _label ctrlSetFont "EtelkaMonospaceProBold";
    _label ctrlSetFontHeight (0.028 * _fontScale);
    _label ctrlSetTextColor [1, 1, 1, 1];
    _label ctrlSetPosition [_left, _rowTop, _width, 0.03 * _fontScale];
    _label ctrlCommit 0;

    private _hasWindow = count _window > 0;
    {
        _x ctrlShow _hasWindow;
    } forEach (_row select [1]);

    if (!_hasWindow) then {
        continue;
    };

    _window params ["_minimumRange", "_optimalRange", "_maximumRange", "_distance", "_inRange"];

    private _scale = 10000;
    private _tickWidth = 2 * pixelW;
    private _barWidth = _width - _tickWidth;
    private _tickPositions = [_minimumRange, _maximumRange, _distance] apply {
        _left + (linearConversion [0, _scale, _x, 0, _barWidth, true]);
    };

    _line ctrlSetBackgroundColor [0.65, 0.65, 0.65, 0.8];
    _line ctrlSetPosition [_left, _barTop, _width, pixelH];

    private _bandColor = if (_inRange) then {
        [0.2, 1, 0.2, 0.8];
    } else {
        [0.2, 0.6, 0.2, 0.5];
    };
    _band ctrlSetBackgroundColor _bandColor;
    _band ctrlSetPosition [_tickPositions # 0, _barTop - 0.003 * _fontScale, (_tickPositions # 1) - (_tickPositions # 0), 0.006 * _fontScale];

    {
        _x ctrlSetBackgroundColor [0.2, 1, 0.2, 1];
    } forEach [_minimumTick, _maximumTick];

    _missileTick ctrlSetTextColor [1, 0, 0, 1];

    {
        _x ctrlSetPosition [_tickPositions # _forEachIndex, _barTop - 0.012 * _fontScale, _tickWidth, 0.018 * _fontScale];
    } forEach [_minimumTick, _maximumTick];

    private _diamondHeight = 0.021 * _fontScale;
    private _diamondWidth = _diamondHeight * pixelW / pixelH;
    _missileTick ctrlSetPosition [(_tickPositions # 2) + (_tickWidth - _diamondWidth) / 2, _barTop + (pixelH - _diamondHeight) / 2, _diamondWidth, _diamondHeight];

    {
        _x ctrlCommit 0;
    } forEach _row;
} forEach _missiles;

_controls;
