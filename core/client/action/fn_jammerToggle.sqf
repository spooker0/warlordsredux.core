params ["_asset"];

if (_asset getVariable ["WL_ewNetActive", false] && isEngineOn _asset) then {
    _asset setVariable ["WL_ewNetActive", false, true];
    _asset setVariable ["WL_ewNetActivating", false, true];
    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_fatal.wss"];
} else {
    if (_asset getVariable ["WL_ewNetActivating", false]) exitWith {
        playSoundUI ["AddItemFailed"];
    };
    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_restart.wss"];

    _asset setVariable ["WL_ewNetActivating", true, true];

    if (!isEngineOn _asset) then {
        [_asset, true] remoteExec ["WL2_fnc_setDazzlerState", 2];
    };

    [_asset] spawn {
        params ["_asset"];
        playSound3D ["a3\data_f_curator\sound\cfgsounds\air_raid.wss", _asset, false, getPosASL _asset, 5, 0.375, 2500];

        private _startTime = serverTime;

        waitUntil {
            sleep 1;
            private _timePassed = serverTime - _startTime;
            private _spinSpeed = _timePassed / 20;
            _timePassed > 20;
        };

        if (alive _asset && isEngineOn _asset) then {
            _asset setVariable ["WL_ewNetActive", true, true];
            _asset setVariable ["WL_ewNetActivating", false, true];
        } else {
            _asset setVariable ["WL_ewNetActivating", false, true];
        };
    };
};