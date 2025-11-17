#include "includes.inc"
params ["_badgeName"];

private _badgeConfigs = call RWD_fnc_getBadgeConfigs;

private _display = uiNamespace getVariable ["RscWLKillfeedMenu", displayNull];
if (isNull _display) then {
	"killfeed" cutRsc ["RscWLKillfeedMenu", "PLAIN", -1, true, true];
	_display = uiNamespace getVariable "RscWLKillfeedMenu";
};
private _texture = _display displayCtrl 5502;
private _badgeData = _badgeConfigs getOrDefault [_badgeName, []];

if (count _badgeData == 0) exitWith {};
private _badgeUrl = _badgeData select 0;
private _badgeLevel = _badgeData select 1;

private _script = format ["addBadge(""%1"", ""%2"", %3);", toUpper _badgeName, _badgeUrl, _badgeLevel];
_texture ctrlWebBrowserAction ["ExecJS", _script];