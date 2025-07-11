#include "includes.inc"
addMissionEventHandler ["GroupIconClick", WL2_fnc_groupIconClickHandle];
addMissionEventHandler ["GroupIconOverEnter", WL2_fnc_groupIconEnterHandle];
addMissionEventHandler ["GroupIconOverLeave", WL2_fnc_groupIconLeaveHandle];

call WL2_fnc_playerEventHandlers;

addMissionEventHandler ["HandleChatMessage", {
	_this call WL2_fnc_handleChatMessages;	// intentional
}];

0 spawn {
	waituntil {sleep 0.1; !isnull (findDisplay 46)};
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
		[_key, "RscWLSamTargetingMenu", DIS_fnc_getTargetList, [DIS_fnc_getSamTarget, "NO TARGET"], "WL2_selectedTarget"] call DIS_fnc_handleKeypress;
		[_key, "RscWLSeadTargetingMenu", DIS_fnc_getTargetList, [DIS_fnc_getSeadTarget, "TARGET: AUTO"], "WL2_selectedTarget"] call DIS_fnc_handleKeypress;
		[_key, "RscWLRemoteMunitionMenu", DIS_fnc_getSquadList, [], "WL2_selectedPlayerTarget"] call DIS_fnc_handleKeypress;
		[_key] call DIS_fnc_handleGPSKeypress;
	}];

	_display displayAddEventHandler ["KeyDown", {
		params ["_display", "_key", "_shift", "_ctrl", "_alt"];
		if (_shift) exitWith {};
		if (_ctrl) exitWith {};
		if (_alt) exitWith {};
		if (_key in actionKeys "networkStats") then {
			0 spawn WL2_fnc_scoreboard;
		};
		if (_key == DIK_ESCAPE) then {
			if !(isNull (uiNamespace getVariable "RscWLScoreboardMenu")) then {
				"scoreboard" cutText ["", "PLAIN"];
				true;
			};
		};
	}];

	// intentionally separate handler
	_display displayAddEventHandler ["KeyDown", {
		private _key = _this # 1;
		[_key] call WL2_fnc_handleBuyMenuKeypress;
	}];

	while { !BIS_WL_missionEnd } do {
		private _purchaseMenu = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
		if (isNull _purchaseMenu) then {
			WL_GEAR_BUY_MENU = false;
			WL_CONTROL_MAP ctrlEnable true;
		};
		sleep 1;
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
	[_newCameraOn] spawn WL2_fnc_drawAssetName;

	private _assetActualType = _newCameraOn getVariable ["WL2_orderedClass", typeof _newCameraOn];
	private _ecmParameters = WL_ASSET(_assetActualType, "ecm", []);
	if (count _ecmParameters >= 3) then {
		[_newCameraOn] spawn WL2_fnc_ecmJammer;
	};
}];