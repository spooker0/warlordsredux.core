#include "..\..\warlords_constants.inc"

if (isDedicated) exitWith {};

private _incomingMissileDisplay = uiNamespace getVariable ["RscWLIncomingMissileDisplay", objNull];
if (isNull _incomingMissileDisplay) then {
	"IncomingDisplay" cutRsc ["RscWLIncomingMissileDisplay", "PLAIN", -1, true, true];
	_incomingMissileDisplay = uiNamespace getVariable "RscWLIncomingMissileDisplay";
};

private _indicatorMissile = _incomingMissileDisplay displayCtrl 25000;
private _indicatorStatus = _incomingMissileDisplay displayCtrl 25001;
private _indicatorDistance = _incomingMissileDisplay displayCtrl 25002;

private _missileTypeData = createHashMapFromArray [
    ["M_Zephyr", "ZEPHYR"],
    ["M_Titan_AA_long", "TITAN"],
    ["ammo_Missile_mim145", "DEFENDER"],
    ["ammo_Missile_s750", "RHEA"],
    ["ammo_Missile_rim116", "SPARTAN"],
    ["ammo_Missile_rim162", "CENTURION"],
    ["M_70mm_SAAMI", "SAAMI"]
];

while { !BIS_WL_missionEnd } do {
    if (WL_HelmetInterface == 0) then {
        sleep 5;
        continue;
    };

    private _asset = cameraOn;
    private _incomingMissiles = _asset getVariable ["WL_incomingMissiles", []];
    _incomingMissiles = _incomingMissiles select { alive _x };

    private _missilesData = _incomingMissiles apply {
        private _missile = _x;
        private _missileState = _missile getVariable ["APS_missileState", "LOCKED"];
        private _distance = _missile distance _asset;
        private _relDir = _missile getRelDir _asset;
        private _missileApproaching = (_relDir < 90 || _relDir > 270) && !(_missileState in ["LOST", "NOTCHED"]);
        private _missileType = _missileTypeData getOrDefault [typeof _missile, "MISSILE"];
        private _missileRelDir = _asset getRelDir _missile;

        [_missileState, _distance, _missileApproaching, _missileType, _missileRelDir];
    };
    _missilesData = [_missilesData, [], {
        _x # 1 + (if (_x # 2) then { 0 } else { 100000 })
    }, "ASCEND"] call BIS_fnc_sortBy;

    private _missileTypes = [];
    private _missileStates = [];
    private _missileDistances = [];

    {
        private _missileState = _x # 0;
        private _distance = _x # 1;
        private _missileApproaching = _x # 2;
        private _missileType = _x # 3;
        private _color = switch true do {
            case (!_missileApproaching): {
                "#000000"
            };
            case (_distance > 5000): {
                "#ffffff"
            };
            case (_distance > 2500): {
                "#ffff00"
            };
            default {
                "#ff0000"
            };
        };
        private _relDirText = format ["%1", round (_x # 4)];

        _missileTypes pushBack format ["<t color='%1'>%2</t>", _color, _missileType];
        _missileStates pushBack format ["<t color='%1'>%2</t>", _color, _missileState];
        _missileDistances pushBack format ["<t color='%1'>%2 [%3]</t>", _color, (_distance / 1000) toFixed 1, _relDirText];
    } forEach _missilesData;

    _indicatorMissile ctrlSetStructuredText parseText format ["<t size='0.6'>%1</t>", _missileTypes joinString "<br/>"];
    _indicatorStatus ctrlSetStructuredText parseText format ["<t size='0.6'>%1</t>", _missileStates joinString "<br/>"];
    _indicatorDistance ctrlSetStructuredText parseText format ["<t size='0.6' align='right'>%1</t>", _missileDistances joinString "<br/>"];

    sleep 0.001;
};