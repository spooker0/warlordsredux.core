private _lockState = uiNamespace getVariable ["WL2_cruiseMissileLockState", "NONE"];
if (_lockState != "NONE") exitWith {
    systemChat "Cruise missile strike in progress. Please wait.";
    playSoundUI ["AddItemFailed"];
};

// Find launching carrier
private _carrierSectors = (BIS_WL_sectorsArray # 0) select {
    _x getVariable ["WL2_isAircraftCarrier", false]
};
if (count _carrierSectors == 0) exitWith {
    systemChat "No aircraft carriers available for cruise missile strike.";
    playSoundUI ["AddItemFailed"];
};

uiNamespace setVariable ["WL2_cruiseMissileTargets", []];
uiNamespace setVariable ["WL2_cruiseMissileLockState", "LOCKING"];

private _instructionDisplay = uiNamespace getVariable ["RscWLCruiseMissileDisplay", displayNull];
if (isNull _instructionDisplay) then {
    "cruiseMissile" cutRsc ["RscWLCruiseMissileDisplay", "PLAIN", -1, true, true];
    _instructionDisplay = uiNamespace getVariable ["RscWLCruiseMissileDisplay", displayNull];
};
private _enemyText = _instructionDisplay displayCtrl 31001;
private _instructionText = _instructionDisplay displayCtrl 31002;

_enemyText ctrlShow false;
_instructionText ctrlShow true;

player selectWeapon (binocular player);

private _cruiseMissleInterface = addMissionEventHandler ["Draw3D", {
    private _targets = uiNamespace getVariable ["WL2_cruiseMissileTargets", []];
    private _lockState = uiNamespace getVariable ["WL2_cruiseMissileLockState", "LOCKING"];

    {
        private _target = _x;
        if (!alive _target) then {
            continue;
        };
        private _targetPos = _target modelToWorldVisual [0, 0, 0];

        // Draw target marker
        drawIcon3D [
            "\A3\ui_f\data\IGUI\Cfg\Cursors\lock_target_ca.paa",
            [1, 0, 0, 1],
            _targetPos,
            0.8,
            0.8,
            0,
            format ["%1 %2", _lockState, _forEachIndex + 1],
            true,
            0.035,
            "RobotoCondensedBold",
            "center",
            true,
            0,
            0.02
        ];
    } forEach _targets;
}];

private _designatingTargets = true;
private _strikeCancelled = false;
private _side = BIS_WL_playerSide;

private _findCoverageGreedy = {
    params ["_targets", "_circleRadius"];

    private _numTargets = count _targets;
    private _neighborhoods = [];

    {
        private _target1 = _x;
        private _target1Pos = getPosASL _target1;
        private _coverSet = [];

        {
            private _target2 = _x;
            private _target2Pos = getPosASL _target2;
            private _dist = _target1Pos distance _target2Pos;

            if (_dist <= _circleRadius) then {
                _coverSet pushBack _forEachIndex;
            };
        } forEach _targets;

        _neighborhoods pushBack _coverSet;
    } forEach _targets;

    private _uncovered = [];
    {
        _uncovered pushBack _forEachIndex;
    } forEach _targets;

    private _selectedCenters = [];

    while { count _uncovered > 0 } do {
        private _bestIndex = -1;
        private _bestCoveredCount = -1;

        {
            private _covered = _x;
            private _intersect = _covered select { _x in _uncovered };

            if (count _intersect > _bestCoveredCount) then {
                _bestIndex = _forEachIndex;
                _bestCoveredCount = count _intersect;
            };
        } forEach _neighborhoods;

        // Add best center
        private _selectedTarget = _targets select _bestIndex;
        _selectedCenters pushBack _selectedTarget;

        // Remove covered targets from uncovered
        {
            _uncovered deleteAt (_uncovered find _x);
        } forEach (_neighborhoods select _bestIndex);
    };

    _selectedCenters
};

waitUntil {
    inputMouse 0 == 0;
};

private _targets = [];
while { _designatingTargets } do {
    private _position = screenToWorld [0.5, 0.5];

    // Detect in area
    private _targetsOnDatalink = (listRemoteTargets _side) select {
        private _target = _x # 0;
        private _targetSide = [_target] call WL2_fnc_getAssetSide;

        private _targetTime = _x # 1;
        _targetTime >= -10 && _targetSide != _side && alive _target && _position distance _target < 2000;
    } apply { _x # 0 };

    private _infantryOnDatalink = _targetsOnDatalink select { _x isKindOf "Man" };
    private _vehiclesOnDatalink = _targetsOnDatalink select { !(_x isKindOf "Man") };

    _targets = [];
    private _infantryCoverage = [_infantryOnDatalink, 50] call _findCoverageGreedy;
    {
        _targets pushBack _x;
    } forEach _infantryCoverage;

    {
        _targets pushBack _x;
    } forEach _vehiclesOnDatalink;

    _targets = [_targets, [], { _x distance player }, "ASCEND"] call BIS_fnc_sortBy;

    uiNamespace setVariable ["WL2_cruiseMissileTargets", _targets];

    if (inputMouse 0 > 0) then {
        if (count _targets > 0) then {
            _designatingTargets = false;
            break;
        } else {
            systemChat "No targets found for cruise missile strike. Check datalink, re-target, and try again.";
            playSoundUI ["AddItemFailed"];
        };
    };

    if (inputAction "navigateMenu" == 1) then {
        _designatingTargets = false;
        _strikeCancelled = true;
        break;
    };

    sleep 0.2;
};


"cruiseMissile" cutText ["", "PLAIN"];

if (_strikeCancelled) exitWith {
    removeMissionEventHandler ["Draw3D", _cruiseMissleInterface];
    uiNamespace setVariable ["WL2_cruiseMissileLockState", "NONE"];
    systemChat "Cruise missile strike cancelled.";
    playSoundUI ["AddItemFailed"];
};

uiNamespace setVariable ["WL2_cruiseMissileLockState", "LOCKED"];

playSoundUI ["AddItemOk"];
player sideRadio "mp_groundsupport_70_tacticalstrikeinbound_BHQ_1";

private _sortedCarriers = [_carrierSectors, [], { _x distance player }, "ASCEND"] call BIS_fnc_sortBy;
private _launchCarrier = _sortedCarriers # 0;
private _launchPosition = getPosASL _launchCarrier;
_launchPosition set [2, 2000];

// Summarize strike
[player, "cruiseMissiles"] remoteExec ["WL2_fnc_handleClientRequest", 2];
systemChat format ["Launching %1 cruise missiles from %2.", count _targets, _launchCarrier getVariable ["WL2_name", "Carrier"]];
[] remoteExec ["WL2_fnc_cruiseMissileWarning", BIS_WL_enemySide, false];

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
            _missile setVelocityModelSpace [0, 300, 0];

            if (alive _target) then {
                private _targetPos = getPosASL _target;
                if (_missile distance _laser > 500 && !_terminal) then {
                    _laser setPosASL (_targetPos vectorAdd [0, 0, 500]);
                    _missile setMissileTarget [_laser, true];
                } else {
                    _terminal = true;
                    _missile setMissileTarget [_target, true];
                };
                _lastTargetPos = _targetPos;
            } else {
                _laser setPosASL _lastTargetPos;
                _missile setMissileTarget [_laser, true];
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

private _startTime = serverTime;
waitUntil {
    count (_missiles select { alive _x }) == 0 ||
    (serverTime - _startTime) > 120
};

removeMissionEventHandler ["Draw3D", _cruiseMissleInterface];
uiNamespace setVariable ["WL2_cruiseMissileLockState", "NONE"];