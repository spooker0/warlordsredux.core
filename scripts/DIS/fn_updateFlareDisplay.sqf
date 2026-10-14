#include "includes.inc"
params ["_display", "_header", "_controls", "_showIncoming"];

disableSerialization;

private _asset = cameraOn;
private _flareConfig = WL_UNIT(_asset, "flares", []);
private _capacity = if (count _flareConfig > 0) then { _flareConfig # 0 } else { 0 };
private _missiles = [];
private _missileInWindow = false;
private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];

if (_capacity > 0 && alive _asset) then {
    private _bursts = _asset getVariable ["DIS_flareBursts", 0];
    private _readyAt = _asset getVariable ["DIS_flareReadyAt", 0];
    private _immunityUntil = _asset getVariable ["DIS_flareImmunityUntil", 0];
    private _reload = (_readyAt - serverTime) max 0;
    private _immunity = (_immunityUntil - serverTime) max 0;

    private _key = (actionKeysNames ["launchCM", 1, "Keyboard"]) regexReplace ["""", ""];
    private _modeKey = (actionKeysNames ["nextCM", 1, "Keyboard"]) regexReplace ["""", ""];
    private _singlesMode = _asset getVariable ["DIS_flareSinglesMode", false];
    private _headerText = [_bursts, _capacity, _reload, _immunity, _singlesMode, _key, _modeKey] call DIS_fnc_flareHeaderText;
    _header ctrlSetStructuredText parseText _headerText;

    private _incomingMissiles = _asset getVariable ["WL_incomingMissiles", []];
    {
        private _missileDefeated = _x getVariable ["DIS_missileDefeated", false];
        if (!alive _x || _missileDefeated || !isNull attachedTo _x) then {
            continue;
        };

        private _window = [_asset, _x] call DIS_fnc_getFlareWindow;
        if (_showIncoming) then {
            _missiles pushBack [_x, _window];
        };

        if (count _window > 0 && { _window # 4 }) then {
            _missileInWindow = true;
        };
    } forEach _incomingMissiles;

    if (_showIncoming) then {
        _missiles = [_missiles, [_asset], {
            (_x # 0) distance _input0;
        }, "ASCEND"] call BIS_fnc_sortBy;
    };
};

private _soundId = uiNamespace getVariable ["DIS_flareWindowSound", -1];
private _flareWindowVolume = _settingsMap getOrDefault ["flareWindowVolume", 1];
if (_missileInWindow && _flareWindowVolume > 0) then {
    private _soundPlaying = _soundId >= 0 && count (soundParams _soundId) > 0;
    if (!_soundPlaying) then {
        _soundId = playSoundUI ["launchBeep", _flareWindowVolume];
        uiNamespace setVariable ["DIS_flareWindowSound", _soundId];
    };
} else {
    if (_soundId >= 0) then {
        stopSound _soundId;
        uiNamespace setVariable ["DIS_flareWindowSound", -1];
    };
};

private _rows = [];
if (count _missiles > 0) then {
    private _missileTypes = call DIS_fnc_getMissileType;
    _rows = _missiles apply {
        _x params ["_missile", "_window"];
        private _missileName = _missile getVariable ["WL2_missileNameOverride", _missileTypes getOrDefault [typeOf _missile, "MISSILE"]];
        if (count _window == 0) then {
            _window = [0, 0, 0, _missile distance _asset, false];
        };
        [_missileName, _window];
    };
};
private _fontScale = (_settingsMap getOrDefault ["targetingMenuFontSize", 18]) / 18;
[_display, _header, _controls, _rows, _fontScale] call DIS_fnc_drawFlareDisplay;
