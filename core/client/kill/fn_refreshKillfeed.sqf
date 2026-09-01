#include "includes.inc"
if (isDedicated) exitWith {};

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];

private _display = uiNamespace getVariable ["RscWLKillfeedDisplay", displayNull];
if (isNull _display) then {
    "killfeed" cutRsc ["RscWLKillfeedDisplay", "PLAIN", -1, true, true];
    _display = uiNamespace getVariable ["RscWLKillfeedDisplay", displayNull];
};

private _textControl = _display displayCtrl 8000;
private _numbersControl = _display displayCtrl 8001;
private _iconsControl = _display displayCtrl 8002;
private _totalControl = _display displayCtrl 8003;

private _badgeFrame = _display displayCtrl 8004;
private _badgeTextControl = _display displayCtrl 8005;

[_textControl, _numbersControl, _iconsControl, _totalControl] spawn {
    params ["_textControl", "_numbersControl", "_iconsControl", "_totalControl"];
    private _lastSettings = [];
    while { !isNull _textControl } do {
        private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];

        private _killfeedLeft = _settingsMap getOrDefault ["killfeedLeft", 50];
        private _killfeedTop = _settingsMap getOrDefault ["killfeedTop", 95];

        private _currentSettings = [_killfeedLeft, _killfeedTop];

        if (_lastSettings isEqualTo _currentSettings) then {
            uiSleep 0.5;
            continue;
        };

        _lastSettings = _currentSettings;

        private _killfeedWidth = 0.4;
        private _killfeedHeight = 0.2;
        private _killfeedNumberWidth = 0.2;
        private _killfeedIconWidth = 0.8;
        private _killfeedIconHeight = 0.06;

        private _killfeedTotalWidth = 0.2;
        private _killfeedTotalHeight = 0.05;

        private _killfeedLeftControl = _killfeedLeft / 100 * safeZoneW + safeZoneX;
        private _killfeedTopControl = _killfeedTop / 100 * safeZoneH + safeZoneY;

        _textControl ctrlSetPosition [
            _killfeedLeftControl - (_killfeedWidth / 2),
            _killfeedTopControl - _killfeedHeight,
            _killfeedWidth,
            _killfeedHeight
        ];
        _textControl ctrlCommit 0;

        _numbersControl ctrlSetPosition [
            _killfeedLeftControl + (_killfeedWidth / 2),
            _killfeedTopControl - _killfeedHeight,
            _killfeedNumberWidth,
            _killfeedHeight
        ];
        _numbersControl ctrlCommit 0;

        _iconsControl ctrlSetPosition [
            _killfeedLeftControl - (_killfeedIconWidth / 2),
            _killfeedTopControl - _killfeedHeight - _killfeedIconHeight,
            _killfeedIconWidth,
            _killfeedIconHeight
        ];
        _iconsControl ctrlCommit 0;

        _totalControl ctrlSetPosition [
            0.5,
            0.5 - (_killfeedTotalHeight / 2),
            _killfeedTotalWidth,
            _killfeedTotalHeight
        ];
        _totalControl ctrlCommit 0;
    };
};

uiNamespace setVariable ["WL2_killfeedItems", []];
uiNamespace setVariable ["WL2_badgeItems", []];
uiNamespace setVariable ["WL2_killfeedLastInputTime", 0];

private _maxIcons = 8;
private _maxFeedTextLines = 5;

private _fadeDuration = 1;
private _stepDuration = 0.1;

private _lastRevealedFeedTime = 0;
private _lastFeedTextsShown = [];

private _iconRowsMemory = [];
private _feedTextRowsMemory = [];

private _feedTotalPoints = 0;
private _lastTotalPointsTime = 0;
private _feedTotalColor = WL_COLOR_SUPPORT;

private _whiteColor = "#ffffff";

private _currentBadge = [];
private _badgeShownTime = 0;
private _badgeFrameHiddenColor = [0, 0, 0, 0];

private _killfeedFadeStarted = false;
private _totalFadeStarted = false;
private _badgeFadeStarted = false;

{
    _x ctrlSetFade 0;
    _x ctrlCommit 0;
} forEach [_textControl, _numbersControl, _iconsControl, _totalControl, _badgeFrame, _badgeTextControl];

private _fnc_formatKillfeedText = {
    params ["_textLine", "_whiteColor", "_customColor"];

    private _prefix = "";
    private _prefixLength = 0;

    if ((_textLine select [0, 5]) == "KILL ") then {
        _prefix = "KILL ";
        _prefixLength = 5;
    } else {
        if ((_textLine select [0, 10]) == "DESTROYED ") then {
            _prefix = "DESTROYED ";
            _prefixLength = 10;
        };
    };

    if (_prefixLength == 0) exitWith {
        format ["<t color='%1'>%2</t>", _whiteColor, _textLine]
    };

    private _suffix = _textLine select [_prefixLength];
    format ["<t color='%1'>%2</t><t color='%3'>%4</t>", _whiteColor, _prefix, _customColor, _suffix]
};

