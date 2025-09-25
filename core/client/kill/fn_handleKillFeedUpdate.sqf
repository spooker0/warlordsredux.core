#include "includes.inc"
if (isDedicated) exitWith {};

private _scoreControl = (findDisplay 46) ctrlCreate ["RscStructuredText", -1];

private _blockW = safeZoneW / 1000;
private _blockH = safeZoneH / (1000 / (getResolution # 4));

private _displayW = _blockW * 180;
private _displayH = _blockH * 54;
private _displayX = safeZoneW + safeZoneX - _displayW - (_blockW * 10);
private _displayY = safeZoneH + safeZoneY - _displayH - (_blockH * 50);

_scoreControl ctrlSetPosition [_displayX - (_blockW * 110), _displayY - (_blockH * 16 * 3 + _blockH * 30), _blockW * 160, _blockH * 16 * 4];
_scoreControl ctrlCommit 0;

uiNamespace setVariable ["WL_scoreControl", _scoreControl];
uiNamespace setVariable ["WL_killRewardMap", createHashMap];

while { !BIS_WL_missionEnd } do {
    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
    private _useNewKillfeed = _settingsMap getOrDefault ["useNewKillfeed", true];

    if (_useNewKillfeed) then {
        private _display = uiNamespace getVariable ["RscWLKillfeedMenu", displayNull];
        if (isNull _display) then {
            "killfeed" cutRsc ["RscWLKillfeedMenu", "PLAIN", -1, true, true];
            _display = uiNamespace getVariable "RscWLKillfeedMenu";
        };

        private _killfeedScale = _settingsMap getOrDefault ["killfeedScale", 1.0];
        private _killfeedBadgeScale = _settingsMap getOrDefault ["killfeedBadgeScale", 1.0];
        private _killfeedTimeout = (_settingsMap getOrDefault ["killfeedTimeout", 10]) * 1000;
        private _killfeedMinGap = _settingsMap getOrDefault ["killfeedMinGap", 500];
        private _ribbonMinShowTime = (_settingsMap getOrDefault ["ribbonMinShowTime", 5]) * 1000;

        private _texture = _display displayCtrl 5502;
        private _script = format [
            "setSettings(%1, %2, %3, %4, %5);",
            _killfeedScale,
            _killfeedBadgeScale,
            _killfeedTimeout,
            _killfeedMinGap,
            _ribbonMinShowTime
        ];
        _texture ctrlWebBrowserAction ["ExecJS", _script];

        sleep 10;
        continue;
    };

    private _killRewards = uiNamespace getVariable ["WL_killRewardMap", []];
    private _killFeedDirty = false;
    private _newKillRewardMap = createHashMap;
    {
        private _killRewardTimestamp = _y # 3;
        if ((_killRewardTimestamp + 10) > serverTime) then {
            _newKillRewardMap set [_x, _y];
        } else {
            _killFeedDirty = true;
        };
    } forEach _killRewards;

    if (_killFeedDirty) then {
        uiNamespace setVariable ["WL_killRewardMap", _newKillRewardMap];
        [] call WL2_fnc_updateKillFeed;
    };

    sleep 1;
};