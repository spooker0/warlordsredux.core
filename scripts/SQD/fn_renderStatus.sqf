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

// private _killStatusText = _display displayCtrl SQD_KILL_STATUS_IDC;
// if (WL_ISUP(player)) exitWith {
//     _killStatusText ctrlShow false;
// };

// private _gameData = uiNamespace getVariable ["WL2_deathInfoData", []];
// if (count _gameData >= 12) then {
//     _gameData params [
//         "_health",
//         "_killerText",
//         "_killerIcon",
//         "_ratioYou",
//         "_ratioThem",
//         "_responsiblePlayerName",
//         "_killerSide",
//         "_badgeText",
//         "_badgeLevel",
//         "_badgeIcon",
//         "_hitPoints",
//         "_projectileHitArray"
//     ];

//     private _projectileHits = _projectileHitArray select [0, 5];
//     private _offset = (5 - count _projectileHits) * 0.03;
//     _projectileHits = _projectileHits apply {
//         _x params ["_hitTime", "_hitText"];
//         format ["<t color='%1'>%2 (%3 ms)</t>", SQD_COLOR_LOCKED, _hitText, _hitTime]
//     };

//     private _statusInfo = format [
//         "<t size='0.45' align='center'>KILLED BY</t><br/><t size='0.35' align='center'>%2 [%3]<br/><t size='0.25'>YOU</t> %4 - %5 <t size='0.25'>THEM</t><br/><t size='0.32'>%6</t></t>",
//         _statusName,
//         _responsiblePlayerName,
//         _killerText,
//         _ratioYou,
//         _ratioThem,
//         _projectileHits joinString "<br/>"
//     ];

//     _killStatusText ctrlSetStructuredText parseText _statusInfo;
//     _killStatusText ctrlSetPosition [
//         safeZoneX + 0.8,
//         safeZoneY + safeZoneH - 0.4 + _offset,
//         safeZoneW - 0.1 - 0.1 - 0.8 - 0.6,
//         0.3 - _offset
//     ];
//     _killStatusText ctrlCommit 0;
//     _killStatusText ctrlShow true;
// };