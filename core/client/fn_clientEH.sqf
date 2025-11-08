#include "includes.inc"
addMissionEventHandler ["GroupIconClick", WL2_fnc_groupIconClickHandle];
addMissionEventHandler ["GroupIconOverEnter", WL2_fnc_groupIconEnterHandle];
addMissionEventHandler ["GroupIconOverLeave", WL2_fnc_groupIconLeaveHandle];

call WL2_fnc_playerEventHandlers;

addMissionEventHandler ["HandleChatMessage", {
	_this call WL2_fnc_handleChatMessages;	// intentional
}];

0 spawn {
	waituntil {uiSleep 0.1; !isnull (findDisplay 46)};
	private _display = findDisplay 46;
	_display displayAddEventHandler ["KeyUp", {
		_key = _this # 1;
		if (_key in actionKeys "Gear") then {
			WL_gearKeyPressed = false;
		};
	}];

	_display displayAddEventHandler ["KeyDown", {
		_this call WL2_fnc_handleKeypress;
	}];

	_display displayAddEventHandler ["KeyDown", {
		params ["_display", "_key"];
		private _currentMode = uiNamespace getVariable ["DIS_currentTargetingMode", "none"];
		switch (_currentMode) do {
			case "asam";
			case "esam";
			case "loal": {
				[_key, DIS_fnc_getTargetList, [DIS_fnc_getSamTarget, "NO TARGET", "WL2_selectedTargetAA"], "WL2_selectedTargetAA"] call DIS_fnc_handleKeypress;
			};
			case "gps": {
				[_key] call DIS_fnc_handleGPSKeypress;
			};
			case "remote": {
				[_key, DIS_fnc_getSquadList, [], "WL2_selectedTargetPlayer"] call DIS_fnc_handleKeypress;
			};
			case "sead": {
				[_key, DIS_fnc_getTargetList, [DIS_fnc_getSeadTarget, "TARGET: AUTO", "WL2_selectedTargetSEAD"], "WL2_selectedTargetSEAD"] call DIS_fnc_handleKeypress;
			};
			default {};
		};
	}];

	_display displayAddEventHandler ["KeyDown", {
		params ["_display", "_key", "_shift", "_ctrl", "_alt"];
		if (_key != 1) exitWith {};	// escape to kill scoreboard
		private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
		if !(isNull _display) then {
			_display closeDisplay 1;
			true;
		};
	}];

	_display displayAddEventHandler ["KeyUp", {
		params ["_display", "_key", "_shift", "_ctrl", "_alt"];
		private _isPressed = false;
		{
			_isPressed = _isPressed || [_x, _key, _shift, _ctrl, _alt] call WL2_fnc_isKeyPressed;
		} forEach actionKeys ["networkStats"];

		if (_isPressed) then {
			0 spawn WL2_fnc_interceptAction;
			0 spawn WL2_fnc_scoreboard;
		};
	}];

	_display displayAddEventHandler ["KeyUp", {
		params ["_display", "_key", "_shift", "_ctrl", "_alt"];
		private _isPressed = false;
		{
			_isPressed = _isPressed || [_x, _key, _shift, _ctrl, _alt] call WL2_fnc_isKeyPressed;
		} forEach actionKeys ["cycleThrownItems"];

		if (_isPressed) then {
			[cameraOn] call APS_fnc_toggle;
		};
	}];

	_display displayAddEventHandler ["KeyDown", {
		params ["_display", "_key"];
		if (alive player && lifeState player != "INCAPACITATED") exitWith {};
		if (_key in actionKeys "ActionContext" || _key in actionKeys "Action") then {
			["Select"] call WL2_fnc_deadActions;
			true;
		};
	}];

	_display displayAddEventHandler ["KeyUp", {
		params ["_display", "_key"];
		if (alive player && lifeState player != "INCAPACITATED") exitWith {};
		if (_key in actionKeys "ActionContext" || _key in actionKeys "Action") then {
			["Unselect"] call WL2_fnc_deadActions;
			true;
		};
	}];

	_display displayAddEventHandler ["MouseZChanged", {
		params ["_displayOrControl", "_scroll"];
		if (alive player && lifeState player != "INCAPACITATED") exitWith {};
		private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
		if (!isNull _display) exitWith {};

		if (_scroll < 0) then {
			["Next"] call WL2_fnc_deadActions;
			true;
		};
		if (_scroll > 0) then {
			["Previous"] call WL2_fnc_deadActions;
			true;
		};
	}];

	// intentionally separate handler
	_display displayAddEventHandler ["KeyDown", {
		private _key = _this # 1;
		[_key] call WL2_fnc_handleBuyMenuKeypress;
	}];

	addUserActionEventHandler ["Eject", "Activate", {
		private _vehicle = vehicle player;
		if (_vehicle isKindOf "Plane" && speed _vehicle > 1) then {
			playSoundUI ["a3\sounds_f_jets\vehicles\air\shared\fx_plane_jet_ejection_in.wss"];
			moveOut player;
			[player] spawn WL2_fnc_parachuteSetup;
		};
	}];

	while { !BIS_WL_missionEnd } do {
		private _purchaseMenu = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
		if (isNull _purchaseMenu) then {
			WL_GEAR_BUY_MENU = false;
			WL_CONTROL_MAP ctrlEnable true;
		};
		uiSleep 1;
	};
};

