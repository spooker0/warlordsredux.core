#include "includes.inc"
params ["_fastTravelMode", "_marker"];

// Fast Travel Modes
// 0: Seized Sector
// 1: Contested Sector
// 2: Air Assault
// 3: Vehicle Paradrop
// 4: Tent
// 5: Stronghold
// 6: Forward Base
// 7: Vehicle Paradrop FOB

openMap [false, false];

"Fast_travel" call WL2_fnc_announcer;

private _destination = [];
private _sectorPos = if (isNil "BIS_WL_targetSector") then {
	[0, 0, 0];
} else {
	(BIS_WL_targetSector getVariable "objectAreaComplete") # 0;
};

private _strongholdHasSpot = false;

switch (_fastTravelMode) do {
	case 0: {
		_destination = selectRandom ([BIS_WL_targetSector] call WL2_fnc_findSpawnsInSector);
	};
	case 1: {
		_destination = selectRandom ([_marker] call WL2_fnc_findSpawnsInMarker);
		[player, "fastTravelContested"] remoteExec ["WL2_fnc_handleClientRequest", 2];
	};
	case 2: {
		private _randomPos = _marker call BIS_fnc_randomPosTrigger;
		private _distance = _randomPos distance2D BIS_WL_targetSector;
		private _height = _sectorPos # 2;
		_height = _height max 250;
		_destination = [_randomPos # 0, _randomPos # 1, _height + _distance * 0.75];

		[player, "fastTravelAirAssault"] remoteExec ["WL2_fnc_handleClientRequest", 2];
	};
	case 3: {
		private _safeSpot = selectRandom ([BIS_WL_targetSector] call WL2_fnc_findSpawnsInSector);
		_destination = [_safeSpot # 0, _safeSpot # 1, 50];
	};
	case 4: {
		private _respawnBag = player getVariable ["WL2_respawnBag", objNull];
        if (!isNull _respawnBag) then {
            _destination = _respawnBag modelToWorld [0, 0, 0];
        };
	};
	case 5: {
		private _stronghold = BIS_WL_targetSector getVariable ["WL_stronghold", objNull];
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
		_destination = selectRandom ([_marker] call WL2_fnc_findSpawnsInMarker);
		_destination = [_destination # 0, _destination # 1, 50];
		deleteMarker _marker;
	};
};

if (count _destination != 3 || _destination isEqualTo [0, 0, 0]) exitWith {
	systemChat "Fast travel failed, no valid position found.";
};

private _tagAlong = (units player) select {
	(isNull objectParent _x) &&
	(alive _x) &&
	(_x != player) &&
	_x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
};

private _directionToSector = _destination getDir _sectorPos;

titleCut ["", "BLACK OUT", 1];

sleep 1;

switch (_fastTravelMode) do {
	case 0;
	case 1: {
		[toUpper format [localize "STR_A3_WL_popup_travelling", BIS_WL_targetSector getVariable "WL2_name"], nil, 3] spawn WL2_fnc_smoothText;
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
				sleep 0.2;
				_parachute setVelocity [0, 0, (velocity _parachute) # 2];
				_parachute setVectorUp [0, 0, 1];
				(getPosATL _vehicle # 2) < 5
			};
			detach _vehicle;
			deleteVehicle _parachute;

			sleep 0.5;
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
            player setVariable ["WL2_respawnBag", objNull, [2, clientOwner]];
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
	case 6: {
		{
			_x setVehiclePosition [_destination, [], 3, "NONE"];
		} forEach _tagAlong;

		player setVehiclePosition [_destination, [], 0, "NONE"];
	};
};

titleCut ["", "BLACK IN", 1];