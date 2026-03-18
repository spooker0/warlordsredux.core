#include "includes.inc"
params ["_killer", "_victim"];

private _assetType = [_victim] call WL2_fnc_getAssetTypeName;
private _forgiveText = if (isPlayer [_victim]) then {
	format ["Choose to forgive %1?", name _killer]
} else {
	format ["Choose to forgive %1 for killing %2?", name _killer, _assetType]
};

private _callbackConfirm = {
	params ["_killer", "_victim"];
    [_killer, player, true, _victim] remoteExec ["WL2_fnc_forgiveTeamkill", 2];
};
private _callbackCancel = {
	params ["_killer", "_victim"];
    [_killer, player, false, _victim] remoteExec ["WL2_fnc_forgiveTeamkill", 2];
};

[
    _forgiveText,
    "Forgive", "Don't forgive",
    _callbackConfirm, _callbackCancel, [_killer, _victim],
    20, false
] spawn WL2_fnc_timedPrompt;