//***Fetch price from requisitions.hpp using "priceHash getOrDefault [typeOf _asset, 200]"***/
priceHash = createHashMap;
_fullList = (missionNamespace getVariable (format ["WL2_purchasable_%1", side player]));
{
	if (_forEachIndex < 7) then {
		_category = _x;
		{
			_x params["_name", "_cost"];
			priceHash set [_name, _cost]
		} forEach _category;
	};
} forEach _fullList;

addMissionEventHandler ["EntityCreated", {
	params ["_entity"];
	if (!local _entity) exitWith {};
	_entityType = (typeOf _entity);
	if (isClass (configFile >> "CfgAmmo" >> _entityType)) then {
		_minesDB = (missionNamespace getVariable [format ["BIS_WL2_minesDB_%1", getPlayerUID player], []]);
		if ((_minesDB getOrdefault [_entityType, 0]) isEqualType []) then {
			_limit = (_minesDB get _entityType) # 0;
			_mines = ((_minesDB get _entityType) # 1) select {alive _x};
			if (count _mines >= _limit) then {
				private _t = _mines find objNull;
				if (_t != -1) then {_mines deleteAt _t;};
					if (count _mines >= _limit) then {
						deleteVehicle _entity;
						missionNameSpace setVariable ["mineDisplayActive", serverTime + 5];
						return;
					} else {
						_mines pushBack _entity;
						_minesDB set [_entityType, [_limit, _mines]];
					};
				} else {
				_mines pushBack _entity;
				_minesDB set [_entityType, [_limit, _mines]];
			};
			missionNameSpace setVariable ["mineDisplayActive", serverTime + 5];
			missionNamespace setVariable [format ["BIS_WL2_minesDB_%1", getPlayerUID player], _minesDB, [2, clientOwner]];
		};
	};
}];

addMissionEventHandler ["EntityRespawned", {
	params ["_newEntity", "_oldEntity"];
	private _wasMan = _oldEntity getEntityInfo 0;
	if (_wasMan) then {
		removeAllActions _oldEntity;
	};
}];

addMissionEventHandler ["PlayerViewChanged", {
	params ["_oldUnit", "_newUnit", "_vehicleIn", "_oldCameraOn", "_newCameraOn", "_uav"];
	if (isNull _newCameraOn) exitWith {
		switchCamera player;
	};

	[_newCameraOn] spawn WL2_fnc_drawAssetName;

	private _assetActualType = _newCameraOn getVariable ["WL2_orderedClass", typeof _newCameraOn];
	private _ecmParameters = WL_ASSET(_assetActualType, "ecm", []);
	if (count _ecmParameters >= 3) then {
		[_newCameraOn] spawn WL2_fnc_ecmJammer;
	};
}];