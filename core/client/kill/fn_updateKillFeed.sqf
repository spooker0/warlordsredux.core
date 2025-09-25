#include "includes.inc"
params ["_displayText", "_reward", "_customColor", "_iconUrl"];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _useNewKillfeed = _settingsMap getOrDefault ["useNewKillfeed", true];

if (_useNewKillfeed) then {
	private _display = uiNamespace getVariable ["RscWLKillfeedMenu", displayNull];
	if (isNull _display) then {
		"killfeed" cutRsc ["RscWLKillfeedMenu", "PLAIN", -1, true, true];
		_display = uiNamespace getVariable "RscWLKillfeedMenu";
	};
	private _texture = _display displayCtrl 5502;

	private _killfeedScale = _settingsMap getOrDefault ["killfeedScale", 1.0];
	private _killfeedTimeout = (_settingsMap getOrDefault ["killfeedTimeout", 10]) * 1000;
	private _killfeedMinGap = _settingsMap getOrDefault ["killfeedMinGap", 500];
	private _ribbonMinShowTime = (_settingsMap getOrDefault ["ribbonMinShowTime", 5]) * 1000;

	private _script = format [
		"addKillfeed(""%1"", %2, ""%3"", ""%4""); setSettings(%5, %6, %7, %8);",
		toUpper _displayText,
		_reward,
		_customColor,
		_iconUrl,
		_killfeedScale,
		_killfeedTimeout,
		_killfeedMinGap,
		_ribbonMinShowTime
	];
	_texture ctrlWebBrowserAction ["ExecJS", _script];

	private _scoreControl = uiNamespace getVariable ["WL_scoreControl", controlNull];
	if (!isNull _scoreControl) then {
		_scoreControl ctrlSetStructuredText parseText "";
	};

} else {
	private _killRewardMap = uiNamespace getVariable ["WL_killRewardMap", createHashMap];

	private _scale = 0.75 call WL2_fnc_purchaseMenuGetUIScale;
	private _moneySign = [BIS_WL_playerSide] call WL2_fnc_getMoneySign;

	private _killFeed = "";
	{
		private _killRewardText = _x;
		private _repetitions = _y # 0;
		private _killRewardPoints = _y # 1;
		private _killRewardColor = _y # 2;
		private _killText = if (_repetitions > 1) then {
			format ["<t size='%1' align='right' color='%2'><t color='%2'>(x%3)</t>    %4    %5%6</t>", _scale, _killRewardColor, _repetitions, _killRewardText, _moneySign, _killRewardPoints];
		} else {
			format ["<t size='%1' align='right' color='%2'>%3    %4%5</t>", _scale, _killRewardColor, _killRewardText, _moneySign, _killRewardPoints];
		};
		_killFeed = _killFeed + _killText + "<br />";
	} forEach _killRewardMap;

	private _scoreControl = uiNamespace getVariable ["WL_scoreControl", controlNull];
	if (!isNull _scoreControl) then {
		_scoreControl ctrlSetStructuredText parseText _killFeed;
	};
};