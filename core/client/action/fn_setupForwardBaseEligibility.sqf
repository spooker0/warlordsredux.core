#include "..\..\warlords_constants.inc"
params ["_target", "_caller", "_upgrading"];

private _cursorObject = cursorObject;

private _spawned = _cursorObject getVariable ["WL_spawnedAsset", false];

if (!_spawned) exitWith {
    [false];
};

if (_caller != _caller) exitWith {
    [false];
};

if !(typeof _cursorObject in ["VirtualReammoBox_camonet_F", "RuggedTerminal_01_communications_hub_F"]) exitWith {
    [false];
};

private _squadMembersNeeded =
#if WL_FOB_SQUAD_REQUIREMENT
    3;
#else
    1;
#endif

if (!_upgrading && typeof _cursorObject == "VirtualReammoBox_camonet_F") exitWith {
    private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
    private _teamForwardBases = _currentForwardBases select {
        _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
    };
    private _fobCooldownVar = format ["WL2_forwardBaseCooldowns_%1", BIS_WL_playerSide];
    private _fobCooldowns = missionNamespace getVariable [_fobCooldownVar, []];
    private _isQualifyingSL = ["isSquadLeaderOfSize", [getPlayerID player, _squadMembersNeeded]] call SQD_fnc_client;

    private _result = [];
    switch (true) do {
        case (!alive _cursorObject): {
            _result = [false];
        };
        case (player distance _cursorObject > WL_MAINTENANCE_RADIUS): {
            _result = [false];
        };
        case (!isNull attachedTo _cursorObject || !isNull ropeAttachedTo _cursorObject): {
            _result = [false];
        };
        case (count _teamForwardBases + count _fobCooldowns >= 3): {
            private _limitReached = format ["Forward base limit reached. Current: %1, Cooldown: %2", count _teamForwardBases, count _fobCooldowns];
            _result = [true, _limitReached];
        };
        case (!_isQualifyingSL): {
            _result = [true, "You need at least 3 squad members to set up a forward base."];
        };
        case (_cursorObject getVariable ["WL2_forwardBaseLevel", 0] != 0): {
            _result = [true, "This forward base is still constructing."];
        };
        default {
            _result = [true, ""];
        };
    };
    _result;
};

if (_upgrading && typeof _cursorObject == "RuggedTerminal_01_communications_hub_F") exitWith {
    private _playerFunds = (missionNamespace getVariable "fundsDatabaseClients") get (getPlayerUID player);
    private _sideOwner = _cursorObject getVariable ["WL2_forwardBaseOwner", sideUnknown];

    private _result = [];
    switch (true) do {
        case (!alive _cursorObject): {
            _result = [false];
        };
        case (player distance _cursorObject > WL_MAINTENANCE_RADIUS): {
            _result = [false];
        };
        case (_sideOwner != BIS_WL_playerSide): {
            _result = [false];
        };
        case (_cursorObject getVariable ["WL2_forwardBaseTime", -1] > serverTime): {
            _result = [true, "This forward base is still upgrading."];
        };
        case (_cursorObject getVariable ["WL2_forwardBaseLevel", 0] >= 3): {
            _result = [true, "This forward base is already at maximum level."];
        };
        case (_playerFunds < WL_FOB_UPGRADE_COST): {
            _result = [true, format ["%1%2 required to upgrade.", [BIS_WL_playerSide] call WL2_fnc_getMoneySign, WL_FOB_UPGRADE_COST]];
        };
        default {
            _result = [true, ""];
        };
    };
    _result;
};

[false];