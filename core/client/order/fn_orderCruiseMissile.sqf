private _position = screenToWorld [0.5, 0.5];
private _side = BIS_WL_playerSide;

// Detect in area
private _targetsOnDatalink = (listRemoteTargets _side) select {
    private _target = _x # 0;
    private _targetSide = [_target] call WL2_fnc_getAssetSide;

    private _targetTime = _x # 1;
    _targetTime >= -10 && _targetSide != _side && alive _target && _position distance _target < 2000;
} apply { _x # 0 };

private _vehiclesOnDatalink = _targetsOnDatalink select {
    !(_x isKindOf "Man")
};

// Queue targets
private _targets = [];
if (count _targetsOnDatalink > 0) then {
    private _missilesToSend = ceil (count _targetsOnDatalink / 10);
    for "_i" from 1 to _missilesToSend do {
        private _target = selectRandom _targetsOnDatalink;
        _targets pushBack _target;
    };
};
if (count _vehiclesOnDatalink > 0) then {
    {
        _targets pushBack _x;
    } forEach _vehiclesOnDatalink;
};

if (count _targets == 0) exitWith {
    systemChat "No targets found for cruise missile strike. Check datalink, re-target, and try again.";
};

// Find launching carrier
private _carrierSectors = (BIS_WL_sectorsArray # 0) select {
    _x getVariable ["WL2_isAircraftCarrier", false]
};
if (count _carrierSectors == 0) exitWith {
    systemChat "No aircraft carriers available for cruise missile strike.";
};

player sideRadio "mp_groundsupport_70_tacticalstrikeinbound_BHQ_1";

private _sortedCarriers = [_carrierSectors, [], { _x distance player }, "ASCEND"] call BIS_fnc_sortBy;
private _launchCarrier = _sortedCarriers # 0;
private _launchPosition = getPosASL _launchCarrier;
_launchPosition set [2, 2000];

// Summarize strike
[player, "cruiseMissiles"] remoteExec ["WL2_fnc_handleClientRequest", 2];
systemChat format ["Launching %1 cruise missiles from %2.", count _targets, _launchCarrier getVariable ["BIS_WL_name", "Carrier"]];

// Launch
private _missiles = [];
{
    private _missile = createVehicle ["ammo_Missile_Cruise_01", _launchPosition, [], 0, "NONE"];
    private _laser = createVehicleLocal ["LaserTargetC", [0, 0, 0], [], 0, "NONE"];

    [_missile, [player, player]] remoteExec ["setShotParents", 2];

    if (!alive _x) then {
        continue;
    };

    [_missile, _laser, _x] spawn {
        params ["_missile", "_laser", "_target"];
        private _terminal = false;
        private _lastTargetPos = getPosASL _target;
        while { alive _missile } do {
            if (!alive _laser) then {
                _laser = createVehicleLocal ["LaserTargetC", [0, 0, 0], [], 0, "NONE"];
            };
            _missile setMissileTarget [_laser, true];
            _missile setVelocityModelSpace [0, 300, 0];

            if (alive _target) then {
                private _targetPos = getPosASL _target;
                if (_missile distance _laser > 500 && !_terminal) then {
                    _laser setPosASL (_targetPos vectorAdd [0, 0, 500]);
                } else {
                    _terminal = true;
                    _laser setPosASL _targetPos;
                };
                _lastTargetPos = _targetPos;
            } else {
                _laser setPosASL _lastTargetPos;
            };

            sleep 1;
        };

        sleep 3;
        deleteVehicle _laser;
        deleteVehicle _missile;
    };
    _missiles pushBack _missile;

    private _soundFiles = [
        "vlslaunch01",
        "vlslaunch02",
        "vlslaunch03"
    ];
    playSoundUI [selectRandom _soundFiles, 1, 1, true];
    sleep 2;
} forEach _targets;

systemChat format ["Launch complete.", count _missiles];
playSoundUI ["a3\dubbing_f\modules\supports\artillery_rounds_complete.ogg", 1, 1, true];

[_missiles # 0, player] spawn DIS_fnc_startMissileCamera;