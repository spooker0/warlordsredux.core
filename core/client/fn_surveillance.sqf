#include "includes.inc"
if (isDedicated) exitWith {};

private _surveillanceCamera = createVehicle ["Land_MultiScreenComputer_01_sand_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
private _position = [16084.1, 16995.5, 0];
_surveillanceCamera setPosATL _position;

private _marker = createMarkerLocal ["marker_surveillance_camera", _position];
_marker setMarkerTypeLocal "loc_move";
_marker setMarkerColorLocal "ColorRed";
_marker setMarkerAlphaLocal 1;

private _scenes = [
	["Ammolofi", [9199, 21553], 1242988],
	["Atsalis", [8484, 25057], 1779918],
	["Molos", [26868, 24538], 1519353],
	["Salt Flats", [23169, 18897], 1633925],
	["AAC", [11660, 11927], 878319],
	["Selakano", [21187, 7557], 413643]
];

{
	_x params ["_name", "_position", "_objectId"];
	private _object = _position nearestObject _objectId;
	if (isNull _object) then {
		continue;
	};
	_object setVariable ["WL2_manualDrone", true];
	_surveillanceCamera addAction [
		format ["<t color='#ff0000'>Check %1</t>", _name],
		{
			_this spawn {
				params ["_target", "_caller", "_actionId", "_argument"];
				private _camera = _argument;
				_camera switchCamera "External";
				uiSleep 8;
				switchCamera player;
			};
		},
		_object,
		100,
		false,
		true
	];
} forEach _scenes;