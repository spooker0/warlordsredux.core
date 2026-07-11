#include "includes.inc"
params ["_unit", "_killer", "_instigator"];
private _unitSide = [_unit] call WL2_fnc_getAssetSide;

private _isSpawnedAsset = _unit getVariable ["WL_spawnedAsset", false];
private _isUnitPlayer = isPlayer [_unit];
if !(_isSpawnedAsset || _isUnitPlayer) exitWith {};

private _alreadyHandled = _unit getVariable ["WL2_alreadyHandled", false];
if (_alreadyHandled) exitWith {};
_unit setVariable ["WL2_alreadyHandled", true];

if (_unit isKindOf "Man") then {
    private _unitPosition = getPosASL _unit;
    private _ownedSector = BIS_WL_allSectors select {
        _unitPosition inArea (_x getVariable "objectAreaComplete")
    };
    if (count _ownedSector > 0) then {
        private _deathSector = _ownedSector # 0;
        private _sectorOwner = _deathSector getVariable ["BIS_WL_owner", independent];
        if (_sectorOwner == _unitSide) then {
            private _sectorVulnerable = _deathSector in [BIS_WL_currentTarget_west, BIS_WL_currentTarget_east];
            if (_sectorVulnerable) then {
                private _sectorDefenders = _deathSector getVariable ["WL2_defenders", 0];
                private _maxSectorDefenders = _deathSector getVariable ["WL2_maxDefenders", 0];
                private _newSectorDefenders = (_sectorDefenders - 1) max 0;

                private _ratioBefore = _sectorDefenders / _maxSectorDefenders;
                private _ratioAfter = _newSectorDefenders / _maxSectorDefenders;

                switch (true) do {
                    case (_ratioBefore > 0.75 && _ratioAfter <= 0.75): {
                        [_deathSector, 75] call WL2_fnc_warnSectorDefenders;
                    };
                    case (_ratioBefore > 0.5 && _ratioAfter <= 0.5): {
                        [_deathSector, 50] call WL2_fnc_warnSectorDefenders;
                    };
                    case (_ratioBefore > 0.25 && _ratioAfter <= 0.25): {
                        [_deathSector, 25] call WL2_fnc_warnSectorDefenders;
                    };
                    case (_sectorDefenders > 0 && _newSectorDefenders <= 0): {
                        [_deathSector, 0] call WL2_fnc_warnSectorDefenders;
                    };
                    default {};
                };
                _deathSector setVariable ["WL2_defenders", _newSectorDefenders, true];
            };
        };
    };
};

private _children = _unit getVariable ["WL2_children", []];
{
    if (alive _x) then {
        _x setDamage [1, true, _killer, _instigator];
    };
} forEach _children;

private _stats = missionNamespace getVariable ["WL_stats", createHashMap];

private _assetActualType = WL_ASSET_TYPE(_unit);
private _deathStats = _stats getOrDefault [_assetActualType, createHashMap];
private _deathValue = _deathStats getOrDefault ["deaths", 0];
_deathStats set ["deaths", _deathValue + 1];
_stats set [_assetActualType, _deathStats];

private _responsiblePlayer = [_killer, _instigator] call WL2_fnc_handleInstigator;
if (!isPlayer _responsiblePlayer || (_unitSide == side group _responsiblePlayer)) then {
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
private _killerActualType = WL_ASSET_TYPE(_killer);

if (_isUnitPlayer && _unit isKindOf "Man") then {
    _victimEntry set ["deaths", (_victimEntry getOrDefault ["deaths", 0]) + 1];
    private _killMessage = if (isPlayer [_responsiblePlayer] && _responsiblePlayer != _unit) then {
        private _ffText = if (_unitSide == _killerSide) then {
            " (Friendly fire)"
        } else {
            ""
        };
        if (_killer isKindOf "Man") then {
            format["%1 was killed by %2.%3", name _unit, name _responsiblePlayer, _ffText];
        } else {
            private _assetType = WL_ASSET(_killerActualType, "name", "");
            if (_assetType == "") then {
                _assetType = getText (configFile >> "CfgVehicles" >> _killerActualType >> "displayName");
            };
            if (_assetType == "") then {
                format["%1 was killed by %2.%3", name _unit, name _responsiblePlayer, _ffText];
            } else {
                format["%1 was killed by %2 with %3.%4", name _unit, name _responsiblePlayer, _assetType, _ffText];
            };
        };
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
            round (0.5 * WL_ASSET(_assetActualType, "cost", 0) ^ 0.8);
        };

        private _spotReward = round (_killReward / 4.0);
        [_spotReward, getPlayerUID _lastSpotted, true, "Spot assist"] call WL2_fnc_fundsDatabaseWrite;
        [_unit, _spotReward, "Spot assist", WL_COLOR_SUPPORT] remoteExec ["WL2_fnc_killRewardClient", _lastSpotted];
    };
};