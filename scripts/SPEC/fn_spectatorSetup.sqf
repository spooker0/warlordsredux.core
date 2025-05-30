#include "constants.inc"

private _projectiles = [];
uiNamespace setVariable ["WL2_projectiles", _projectiles];
private _camera = objNull;

waitUntil {
    _camera = missionNamespace getVariable [SPEC_VAR_CAM, objNull];
    !isNull _camera;
};

_camera camCommand "ceilingHeight 15000";

while { WL_IsSpectator } do {
    private _maxDistance = uiNamespace getVariable ["WL_SpectatorHudMaxDistance", 10000];
    private _allVehicles = (vehicles + allUnits);

    _projectiles = _projectiles select {
        alive _x && _x distance _camera < _maxDistance
    };

    {
        private _vehicle = _x;

        private _unitSpawnedEventListener = _vehicle getVariable ["SPEC_unitSpawnedEventListener", false];
        if (_unitSpawnedEventListener) then {
            continue;
        };
        _vehicle setVariable ["SPEC_unitSpawnedEventListener", true];

        _vehicle addEventHandler ["Fired", SPEC_fnc_spectatorOnFired];
    } forEach _allVehicles;

    private _locations = [];
    private _relevantSectors = BIS_WL_allSectors select {
        _x == WL2_base1 || _x == WL2_base2 ||
        _x == WL_TARGET_ENEMY || _x == WL_TARGET_FRIENDLY ||
        _x getVariable ["BIS_WL_owner", independent] != independent
    };

    _relevantSectors = [_relevantSectors, [], { ((_x getVariable "objectAreaComplete") # 0) distance WL2_base1 }, "ASCEND"] call BIS_fnc_sortBy;

    {
        private _id = format ["loc%1", _forEachIndex];
        private _name = _x getVariable ["WL2_name", "Sector"];
        private _owner = _x getVariable ["BIS_WL_owner", independent];
        private _description = switch (_owner) do {
            case west: {
                "BLUFOR"
            };
            case east: {
                "OPFOR"
            };
            case independent: {
                "INDEPENDENT"
            };
        };
        private _texture = switch (_owner) do {
            case west: {
                "\A3\ui_f\data\map\markers\nato\b_installation.paa";
            };
            case east: {
                "\A3\ui_f\data\map\markers\nato\o_installation.paa";
            };
            case independent: {
                "\A3\ui_f\data\map\markers\nato\n_installation.paa";
            };
        };
        private _sectorPos = (_x getVariable "objectAreaComplete") # 0;
        _sectorPos set [2, 200];

        private _cameraTransform = [
            _sectorPos,
            [0, 1, 0],
            [0, 0, -1]
        ];
        _locations pushBack [_id, _name, _description, _texture, _cameraTransform, 0];
    } forEach _relevantSectors;
    missionNamespace setVariable ["BIS_EGSpectator_locations", _locations];

    {
        private _owner = _x getVariable ["BIS_WL_owner", independent];
        [_x, _owner] call WL2_fnc_sectorMarkerUpdate;
    } forEach BIS_WL_allSectors;

    "BIS_WL_targetEnemy" setMarkerPosLocal getPosASL WL_TARGET_ENEMY;
    "BIS_WL_targetEnemy" setMarkerAlphaLocal 1;
    "BIS_WL_targetEnemy" setMarkerDirLocal 45;
    "BIS_WL_targetFriendly" setMarkerPosLocal getPosASL WL_TARGET_FRIENDLY;
    "BIS_WL_targetFriendly" setMarkerAlphaLocal 1;

    sleep 5;
};