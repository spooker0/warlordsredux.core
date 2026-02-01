#include "includes.inc"
params [["_sender", objNull, [objNull]], ["_action", "", [""]], "_param1", "_param2", "_param3", "_param4", "_param5", "_param6"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != (owner _sender)) exitWith {};

private _uid = getPlayerUID _sender;

private _broadcastActionToSide = {
	params ["_side", "_message"];
	{
		[[_side, "Base"], _message] remoteExec ["commandChat", owner _x];
	} forEach (allPlayers select {side group _x == _side});
};

private _playerFunds = (serverNamespace getVariable "fundsDatabase") getOrDefault [_uid, 0];

private _addFunds = {
	params ["_amount", ["_accountUid", _uid], ["_countAsTeamEarning", true]];
	[_amount, _accountUid, _countAsTeamEarning] call WL2_fnc_fundsDatabaseWrite;
};

private _deductFunds = {
	params ["_cost"];
	private _hasFunds = _playerFunds >= _cost;
	if (_hasFunds) then {
		[-_cost, _uid] call WL2_fnc_fundsDatabaseWrite;
		true;
	} else {
		false;
	};
};

private _actionCost = switch (_action) do {
	case "orderAsset" : {
		private _paidFor = if (isNil "_param6") then { false } else { _param6 };
		if (_paidFor) then {
			0
		} else {
			WL_ASSET(_param3, "cost", 50001)
		};
	};
	case "resetVehicle" : { 10 };
	case "equip" : { _param1 max 0 };
	case "buyStronghold" : { WL_COST_STRONGHOLD };
	case "fortifyStronghold" : { WL_COST_FORTIFY };
	case "orderArsenal" : { WL_COST_ARSENAL };
	case "fastTravelContested" : { WL_COST_FTCONTESTED };
	case "fastTravelAirAssault" : { WL_COST_AIRASSAULT };
	case "fastTravelParadrop" : { WL_COST_PARADROP };
	case "fastTravelSquadLeader" : { WL_COST_FTSL };
	case "scan" : { WL_COST_SCAN };
	case "combatAir" : { WL_COST_COMBATAIR };
	case "debugCombatAir" : { WL_COST_COMBATAIR };
	case "targetReset" : { WL_COST_TARGETRESET };
	case "orderAI" : { WL_ASSET(_param1, "cost", 150) };
	case "buildABear" : { 300 };
	case "controlCollaborator" : { 2000 };
	case "camouflage" : { 500 };
	case "cruiseMissiles" : { 15000 };
	case "repairFOB" : { 500 };
	case "repairStronghold" : { WL_COST_STRONGHOLD / 2 };
	case "jetRTB" : { WL_COST_JETRTB };
	default { 0 };
};

// Deduct cost and exit early if funds are insufficient
if (_actionCost > 0 && { !([_actionCost] call _deductFunds) }) exitWith {};

if (_action == "orderAsset") exitWith {
	private _orderType = _param1;
	private _position = _param2;
	private _orderedClass = _param3;

	private _stats = missionNamespace getVariable ["WL_stats", createHashMap];
	private _orderedClassStats = _stats getOrDefault [_orderedClass, createHashMap];

	private _existingValue = _orderedClassStats getOrDefault ["buys", 0];
	_orderedClassStats set ["buys", _existingValue + 1];

	_stats set [_orderedClass, _orderedClassStats];
	missionNamespace setVariable ["WL_stats", _stats];

	switch (_orderType) do {
		case "air" : {
			[_sender, _position, _orderedClass, WL_ASSET(_param3, "cost", 50001)] spawn WL2_fnc_orderAir;
		};
		case "naval" : {
			[_sender, _position, _orderedClass] spawn WL2_fnc_orderWater;
		};
		default {
			private _direction = _param4;
			private _exactPosition = _param5;
			[_sender, _position, _orderedClass, _direction, _exactPosition] spawn WL2_fnc_orderGround;
		};
	};
};

if (_action == "resetVehicle") exitWith {
	private _asset = _param1;
	private _position = _param2;
	private _direction = _param3;

	_asset setVectorDirAndUp _direction;

	private _orderedClass = _asset getVariable ["WL2_orderedClass", typeOf _asset];
	private _isDemolishable = WL_ASSET(_orderedClass, "demolishable", 0) > 0;
	if (_isDemolishable) then {
		_asset setPosWorld _position;
	} else {
		_asset setVehiclePosition [_position, [], 0, "CAN_COLLIDE"];
	};
};

if (_action == "revived") exitWith {
	private _reward = _param1;
	[_reward] call _addFunds;
	[objNull, _reward, "Revived Teammate", "#228b22"] remoteExec ["WL2_fnc_killRewardClient", _sender];
};

