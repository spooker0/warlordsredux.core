#include "includes.inc"
params ["_destroyerBase", "_mrls", "_controller", "_firstSpawn"];

waitUntil {
    uiSleep 1;
    (getPosASL _destroyerBase) isNotEqualTo [0,0,0];
};

_mrls addEventHandler ["Fired", {
    _this spawn {
        params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
        if (cameraOn != _unit) exitWith {};

        private _inRangeCalculation = [_unit] call DIS_fnc_calculateInRange;
        private _targetCoordinates = _inRangeCalculation # 3;
        _projectile setVariable ["DIS_targetCoordinates", _targetCoordinates];
        [_projectile, _unit] spawn DIS_fnc_gpsMunition;
        [_projectile, _unit] call DIS_fnc_startMissileCamera;

        private _currentAmmo = _unit magazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", [0]];
        private _newControllerImage = format [
            "#(rgb,512,512,3)text(1,1,""PuristaBold"",0.3,""#000000"",""#ffffff"",""AMMO\n%1"")",
            _currentAmmo
        ];

        private _controller = _unit getVariable ["WL2_destroyerController", objNull];
        _controller setObjectTextureGlobal [3, _newControllerImage];
    };
}];

if (!_firstSpawn) exitWith {};

private _destroyerParts = getArray (configFile >> "CfgVehicles" >> typeOf _destroyerBase >> "multiStructureParts");
private _destroyerPartsArray = [];

private _destroyerPos = getPosWorld _destroyerBase;
private _destroyerDir = getDir _destroyerBase;

private _destroyerPitchBank = _destroyerBase call bis_fnc_getPitchBank;
_destroyerPitchBank params [["_destroyerPitch", 0], ["_destroyerBank", 0]];

private _destroyerHullNumbers = _destroyerBase getVariable ["WL2_destroyerHullNumbers", [0, 0, 0]];
private _hullNum1 = _destroyerHullNumbers select 0;
private _hullNum2 = _destroyerHullNumbers select 1;
private _hullNum3 = _destroyerHullNumbers select 2;

{
    private _dummyClassName = _x select 0;
    private _dummyPosition = _x select 1;
    private _dummy = createVehicleLocal [_dummyClassName, _destroyerPos, [], 0, "CAN_COLLIDE"];
    // private _dummy = createSimpleObject [_dummyClassName, _destroyerPos, true];
    _dummy setDir _destroyerDir;

    [_dummy, _destroyerPitch, _destroyerBank] call bis_fnc_setPitchBank;

    private _destroyerPartPos = _destroyerBase modelToWorldWorld (_destroyerBase selectionPosition _dummyPosition);
    _dummy setPosWorld _destroyerPartPos;

    _destroyerPartsArray pushBack _dummy;

    _dummy allowDamage false;

    if (_dummyClassName == "Land_Destroyer_01_hull_01_F") then {
        _dummy setObjectTexture [0, format ["\A3\Boat_F_Destroyer\Destroyer_01\Data\Destroyer_01_N_0%1_co.paa", _hullNum1]];
        _dummy setObjectTexture [1, format ["\A3\Boat_F_Destroyer\Destroyer_01\Data\Destroyer_01_N_0%1_co.paa", _hullNum2]];
        _dummy setObjectTexture [2, format ["\A3\Boat_F_Destroyer\Destroyer_01\Data\Destroyer_01_N_0%1_co.paa", _hullNum3]];
    };

    private _doorNumber = getNumber (configFile >> "CfgVehicles" >> _dummyClassName >> "numberOfDoors");
    for "_i" from 1 to _doorNumber do {
        _dummy animateSource [format ["Door_%1_source", _i], 1];
    };

    if (_dummyClassName == "Land_Destroyer_01_hull_04_F") then {
        _dummy animateSource ["Door_Hangar_1_1_open", 1];
        _dummy animateSource ["Door_Hangar_1_2_open", 1];
        _dummy animateSource ["Door_Hangar_1_3_open", 1];
        _dummy animateSource ["Door_Hangar_2_1_open", 1];
        _dummy animateSource ["Door_Hangar_2_2_open", 1];
        _dummy animateSource ["Door_Hangar_2_3_open", 1];
    };

    _dummy setVariable ["WL2_doorsLocked", true];
} foreach _destroyerParts;

private _destroyerDir = getDir _destroyerBase;
private _destroyerProps = [];

private _staticProps = [
    ["Land_PortableDesk_01_olive_F", [-0.579102,-34.438,19.6331], 0],
    ["Land_PortableDesk_01_olive_F", [1.87598, -34.4341, 19.6326], 0],
    ["Land_PortableGenerator_01_sand_F", [-1.32324, -33.9192, 19.5646], 89.5469],
    ["Land_PortableServer_01_cover_olive_F", [-1.54688, -34.4224, 20.1178], -192.838],
    ["Land_DeskChair_01_sand_F", [-0.648438, -35.3083, 19.4113], -99.8427],
    ["Land_MultiScreenComputer_01_closed_sand_F", [1.00293, -34.3979, 20.3257], 56.4011],
    ["Land_laptop_03_closed_olive_F", [1.56152, -34.5183, 20.2523], -23.635],
    ["Land_IPPhone_01_olive_F", [1.94238, -34.489, 20.1216], -1.554],
    ["Land_BatteryPack_01_open_sand_F", [1.01367, -34.7173, 19.7958], 153.802],
    ["Land_BatteryPack_01_closed_sand_F", [1.21875, -34.3982, 19.6868], -1.62357],
    ["Land_PortableServer_01_sand_F", [1.15527, -34.5205, 19.3637], -3.05557],
    ["Land_DeskChair_01_black_F", [2.62598, -34.708, 19.4234], 152.338],
    ["Land_Router_01_sand_F", [2.79883, -34.4292, 20.1897], -177.399],
    ["Land_Plank_01_8m_F", [15, 0, 21.0], 90.0],
    ["Land_Plank_01_8m_F", [15, 0.8, 21.0], 90.0],
    ["Land_Plank_01_8m_F", [-15, 0, 21.0], -90.0],
    ["Land_Plank_01_8m_F", [-15, 0.8, 21.0], -90.0]
];