while { !BIS_WL_missionEnd } do {
    private _totalDisplayDelay = _settingsMap getOrDefault ["killfeedTotalTimeout", 3];
    private _clearDelay = _settingsMap getOrDefault ["killfeedTimeout", 10];
    private _badgeDismissDelay = _settingsMap getOrDefault ["ribbonMinShowTime", 5];

    private _now = time;
    private _items = uiNamespace getVariable ["WL2_killfeedItems", []];

    if (count _items > 0) then {
        private _newItem = _items deleteAt 0;

        _lastRevealedFeedTime = _now;

        {
            _x ctrlSetFade 0;
            _x ctrlCommit 0;
        } forEach [_textControl, _numbersControl, _iconsControl];
        _killfeedFadeStarted = false;

        _newItem params ["_newIconPath", "_newFeedText", "_newFeedPoints", "_newFeedColor"];

        if (_newIconPath != "") then {
            _iconRowsMemory pushBack [_newIconPath, _newFeedColor];

            while { count _iconRowsMemory > _maxIcons } do {
                _iconRowsMemory deleteAt 0;
            };
        };

        if (_newFeedText != "") then {
            _feedTotalPoints = _feedTotalPoints + _newFeedPoints;
            _lastTotalPointsTime = _now;

            _totalControl ctrlSetFade 0;
            _totalControl ctrlCommit 0;

            _totalFadeStarted = false;

            if (_newFeedColor == WL_COLOR_KILL) then {
                _feedTotalColor = WL_COLOR_KILL;
            };

            private _existingIndex = _feedTextRowsMemory findIf {
                _x # 0 == _newFeedText
            };

            if (_existingIndex == -1) then {
                _feedTextRowsMemory insert [0, [[_newFeedText, 1, _newFeedPoints, _newFeedColor]]];
            } else {
                private _existing = _feedTextRowsMemory deleteAt _existingIndex;

                private _oldCount = _existing param [1, 1];
                private _oldPoints = _existing param [2, 0];

                _feedTextRowsMemory insert [0, [[_newFeedText, _oldCount + 1, _oldPoints + _newFeedPoints, _newFeedColor]]];
            };
        };
    };

    private _hasPendingItems = count _items > 0;

    private _lastInputTime = uiNamespace getVariable ["WL2_killfeedLastInputTime", 0];
    private _lastActivityTime = _lastInputTime max _lastRevealedFeedTime;

    if (_lastActivityTime > 0) then {
        private _timeSinceLastActivity = _now - _lastActivityTime;
        private _fadeStartTime = (_clearDelay - _fadeDuration) max 0;

        if (!_hasPendingItems && !_killfeedFadeStarted && _timeSinceLastActivity >= _fadeStartTime) then {
            {
                _x ctrlSetFade 1;
                _x ctrlCommit _fadeDuration;
            } forEach [_textControl, _numbersControl, _iconsControl];

            _killfeedFadeStarted = true;
        };
    };

    if (!_hasPendingItems && _lastActivityTime > 0 && _now - _lastActivityTime > _clearDelay) then {
        _lastRevealedFeedTime = 0;
        _lastFeedTextsShown = [];

        _iconRowsMemory resize 0;
        _feedTextRowsMemory resize 0;

        _feedTotalPoints = 0;
        _lastTotalPointsTime = 0;
        _feedTotalColor = WL_COLOR_SUPPORT;

        _killfeedFadeStarted = false;
    };

    private _iconImages = "";

    {
        _x params ["_iconPath", "_iconColor"];

        _iconImages = format ["%1 <img color='%2' image='%3'/>", _iconImages, _iconColor, _iconPath];
    } forEach _iconRowsMemory;
    _iconsControl ctrlSetStructuredText parseText format ["<t shadow='2'>%1</t>", _iconImages];

    private _feedTextRowsToShow = _feedTextRowsMemory select [0, _maxFeedTextLines min count _feedTextRowsMemory];

    if (_lastFeedTextsShown isNotEqualTo _feedTextRowsToShow) then {
        private _killfeedNotificationVolume = _settingsMap getOrDefault ["killfeedNotification", 1.0];
        private _pitch = 1 + (random 0.2);
        playSoundUI ["AddItemOk", _killfeedNotificationVolume * 3, _pitch];

        _lastFeedTextsShown = +_feedTextRowsToShow;
    };

    private _feedTextStructured = "";
    private _numbersStructured = "";

    {
        _x params ["_text", "_count", "_points", "_numberColor"];

        private _textLine = _text;
        private _pointsLine = format ["+%1", _points];

        if (_count > 1) then {
            _textLine = format ["%1 <t size='0.8' align='right' color='%2'>x%3</t>", _textLine, _whiteColor, _count];
        };

        if (_forEachIndex > 0) then {
            _feedTextStructured = _feedTextStructured + "<br/>";
            _numbersStructured = _numbersStructured + "<br/>";
        };

        private _formattedText = [_textLine, _whiteColor, _numberColor] call _fnc_formatKillfeedText;
        _feedTextStructured = _feedTextStructured + _formattedText;
        _numbersStructured = _numbersStructured + format ["<t color='%1'>%2</t>", _numberColor, _pointsLine];
    } forEach _feedTextRowsToShow;

    _textControl ctrlSetStructuredText parseText format ["<t shadow='2'>%1</t>", _feedTextStructured];
    _numbersControl ctrlSetStructuredText parseText format ["<t shadow='2'>%1</t>", _numbersStructured];

    private _totalStructured = "";

    if (_feedTotalPoints > 0 && _lastTotalPointsTime > 0) then {
        private _timeSinceTotalPoints = _now - _lastTotalPointsTime;

        if (_timeSinceTotalPoints <= _totalDisplayDelay) then {
            private _totalFadeStartTime = (_totalDisplayDelay - _fadeDuration) max 0;

            if (!_totalFadeStarted && _timeSinceTotalPoints >= _totalFadeStartTime) then {
                _totalControl ctrlSetFade 1;
                _totalControl ctrlCommit _fadeDuration;

                _totalFadeStarted = true;
            };

            _totalStructured = format ["<t color='%1'>%2%3</t>", _feedTotalColor, WL_MONEY_SIGN, (_feedTotalPoints call BIS_fnc_numberText) regexReplace [" ", ","]];
        };
    };

    _totalControl ctrlSetStructuredText parseText format ["<t shadow='2'>%1</t>", _totalStructured];

    private _badgeItems = uiNamespace getVariable ["WL2_badgeItems", []];

    if (count _currentBadge == 0 && count _badgeItems > 0) then {
        _currentBadge = _badgeItems deleteAt 0;
        _badgeShownTime = _now;

        _badgeFrame ctrlSetFade 0;
        _badgeFrame ctrlCommit 0;

        _badgeTextControl ctrlSetFade 0;
        _badgeTextControl ctrlCommit 0;

        _badgeFadeStarted = false;

        private _badgeLevel = _currentBadge # 3;

        if (_badgeLevel == 3) then {
            private _killfeedCelebrationVolume = _settingsMap getOrDefault ["killfeedCelebration", 1.0];
            playSoundUI ["a3\missions_f_exp\data\sounds\exp_m05_dramatic.wss", _killfeedCelebrationVolume * 5];
        } else {
            private _killfeedNotificationVolume = _settingsMap getOrDefault ["killfeedNotification", 1.0];
            private _pitch = 0.5 + (random 0.5);

            private _sound = [
                "a3\sounds_f_orange\missionsfx\orange_destroy_01.wss",
                "a3\sounds_f_orange\missionsfx\orange_destroy_02.wss",
                "a3\sounds_f_orange\missionsfx\orange_destroy_03.wss"
            ];

            playSoundUI [selectRandom _sound, _killfeedNotificationVolume, _pitch];
        };
    };

    if (count _currentBadge > 0) then {
        private _badgeElapsed = _now - _badgeShownTime;

        private _badgeFadeStartTime = (
            _badgeDismissDelay - _fadeDuration
        ) max 0;

        if (!_badgeFadeStarted && _badgeElapsed >= _badgeFadeStartTime) then {
            _badgeFrame ctrlSetFade 1;
            _badgeFrame ctrlCommit _fadeDuration;

            _badgeTextControl ctrlSetFade 1;
            _badgeTextControl ctrlCommit _fadeDuration;

            _badgeFadeStarted = true;
        };
    };

    if (count _currentBadge > 0 && _now - _badgeShownTime > _badgeDismissDelay) then {
        _currentBadge = [];
        _badgeShownTime = 0;
        _badgeFadeStarted = false;
    };

    if (count _currentBadge > 0) then {
        _currentBadge params ["_badgeName", "_badgeDescription", "_badgeIcon", "_badgeLevel"];

        private _badgeFrameColor = switch (_badgeLevel) do {
            case 1: {
                [0.45, 0.62, 0.80, 1]
            };
            case 2: {
                [0.80, 0.45, 0.45, 1]
            };
            case 3: {
                [1, 0.85, 0, 1]
            };
            default {
                [0, 0, 0, 0]
            };
        };

        _badgeFrame ctrlSetBackgroundColor _badgeFrameColor;

        private _badgeStructured = format [
            "<img image='%1' size='1.5' shadow='0'/><br/><t color='#ffffff' shadow='2'>%2</t><br/><t color='#ffffff' size='0.8' shadow='2'>%3</t>",
            _badgeIcon,
            _badgeName,
            _badgeDescription
        ];

        _badgeTextControl ctrlSetStructuredText parseText _badgeStructured;
    } else {
        _badgeFrame ctrlSetBackgroundColor _badgeFrameHiddenColor;
        _badgeTextControl ctrlSetStructuredText parseText "";
    };

    uiSleep _stepDuration;
};