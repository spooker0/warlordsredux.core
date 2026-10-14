#include "includes.inc"
params ["_asset", "_caller"];

if (!alive _asset || !alive _caller || !local _asset) exitWith {};

private _flareConfig = WL_UNIT(_asset, "flares", []);
if (count _flareConfig == 0) exitWith {};

_flareConfig params ["_capacity", "_flareReload", "_flareJamDuration"];
if (_capacity <= 0) exitWith {};

private _bursts = _asset getVariable ["DIS_flareBursts", 0];
private _readyAt = _asset getVariable ["DIS_flareReadyAt", 0];
if (_bursts <= 0 || serverTime < _readyAt) exitWith {
    if (hasInterface && _caller == player) then {
        playSoundUI ["AddItemFailed"];
    };
};

private _singlesMode = _asset getVariable ["DIS_flareSinglesMode", false];
if (_singlesMode) then {
    _flareReload = _flareReload * 3;
    _flareJamDuration = _flareJamDuration * 3;
};

private _flareTime = serverTime;
private _immunityUntil = _flareTime + _flareJamDuration;
_asset setVariable ["DIS_flareBursts", _bursts - 1, true];
_asset setVariable ["DIS_flareReadyAt", _flareTime + _flareReload];
_asset setVariable ["DIS_flareImmunityUntil", _immunityUntil, true];

private _incomingMissiles = _asset getVariable ["WL_incomingMissiles", []];
private _trackedMissiles = +_incomingMissiles;
if (!_singlesMode) then {
    {
        private _window = [_asset, _x] call DIS_fnc_getFlareWindow;
        if (count _window == 0) then {
            continue;
        };

        private _missileDefeated = _x getVariable ["DIS_missileDefeated", false];
        if (_window # 4 && !_missileDefeated) then {
            _x setVariable ["DIS_missileDefeated", true, true];
        };
    } forEach _incomingMissiles;
};

if (_flareJamDuration > 0) then {
    [_asset, _trackedMissiles, _immunityUntil] spawn {
        params ["_asset", "_trackedMissiles", "_immunityUntil"];

        while { alive _asset && serverTime < _immunityUntil } do {
            private _incomingMissiles = _asset getVariable ["WL_incomingMissiles", []];
            {
                if (_x in _trackedMissiles) then {
                    continue;
                };

                private _window = [_asset, _x] call DIS_fnc_getFlareWindow;
                if (count _window == 0) then {
                    continue;
                };

                private _missileDefeated = _x getVariable ["DIS_missileDefeated", false];
                if (_missileDefeated) then {
                    continue;
                };

                _x setVariable ["DIS_missileDefeated", true, true];
            } forEach _incomingMissiles;

            uiSleep 0.5;
        };
    };
};

[_asset, _singlesMode] remoteExec ["DIS_fnc_flareEffects", 0];
