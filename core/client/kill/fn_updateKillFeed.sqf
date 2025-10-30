#include "includes.inc"
params ["_displayText", "_reward", "_customColor", "_iconUrl"];

if (WL_IsSpectator && _displayText != "Spectate Target Earned Score") exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _useNewKillfeed = _settingsMap getOrDefault ["useNewKillfeed", true];

if (_useNewKillfeed) then {
	private _display = uiNamespace getVariable ["RscWLKillfeedMenu", displayNull];
	if (isNull _display) then {
		"killfeed" cutRsc ["RscWLKillfeedMenu", "PLAIN", -1, true, true];
		_display = uiNamespace getVariable "RscWLKillfeedMenu";
	};

	private _times = 1;
	if (_displayText == "RECON") then {
		_times = (floor (_reward / 100)) max 1;
	};
	if (_displayText == "ACTIVE PROTECTION SYSTEM") then {
		_times = (floor (_reward / 50)) max 1;
	};
	if (_displayText == "DAZZLER") then {
		_times = (floor (_reward / 10)) max 1;
	};
	if (_displayText == "DEMOLITION") then {
		_times = (floor (_reward / 20)) max 1;
	};
	private _texture = _display displayCtrl 5502;

	private _killFeedItems = [
		toUpper _displayText,
		floor (_reward / _times),
		_customColor,
		_iconUrl
	];
	private _killfeedText = _texture ctrlWebBrowserAction ["ToBase64", toJSON _killFeedItems];
	private _script = format ["addKillfeed(atobr(""%1""), %2)", _killfeedText, _times];
	_texture ctrlWebBrowserAction ["ExecJS", _script];

	private _scoreControl = uiNamespace getVariable ["WL_scoreControl", controlNull];
	if (!isNull _scoreControl) then {
		_scoreControl ctrlSetStructuredText parseText "";
	};

} else {
	private _killRewardMap = uiNamespace getVariable ["WL_killRewardMap", createHashMap];

	private _scale = 0.75 call WL2_fnc_purchaseMenuGetUIScale;
	private _moneySign = WL_MoneySign;

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