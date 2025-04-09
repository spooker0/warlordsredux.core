#include "constants.inc"

private _spectatingPlayer = objNull;
private _spectatingPlayerScore = -1;

uiNamespace setVariable ["SPEC_spectateProjectile", false];

while { WL_IsSpectator } do {
    private _spectatorFocus = uiNamespace getVariable [SPEC_VAR_FOCUS, objNull];
    private _currentSpectatingPlayer = [_spectatorFocus, _spectatorFocus] call WL2_fnc_handleInstigator;
    private _currentScore = score _spectatingPlayer;

    if (_currentSpectatingPlayer != _spectatingPlayer) then {
        _spectatingPlayer = _currentSpectatingPlayer;
        _spectatingPlayerScore = score _spectatingPlayer;
    } else {
        if (_currentScore != _spectatingPlayerScore) then {
            _spectatingPlayerScore = _currentScore;
            playSoundUI ["hitmarker", 1, 1];
        };
    };

    if (inputAction "GetOver" > 0) then {
        waitUntil { inputAction "GetOver" == 0 };
        private _volume = getPlayerVoNVolume _spectatingPlayer;
        if (_volume == -1) then {
            continue;
        } else {
            if (_volume == 0) then {
                _spectatingPlayer setPlayerVoNVolume 1;
            } else {
                _spectatingPlayer setPlayerVoNVolume 0;
            };
        };
    };

    if (inputAction "binocular" > 0) then {
        waitUntil { inputAction "binocular" == 0 };
        playSoundUI ["a3\sounds_f\arsenal\weapons_static\hmg_127mm_static\hmg127mm_static_dry.wss"];
        private _existingFocus = uiNamespace getVariable ["SPEC_spectateProjectile", false];
        private _newFocus = !_existingFocus;
        uiNamespace setVariable ["SPEC_spectateProjectile", _newFocus];
        [_newFocus] call SPEC_fnc_spectatorUpdateBinocularIcon;
    };

    if (inputAction "compass" > 0) then {
        waitUntil { inputAction "compass" == 0 };
        call MENU_fnc_settingsMenuInit;
    };

    sleep 0.001;
};