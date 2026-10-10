#include "includes.inc"
params ["_asset", "_caller"];

if (!alive _asset || !alive _caller || !local _asset) exitWith {};

private _capacity = WL_UNIT(_asset, "flareBursts", 0);
if (_capacity <= 0) exitWith {};

private _bursts = _asset getVariable ["DIS_flareBursts", 0];
private _readyAt = _asset getVariable ["DIS_flareReadyAt", 0];
if (_bursts <= 0 || serverTime < _readyAt) exitWith {
    if (hasInterface && _caller == player) then {
        playSoundUI ["AddItemFailed"];
    };
};

private _flareTime = serverTime;
private _immunityUntil = _flareTime + WL_FLARE_IMMUNITY;
_asset setVariable ["DIS_flareBursts", _bursts - 1, true];
_asset setVariable ["DIS_flareReadyAt", _flareTime + WL_UNIT(_asset, "flareReload", 8)];
_asset setVariable ["DIS_flareImmunityUntil", _immunityUntil, true];

private _incomingMissiles = _asset getVariable ["WL_incomingMissiles", []];
private _trackedMissiles = +_incomingMissiles;
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

[_asset] remoteExec ["DIS_fnc_flareEffects", 0];
