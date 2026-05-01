#include "includes.inc"
params ["_fastTravelMode", "_location"];

// Fast Travel Modes
// 0: Seized Sector
// 1: Contested Sector
// 2: Air Assault
// 3: Vehicle Paradrop
// 4: Tent
// 5: Stronghold
// 6: Forward Base
// 7: Vehicle Paradrop FOB
// 8: Near Stronghold

openMap [false, false];

"Fast_travel" call WL2_fnc_announcer;

private _destination = [];
private _strongholdHasSpot = false;

switch (_fastTravelMode) do {
	case 0: {
		private _homeBase = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
		if (_homeBase == _location && WL_TARGET_ENEMY != _homeBase) then {
			_destination = _homeBase modelToWorld [0, 0, 0];
		} else {
			_destination = selectRandom ([_location] call WL2_fnc_findSpawnsInSector);
		};
	};
	case 1: {
		private _area = WL_TARGET_FRIENDLY getVariable "WL2_objectArea";
		private _size = if (_area # 3) then {
			sqrt (((_area # 0) ^ 2) + ((_area # 1) ^ 2));
		} else {
			(_area # 0) max (_area # 1);
		};
		private _distance = _size + WL_FAST_TRAVEL_OFFSET;
		private _position = WL_TARGET_FRIENDLY getPos [_distance, WL_TARGET_FRIENDLY getDir player];
		_position set [2, 0];
		_destination = _position;
		[player, "fastTravelContested"] remoteExec ["WL2_fnc_handleClientRequest", 2];
	};
	case 2: {
		private _area = WL_TARGET_FRIENDLY getVariable "WL2_objectArea";
		private _size = if (_area # 3) then {
			sqrt (((_area # 0) ^ 2) + ((_area # 1) ^ 2));
		} else {
			(_area # 0) max (_area # 1);
		};

		private _distance = _size + WL_FAST_TRAVEL_OFFSET;

		private _position = WL_TARGET_FRIENDLY getPos [_distance, WL_TARGET_FRIENDLY getDir player];

		_destination = [_position # 0, _position # 1, 250 + _distance * 0.75];
		[player, "fastTravelAirAssault"] remoteExec ["WL2_fnc_handleClientRequest", 2];
	};
	case 3: {
		private _safeSpot = selectRandom ([_location] call WL2_fnc_findSpawnsInSector);
		_destination = [_safeSpot # 0, _safeSpot # 1, 50];
	};
	case 4: {
		private _respawnBag = player getVariable ["WL2_respawnBag", objNull];
        if (!isNull _respawnBag) then {
            _destination = _respawnBag modelToWorld [0, 0, 0];
        };
	};
	case 5: {
		private _stronghold = _location getVariable ["WL_stronghold", objNull];
		private _posArr = _stronghold buildingPos -1;
		_destination = if (count _posArr > 0) then {
			_strongholdHasSpot = true;
			selectRandom _posArr;
		} else {
			getPosATL _stronghold;
		};
	};
	case 6;
	case 7: {
		_destination = selectRandom ([_location] call WL2_fnc_findSpawnsInArea);
		_destination = [_destination # 0, _destination # 1, 50];
	};
	case 8: {
		private _stronghold = _location getVariable ["WL_stronghold", objNull];
		private _strongholdRadius = _stronghold getVariable ["WL_strongholdRadius", 0];
		private _randomDir = random 360;
		private _randomDist = _strongholdRadius + random 10;
		_destination = _stronghold getPos [_randomDist, _randomDir];
	};
};

if (count _destination != 3 || _destination isEqualTo [0, 0, 0]) exitWith {
	["Fast travel failed, no valid position found."] call WL2_fnc_smoothText;
};

private _tagAlong = (units player) select {
	isNull objectParent _x
} select {
	alive _x
} select {
	_x != player
} select {
	_x distance player < 200
} select {
	_x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
} select {
	_x getVariable ["WL2_aiFollow", true]
};

private _directionToSector = if (isNil "_location") then {
	getDir player
} else {
	if (_location isEqualType []) then {
		private _finalPoint = if (count _location == 3) then {
			_location
		} else {
			_location # 0
		};
		_destination getDir _finalPoint;
	} else {
		_destination getDir _location;
	};
};

titleCut ["", "BLACK OUT", 1];

uiSleep 1;

switch (_fastTravelMode) do {
	case 0;
	case 1: {
		[format [localize "STR_A3_WL_popup_travelling", _location getVariable ["WL2_name", "Sector"]]] call WL2_fnc_smoothText;
		{
			_x setVehiclePosition [_destination, [], 3, "NONE"];
		} forEach _tagAlong;
		player setVehiclePosition [_destination, [], 0, "NONE"];

		player setDir _directionToSector;
	};
	case 2: {
		{
			_x setPosASL _destination;
			_x setDir _directionToSector;
			_x setVelocityModelSpace [0, 30, 0];
			[_x] spawn WL2_fnc_parachuteSetup;
		} forEach _tagAlong;

		player setPosASL _destination;
		player setDir _directionToSector;
		player setVelocityModelSpace [0, 30, 0];
		[player] spawn WL2_fnc_parachuteSetup;
	};
	case 3;
	case 7: {
		private _vehicle = vehicle player;

		private _parachuteClass = switch (BIS_WL_playerSide) do {
			case west: {
				"B_Parachute_02_F";
			};
			case east: {
				"O_Parachute_02_F";
			};
			case independent: {
				"I_Parachute_02_F";
			};
		};

		_destination set [2, 150];
		private _parachute = createVehicle [_parachuteClass, _destination, [], 0, "NONE"];
		_parachute setDir _directionToSector;
		_vehicle attachTo [_parachute, [0, 0, 0]];
		[_vehicle, _parachute] spawn {
			params ["_vehicle", "_parachute"];
			waitUntil {
				uiSleep 0.01;
				_parachute setVelocity [0, 0, -10];
				_parachute setVectorUp [0, 0, 1];
				private _alt = (getPosVisual _vehicle) # 2;
				_alt < 5;
			};
			detach _vehicle;
			deleteVehicle _parachute;

			uiSleep 0.5;
			_vehicle setVehiclePosition [getPosATL _vehicle, [], 0, "NONE"];
		};

        _vehicle setVariable ["WL2_paradropNextUse", serverTime + WL_COOLDOWN_PARADROP, true];
		[player, "fastTravelParadrop"] remoteExec ["WL2_fnc_handleClientRequest", 2];
	};
	case 4: {
        if (count _destination > 0) then {
            player setVehiclePosition [_destination, [], 0, "CAN_COLLIDE"];
			{
				_x setVehiclePosition [_destination, [], 3, "NONE"];
			} forEach _tagAlong;

			private _respawnBag = player getVariable ["WL2_respawnBag", objNull];
			if (!isNull _respawnBag) then {
				deleteVehicle _respawnBag;
			};
            player setVariable ["WL2_respawnBag", objNull];
        };
	};
	case 5: {
		if (_strongholdHasSpot) then {
			{
				_x setPosATL _destination;
			} forEach _tagAlong;

			player setPosATL _destination;
		} else {
			{
				_x setVehiclePosition [_destination, [], 3, "NONE"];
			} forEach _tagAlong;

			player setVehiclePosition [_destination, [], 0, "NONE"];
		};
	};
	case 6;
	case 8: {
		{
			_x setVehiclePosition [_destination, [], 3, "NONE"];
		} forEach _tagAlong;

		player setDir _directionToSector;
		player setVehiclePosition [_destination, [], 0, "NONE"];
	};
};

titleCut ["", "BLACK IN", 1];