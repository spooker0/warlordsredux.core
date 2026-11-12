#include "includes.inc"
params ["_killer", "_assetTypeName", "_assetCost"];

private _forgiveText = format [localize "STR_WL_forgiveConfirm", name _killer, _assetTypeName];

private _callbackConfirm = {};

private _callbackCancel = {
	params ["_killer", "_assetTypeName", "_assetCost"];
    [_killer, player, _assetTypeName, _assetCost] remoteExec ["WL2_fnc_forgiveTeamkill", 2];
};

[
    "teamkill",
    _forgiveText,
    "\a3\Ui_F_Curator\Data\CfgMarkers\kia_ca.paa",
    localize "STR_WL_forgiveButton", localize "STR_WL_dontForgiveButton",
    _callbackConfirm, _callbackCancel, [_killer, _assetTypeName, _assetCost],
    20, false
] spawn WL2_fnc_timedPrompt;