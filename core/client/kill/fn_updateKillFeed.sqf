#include "includes.inc"
params ["_displayText", "_reward", "_customColor", "_iconUrl"];

if (WL_IsSpectator && _displayText != "Spectate Target Earned Score") exitWith {};

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