#include "includes.inc"
params ["_killer", "_victim"];

private _assetType = [_victim] call WL2_fnc_getAssetTypeName;
private _forgiveText = if (isPlayer [_victim]) then {
	format ["Choose to forgive %1?", name _killer]
} else {
	format ["Choose to forgive %1 for killing %2?", name _killer, _assetType]
};
private _result = [
	"Forgive Friendly Fire",
	_forgiveText,
	"Forgive", "Don't forgive"
] call WL2_fnc_prompt;
[_killer, player, _result, _victim] remoteExec ["WL2_fnc_forgiveTeamkill", 2];