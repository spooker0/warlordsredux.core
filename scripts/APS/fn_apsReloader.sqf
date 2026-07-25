#include "includes.inc"

while { !BIS_WL_missionEnd } do {
    private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
    private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
    private _reloadableVehicles = _ownedVehicles select {
        private _apsType = _x getVariable ["APS_apsType", 0];
        _apsType >= 4;
    };

    {
        private _vehicle = _x;
        private _apsAmmo = _vehicle getVariable ["apsAmmo", 0];
        private _apsActive = _vehicle getVariable ["WL2_apsActivated", false];
        if (_apsAmmo > 0 && _apsActive) then {
            _vehicle setVariable ["WL2_apsReloadStarted", false];
            continue;
        };

        private _maxAmmo = [_vehicle] call APS_fnc_getMaxAmmo;
        if (_apsAmmo >= _maxAmmo) then {
            _vehicle setVariable ["WL2_apsReloadStarted", false];
            continue;
        };

        private _reloadStarted = _vehicle getVariable ["WL2_apsReloadStarted", false];
        if (!_reloadStarted) then {
            _vehicle setVariable ["APS_nextReloadTime", serverTime + WL_COOLDOWN_APS_RELOAD];
            _vehicle setVariable ["WL2_apsReloadStarted", true];
            continue;
        };

        private _nextReloadTime = _vehicle getVariable ["APS_nextReloadTime", 0];
        if (serverTime < _nextReloadTime) then {
            continue;
        };

        private _newAmmo = (_apsAmmo + 1) min _maxAmmo;
        _vehicle setVariable ["apsAmmo", _newAmmo, true];
        _vehicle setVariable ["APS_nextReloadTime", serverTime + WL_COOLDOWN_APS_RELOAD];

        if (_newAmmo >= _maxAmmo && !_apsActive) then {
            [_vehicle] call APS_fnc_toggle;
        };

        if (cameraOn == _vehicle) then {
            playSoundUI ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Rearm.wss", 0.5];
        };
    } forEach _reloadableVehicles;

    uiSleep 1;
};