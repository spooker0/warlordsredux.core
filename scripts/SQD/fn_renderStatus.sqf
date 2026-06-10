#include "includes.inc"
params ["_display"];

private _statusText = _display displayCtrl SQD_STATUS_IDC;
private _statusName = "";
private _statusColor = "#ffffff";
private _statusTime = "";
if (WL_ISUP(player)) then {
    _statusName = "ALIVE";
} else {
    _statusColor = "#ff0000";
    if (alive player) then {
        private _expirationTime = player getVariable ["WL2_expirationTime", 0];
        private _respawnTimer = (_expirationTime - serverTime) max 0;
        _statusName = "DOWNED";
        if (_respawnTimer > 0) then {
            _statusTime = _respawnTimer toFixed 1;
        };
    } else {
        _statusName = "RESPAWNING";
        private _respawnTimer = playerRespawnTime;
        if (_respawnTimer > 0) then {
            _statusTime = round _respawnTimer;
        };
    };
};
private _statusTextStructured = parseText format [
    "<t> <t size='0.5' valign='middle'><t align='center' color='%1'>%2</t><t align='right'>%3</t></t> </t>",
    _statusColor,
    _statusName,
    _statusTime
];
_statusText ctrlSetStructuredText _statusTextStructured;
_statusText ctrlCommit 0;

private _respawnCounter = uiNamespace getVariable ["RscRespawnCounter", displayNull];
if (!isNull _respawnCounter) then {
    _respawnCounter closeDisplay 1;
};

private _statusHelpButton = _display displayCtrl SQD_STATUS_HELP_IDC;
private _statusHelpButtonTextStructured = [
    "HELP",
    SQD_LAYOUT_LABEL_TEXT_SIZE * 0.75,
    SQD_COLOR_TEXT,
    "center"
] call SQD_fnc_renderText;
_statusHelpButton ctrlSetStructuredText _statusHelpButtonTextStructured;
_statusHelpButton ctrlRemoveAllEventHandlers "ButtonClick";
_statusHelpButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control", "_event", "_x", "_y", "_shift", "_ctrl", "_alt"];
    private _display = ctrlParent _control;
    _display closeDisplay 0;
    0 spawn WL2_fnc_welcome;
}];