{
    private _className = _x select 0;
    private _propPosition = _x select 1;
    private _direction = _x select 2;

    private _staticProp = createSimpleObject [_className, _propPosition, true];
    _staticProp setDir (_direction + _destroyerDir);

    private _staticPropPos = _destroyerBase modelToWorldWorld _propPosition;
    _staticProp setPosWorld _staticPropPos;

    _staticProp allowDamage false;
    _staticProp enableSimulation false;

    _destroyerProps pushBack _staticProp;
} forEach _staticProps;

private _trolleyLocations = [
    [3.5, 16, 8],
    [-3.5, 16, 8]
];
{
    private _trolley = createVehicleLocal ["Land_ToolTrolley_02_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _trolley setDir (_destroyerDir + 180 * (_forEachIndex - 1));
    _trolley setPosWorld (_destroyerBase modelToWorldWorld _x);
    _trolley allowDamage false;
    _trolley addAction [
        "<t color='#00FF00'>Grab Traversal Tools</t>",
        {
            params ["_target", "_caller", "_actionId"];
            call WL2_fnc_grapple;
        },
        [],
        100,
        false,
        false,
        "",
        "cameraOn == player && player getVariable [""WL2_hasGrapple"", 0] <= 0",
        5,
        false
    ];

    _destroyerProps pushBack _trolley;
} forEach _trolleyLocations;

private _destroyerId = _destroyerBase getVariable ["WL2_destroyerId", 0];

private _ropeLocations = [
    [0, -110.5, 14],
    [0, 92, 10.5],
    [11, 60, 17],
    [-11, 60, 17],
    [19, 0.4, 21.5],
    [-19, 0.4, 21.5]
];
private _ropeDirections = [0, 180, 180, 180, 270, 90];
private _ropeMinLevel = [0, 0, 9, 9, 0, 0];

private _ropeMarkers = [];
{
    private _ropeLocation = _x;

    private _ropePosition = _destroyerBase modelToWorldWorld _ropeLocation;
    private _rope = createSimpleObject ["Land_Rope_F", _ropePosition, true];
    _rope setDir (getDir _destroyerBase + _ropeDirections # _forEachIndex);
    _rope setPosASL _ropePosition;
    _rope setVariable ["WL2_rappelRopeMinLevel", _ropeMinLevel # _forEachIndex];

    private _marker = format ["destroyer%1_rappel%2", _destroyerId, _forEachIndex];
    createMarkerLocal [_marker, _ropePosition];
    _marker setMarkerTypeLocal "loc_Quay";
    _marker setMarkerAlphaLocal 0.4;
    _marker setMarkerSizeLocal [0.7, 0.7];
    _ropeMarkers pushBack _marker;

    private _existingRopes = missionNamespace getVariable ["WL2_rappelRopes", []];
    _existingRopes pushBack _rope;
    missionNamespace setVariable ["WL2_rappelRopes", _existingRopes];

    _destroyerProps pushBack _rope;
} forEach _ropeLocations;

_controller addAction [
    "<t color='#FF0000'>Control Missile Battery</t>",
    {
        _this spawn {
            params ["_target", "_caller", "_actionId"];
            private _mrls = _target getVariable ["WL2_destroyerVLS", objNull];
            if (isNull _mrls) exitWith {
                ["Missile Battery not found."] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
            };
            _target setVariable ["WL2_controller", _caller, true];

            _mrls switchCamera "External";
            player remoteControl (crew _mrls select 0);

            uiNamespace setVariable ["WL2_usingVLS", true];
            private _areControlsReady = true;
            while {
                cameraOn == _mrls &&
                alive player &&
                lifeState player != "INCAPACITATED"
            } do {
                uiSleep 0.1;
            };

            uiNamespace setVariable ["WL2_usingVLS", false];
            _target setVariable ["WL2_controller", objNull, true];
        };
    },
    [],
    100,
    false,
    false,
    "",
    "isNull (_target getVariable [""WL2_controller"", objNull])",
    30,
    false
];

while { alive _destroyerBase } do {
    uiSleep 1;
};

{
    deleteVehicle _x;
} forEach _destroyerProps;

{
    deleteMarkerLocal _x;
} forEach _ropeMarkers;

private _destroyerPartPos = _destroyerPartsArray apply {
    [_x, getPosASL _x];
};

private _startTime = serverTime;
while { serverTime < _startTime + 120 } do {
    uiSleep 0.0001;
    {
        private _part = _x select 0;
        private _startPos = _x select 1;
        private _endPos = _startPos vectorAdd [0, 0, -75];

        private _vectorDir = vectorDir _part;
        private _vectorUp = vectorUp _part;

        _part setVelocityTransformation [
            _startPos,
            _endPos,
            [0, 0, 0],
            [0, 0, 0],
            _vectorDir,
            _vectorDir,
            _vectorUp,
            _vectorUp,
            (serverTime - _startTime) / 120
        ];
    } forEach _destroyerPartPos;
};

{
    deleteVehicle _x;
} forEach _destroyerPartsArray;