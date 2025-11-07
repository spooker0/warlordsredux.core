#include "includes.inc"
private _display = uiNamespace getVariable ["RscWLHintMenu", displayNull];
if (isNull _display) then {
    "hintLayer" cutRsc ["RscWLHintMenu", "PLAIN", -1, true, true];
    _display = uiNamespace getVariable "RscWLHintMenu";
};
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

private _sideToText = {
    params ["_side"];
    ["BLUFOR", "OPFOR", "INDEP"] # ([west, east, independent] find _side);
};

while { !BIS_WL_missionEnd } do {
	uiSleep WL_TIMEOUT_STANDARD;

	private _side = BIS_WL_playerSide;
	private _sectorsBeingCaptured = BIS_WL_allSectors select {
		private _isBeingCaptured = _x getVariable ["BIS_WL_captureProgress", 0] > 0;
		private _revealed = _side in (_x getVariable ["BIS_WL_revealedBy", []]) || _side == independent || WL_IsSpectator || WL_IsReplaying;
		_isBeingCaptured && _revealed;
	};

	if (count _sectorsBeingCaptured == 0) then {
        _texture ctrlWebBrowserAction ["ExecJS", "hideSectorCapture();"];
		continue;
	};

	private _sectorCaptureList = _sectorsBeingCaptured apply {
		private _sectorName = _x getVariable ["WL2_name", "Sector"];

        private _captureProgress = _x getVariable ["BIS_WL_captureProgress", 0];
		private _captureProgressPercent = (round (_captureProgress * 1000) / 10);

		private _capturingTeam = _x getVariable ["BIS_WL_capturingTeam", independent];
		private _defendingTeam = _x getVariable ["BIS_WL_owner", independent];

        private _captureDetails = _x getVariable ["WL_captureDetails", []];

        private _capturingTeamCap = _captureDetails select {
            _x # 0 == _capturingTeam
        } select 0 select 1;
        private _defendingTeamCap = _captureDetails select {
            _x # 0 == _defendingTeam
        } select 0 select 1;
        private _capturingTeamText = [_capturingTeam] call _sideToText;
        private _defendingTeamText = [_defendingTeam] call _sideToText;

        [_sectorName, _capturingTeamCap, _defendingTeamCap, _captureProgressPercent, _capturingTeamText, _defendingTeamText];
	};

    _texture ctrlWebBrowserAction ["ExecJS", format ["updateSectorCapture(%1);", toJSON _sectorCaptureList]];
};