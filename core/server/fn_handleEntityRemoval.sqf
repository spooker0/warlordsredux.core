#include "includes.inc"
params ["_unit", "_killer", "_instigator"];

private _isSpawnedAsset = _unit getVariable ["WL_spawnedAsset", false];
private _isUnitPlayer = isPlayer [_unit];
if !(_isSpawnedAsset || _isUnitPlayer) exitWith {};

private _alreadyHandled = _unit getVariable ["WL2_alreadyHandled", false];
if (_alreadyHandled) exitWith {};
_unit setVariable ["WL2_alreadyHandled", true];

private _children = _unit getVariable ["WL2_children", []];
{
    deleteVehicle _x;
} forEach _children;

private _stats = missionNamespace getVariable ["WL_stats", createHashMap];

private _assetActualType = _unit getVariable ["WL2_orderedClass", typeOf _unit];
private _deathStats = _stats getOrDefault [_assetActualType, createHashMap];
private _deathValue = _deathStats getOrDefault ["deaths", 0];
_deathStats set ["deaths", _deathValue + 1];
_stats set [_assetActualType, _deathStats];

private _responsiblePlayer = [_killer, _instigator] call WL2_fnc_handleInstigator;
if (!isPlayer _responsiblePlayer || ([_unit] call WL2_fnc_getAssetSide) == (side group _responsiblePlayer)) then {
    private _lastHitter = _unit getVariable ["WL_lastHitter", objNull];
    if (!isNull _lastHitter) then {
        _responsiblePlayer = _lastHitter;
    };
};

if (_isUnitPlayer) then {	// use alt syntax to exclude vehicle kills
    [_unit, _responsiblePlayer, _killer] remoteExec ["WL2_fnc_deathInfo", _unit];
};

private _scoreboard = missionNamespace getVariable ["WL2_scoreboardData", createHashMap];
private _victimEntry = _scoreboard getOrDefault [getPlayerUID _unit, createHashMap];
private _killerEntry = _scoreboard getOrDefault [getPlayerUID _responsiblePlayer, createHashMap];

private _killerSide = side group _responsiblePlayer;
private _unitSide = [_unit] call WL2_fnc_getAssetSide;

if (_isUnitPlayer && _unit isKindOf "Man") then {
    _victimEntry set ["deaths", (_victimEntry getOrDefault ["deaths", 0]) + 1];
    private _killMessage = if (isPlayer [_responsiblePlayer] && _responsiblePlayer != _unit) then {
        private _ffText = if (_unitSide == _killerSide) then {
            " (Friendly fire)"
        } else {
            ""
        };
        format["%1 was killed by %2.%3", name _unit, name _responsiblePlayer, _ffText];
    } else {
        format["%1 was killed.", name _unit];
    };
    [_killMessage] remoteExec ["systemChat", 0];
};

if (isNull _responsiblePlayer) exitWith {};

private _unitCost = if (_unit isKindOf "Man") then {
    if (_isUnitPlayer) then { 60 } else { 30 };
} else {
    WL_ASSET(_assetActualType, "cost", 0);
};

private _killerActualType = _killer getVariable ["WL2_orderedClass", typeOf _killer];
private _killerStats = _stats getOrDefault [_killerActualType, createHashMap];
private _killerKillValue = _killerStats getOrDefault ["killValue", 0];
if (_unitCost > 0 && _responsiblePlayer != _unit) then {
    _killerStats set ["killValue", _killerKillValue + _unitCost];
    _stats set [_killerActualType, _killerStats];

    [_unit, _assetActualType, _killerEntry, _killerSide == _unitSide] call WL2_fnc_setScoreboardEntry;
};

_scoreboard set [getPlayerUID _unit, _victimEntry];
_scoreboard set [getPlayerUID _responsiblePlayer, _killerEntry];
missionNamespace setVariable ["WL2_scoreboardData", _scoreboard];

if (!isNull _responsiblePlayer && { isPlayer [_responsiblePlayer] }) then {
    // must be sync calls, type info may disappear in next frame
    [_unit, _responsiblePlayer] call WL2_fnc_killRewardHandle;
    [_unit, _responsiblePlayer] call WL2_fnc_friendlyFireHandleServer;

    if (_isUnitPlayer) then {
        diag_log format["PvP kill: %1_%2 was killed by %3_%4 from %5m", name _unit, getPlayerUID _unit, name _responsiblePlayer, getPlayerUID _responsiblePlayer, _unit distance _responsiblePlayer];
    };

    private _lastSpotted = _unit getVariable ["WL_lastSpotted", objNull];
    if (!isNull _lastSpotted && {_lastSpotted != _responsiblePlayer}) then {
        private _killReward = if (_unit isKindOf "Man") then {
            if (_isUnitPlayer) then { 60 } else { 30 };
        } else {
            round (0.7 * WL_ASSET(_assetActualType, "cost", 0) ^ 0.8);
        };

        private _spotReward = round (_killReward / 4.0);
        [_spotReward, getPlayerUID _lastSpotted] call WL2_fnc_fundsDatabaseWrite;
        [_unit, _spotReward, "Spot assist", "#228b22"] remoteExec ["WL2_fnc_killRewardClient", _lastSpotted];
    };
};

_unit spawn {
    params ["_unit"];
    if ((typeOf _unit) == "Land_IRMaskingCover_01_F") then {
        {
            _asset = _x;
            if !(alive _x) then {
                deleteVehicle _asset;
            };
        } forEach ((allMissionObjects "") select {(["BIS_WL_", str _x, false] call BIS_fnc_inString) && {!(["BIS_WL_init", str _x, false] call BIS_fnc_inString)}});
    };
    if ((typeOf _unit) == "Land_Pod_Heli_Transport_04_medevac_F" || {(typeOf _unit) == "B_Slingload_01_Medevac_F"}) then {
        deleteVehicle _unit;
    };
};