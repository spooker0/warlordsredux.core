#include "includes.inc"
params ["_displayText", "_reward", "_customColor", "_iconUrl"];

if (WL_IsSpectator && !("SPECTATE" in _displayText)) exitWith {};

_displayText = toUpper _displayText;

private _rewards = [];

private _killfeedDivisionUnit = uiNamespace getVariable ["WL2_killfeedRewardDivision", createHashMap];

while { _reward > 0 } do {
	private _killFeedDivision = _killfeedDivisionUnit getOrDefault [_displayText, _reward];
	private _currentReward = _reward min _killFeedDivision;
	_reward = _reward - _currentReward;
	_rewards pushBack _currentReward;
};

private _killfeedItems = uiNamespace getVariable ["WL2_killfeedItems", []];
{
	_killfeedItems pushBack [
		_iconUrl,
		toUpper _displayText,
		_x,
		_customColor
	];
} forEach _rewards;

uiNamespace setVariable ["WL2_killfeedLastInputTime", time];