if (_action == "spot") exitWith {
	private _reward = _param1;
	[_reward] call _addFunds;
	[objNull, _reward, "Recon", "#228b22"] remoteExec ["WL2_fnc_killRewardClient", _sender];
};

if (_action == "demolished") exitWith {
	private _steps = _param1;
	private _reward = 20 * _steps;
	[_reward] call _addFunds;
	[objNull, _reward, "Demolition", "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _sender];
};

if (_action == "orderArsenal") exitWith {
	0 remoteExec ["WL2_fnc_orderArsenal", remoteExecutedOwner];
};

if (_action == "immobilized") exitWith {
	private _reward = 50;
	[_reward] call _addFunds;
	[objNull, _reward, "Vehicle Disabled", "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _sender];
};

private _side = side group _sender;
if (_action == "scan") exitWith {
	private _sector = _param2;

	private _sectorName = _sector getVariable ["WL2_name", "???"];
	private _message = format ["%1 has initiated sector scan on %2.", name _sender, _sectorName];
	[_side, _message] call _broadcastActionToSide;

	private _spawnPos = getPosATL _sector;
	_spawnPos set [2, 500];

	private _uavGroup = createGroup _side;
	_uavGroup deleteGroupWhenEmpty true;

	private _uavType = if (_side == west) then {
		"B_UAV_02_F"
	} else {
		"O_UAV_02_F"
	};

	private _uav = createVehicle [_uavType, _spawnPos, [], 0, "FLY"];
	_uav setVehicleAmmo 0;
	_uav setVariable ["BIS_WL_ownerAsset", getPlayerUID _sender, true];
	_uav setVariable ["BIS_WL_ownerAssetSide", _side, true];
	_uav setVariable ["WL_spawnedAsset", true, true];

	_uav setPosASL (AGLtoASL _spawnPos);

	private _crewType = if (_side == west) then {
		"B_UAV_AI"
	} else {
		"O_UAV_AI"
	};

	private _pilot = _uavGroup createUnit [_crewType, _spawnPos, [], 0, "NONE"];
	_pilot moveInAny _uav;

	_uav lock 2;
	_uav setFuelConsumptionCoef 20;
	_uav setVariable ["WL2_accessControl", 7, true];

	private _waypoint = _uavGroup addWaypoint [_sector, 0];
	_waypoint setWaypointLoiterType "CIRCLE";

	[_sector, _uav] remoteExec ["WL2_fnc_sectorScanHandle", _side];
	[_sector, _uav, _side] spawn {
		params ["_sector", "_uav", "_side"];

		while {
			alive _uav &&
			fuel _uav > 0 &&
			_uav distance2D _sector < 1000 &&
			(_uav modelToWorld [0, 0, 0]) # 2 > 200
		} do {
			uiSleep 1;
		};
		if (!isNull _uav) then {
			deleteVehicle _uav;
		};

		private _lastScannedVar = format ["WL2_lastScanned_%1", _side];
		_sector setVariable [_lastScannedVar, serverTime, true];
	};
};

if (_action == "combatAir") exitWith {
	private _sector = _param2;

	private _sectorName = _sector getVariable ["WL2_name", "???"];
	private _sideName = [_side] call WL2_fnc_sideToFaction;

	private _friendlyMessage = format ["%1 has initiated combat air patrol over %2.", name _sender, _sectorName];
	[_side, _friendlyMessage] call _broadcastActionToSide;

	private _enemyMessage = format ["%1 has initiated combat air patrol over %2.", _sideName, _sectorName];
	private _enemySide = switch (_side) do {
		case west : { east };
		case east : { west };
		default { civilian };
	};
	[_enemySide, _enemyMessage] call _broadcastActionToSide;

	_sector setVariable ["WL2_combatAirActive", true, true];
	_sector setVariable ["WL2_combatAirRequester", _uid, true];
	_sector setVariable ["WL2_nextCombatAir", serverTime + WL_DURATION_CAP + WL_COOLDOWN_CAP, true];

	[_sector, _side] remoteExec ["WL2_fnc_combatAirHandle", 0];
	[_sector] spawn {
		params ["_sector"];

		uiSleep WL_DURATION_CAP;

		_sector setVariable ["WL2_combatAirActive", false, true];
	};
};

#if WL_CAP_DEBUG
if (_action == "debugCombatAir") exitWith {
	private _sector = _param2;

	private _sectorName = _sector getVariable ["WL2_name", "???"];
	private _sideName = [_side] call WL2_fnc_sideToFaction;

	private _friendlyMessage = format ["%1 has initiated debug combat air patrol over %2.", name _sender, _sectorName];
	[_side, _friendlyMessage] call _broadcastActionToSide;

	_sector setVariable ["WL2_combatAirActive", true, true];
	_sector setVariable ["WL2_combatAirRequester", _uid, true];
	_sector setVariable ["WL2_nextCombatAir", serverTime + WL_DURATION_CAP + WL_COOLDOWN_CAP, true];

	[_sector, independent] remoteExec ["WL2_fnc_combatAirHandle", 0];
	[_sector] spawn {
		params ["_sector"];

		uiSleep WL_DURATION_CAP;

		_sector setVariable ["WL2_combatAirActive", false, true];
	};
};
#endif

if (_action == "ftSupportPoints") exitWith {
	private _ftVehicle = _param1;
	private _unitsToMove = _param2;
	private _reward = 20;

	private _targets = [
		missionNamespace getVariable "BIS_WL_currentTarget_west",
		missionNamespace getVariable "BIS_WL_currentTarget_east"
	] select {
		!(isNull _x)
	};

	if ((_targets findIf {_sender inArea (_x getVariable "objectAreaComplete")}) != -1) then {
		_reward = _reward * 2;
	};
	_reward = _reward * _unitsToMove;

	private _ftVehicleOwner = _ftVehicle getVariable ["BIS_WL_ownerAsset", "123"];
	private _rewardStack = _ftVehicle getVariable ["BIS_WL_rewardedStack", createHashMap];
	private _ftOwnerPlayer = _ftVehicleOwner call BIS_fnc_getUnitByUID;

	private _senderLastReward = _rewardStack getOrDefault [getPlayerUID _sender, -1000];

	private _eligible = _senderLastReward + 60 <= serverTime && _ftVehicleOwner != _uid;
	if (_eligible) then {
		[_reward, _ftVehicleOwner] call WL2_fnc_fundsDatabaseWrite;

		_rewardStack set [getPlayerUID _sender, serverTime];
		_ftVehicle setVariable ["BIS_WL_rewardedStack", _rewardStack];

		[objNull, _reward, "Spawn reward", "#228b22"] remoteExec ["WL2_fnc_killRewardClient", _ftOwnerPlayer];
	};
};

if (_action == "targetReset") exitWith {
	missionNamespace setVariable [format ["WL_targetReset_%1", _side], true, true];
	["server", true] call WL2_fnc_updateSectorArrays;

	private _message = format ["%1 has initiated a vote to reset the target sector.", name _sender];
	[_side, _message] call _broadcastActionToSide;
};

if (_action == "fundsTransfer") exitWith {
	private _transferCost = WL_COST_FUNDTRANSFER;
	private _transferAmount = _param1;
	private _recipient = _param2;

	if (_sender getVariable ["WL2_afk", false]) exitWith {};
	if !([_transferCost + _transferAmount] call _deductFunds) exitWith {};

	[_transferAmount, getPlayerUID _recipient, false] call _addFunds;

	private _sentMoney = format ["%1%2", WL_MoneySign, _transferAmount];
	private _message = format [localize "STR_A3_WL_donate_cp", name _sender, name _recipient, _sentMoney];

	[_side, _message] call _broadcastActionToSide;
};

if (_action == "repair") exitWith {
	if ((!isNil {_param1}) && {_param1 <= serverTime}) then {
		_param3 setDamage _param2;
	};
};

if (_action == "kill") exitWith {
	_sender setDamage 1;
};

if (_action == "demine") exitWith {
	private _asset = _param1;
	private _targets = _param2;
	{
		_x setDamage [1, true, _asset, _sender];
	} forEach _targets;
};

if (_action == "secure") exitWith {
	private _target = _param1;
	_target setDamage 1;

	private _reward = 50;
	[_reward] call _addFunds;
	[objNull, _reward, "Secured", "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _sender];
};

if (_action == "10K") exitWith {
	if !(["(EU) #11", serverName] call BIS_fnc_inString) then {
		[10000, _uid, false] call WL2_fnc_fundsDatabaseWrite;
	};
};

if (_action == "updateZeus") exitWith {
	if (getPlayerUID _sender in (getArray (missionConfigFile >> "adminIDs"))) then {
		private _allEntities = entities [[], ["Logic"], true];
		private _allNonLocalEntities = _allEntities select { owner _x != 0 };
		{
			_x addCuratorEditableObjects [_allNonLocalEntities, true];
		} forEach allCurators;
	};
};

if (_action == "sectorReward") exitWith {
	private _reward = _param1;
	[_reward] call _addFunds;
};

if (_action == "secureAircraft") exitWith {
	private _reward = _param1;
	[_reward] call _addFunds;
};

if (_action == "droneExplode") exitWith {
	private _drone = vehicle _param1;
	private _expl = createVehicle ["HelicopterExploBig", getPos _drone, [], 0, "FLY"];
	_expl setPosWorld (getPosWorld _drone);
	_expl setShotParents [_drone, _sender];
	triggerAmmo _expl;
	deleteVehicle _drone;
};