#include "includes.inc"
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
				[_key, DIS_fnc_getTargetList, [DIS_fnc_getSamTarget, "NO TARGET", "WL2_selectedTargetAA"], "AA"] call DIS_fnc_handleKeypress;
			};
			case "gps": {
				[_key] call DIS_fnc_handleGPSKeypress;
			};
			case "laser": {
				[_key, DIS_fnc_getLaserList, [], "Laser"] call DIS_fnc_handleKeypress;
			};
			case "remote": {
				[_key, DIS_fnc_getSquadList, [], "Player"] call DIS_fnc_handleKeypress;
			};
			case "sead": {
				[_key, DIS_fnc_getTargetList, [DIS_fnc_getSeadTarget, "TARGET: AUTO", "WL2_selectedTargetSEAD"], "SEAD"] call DIS_fnc_handleKeypress;
			};
			default {};
		};
	}];

	_display displayAddEventHandler ["KeyDown", {
		params ["_display", "_key", "_shift", "_ctrl", "_alt"];
		if (BIS_WL_missionEnd) exitWith {};
		if (_key != 1) exitWith {};	// escape to kill scoreboard
		private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
		if !(isNull _display) then {
			_display closeDisplay 1;
			true;
		};
	}];

	_display displayAddEventHandler ["KeyUp", {
		params ["_display", "_key", "_shift", "_ctrl", "_alt"];
		if (BIS_WL_missionEnd) exitWith {};
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
		if (WL_ISUP(player)) exitWith {};
		if (_key in actionKeys "ActionContext" || _key in actionKeys "Action") then {
			["Select"] call WL2_fnc_deadActions;
			true;
		};
	}];

	_display displayAddEventHandler ["KeyUp", {
		params ["_display", "_key"];
		if (WL_ISUP(player)) exitWith {};
		if (_key in actionKeys "ActionContext" || _key in actionKeys "Action") then {
			["Unselect"] call WL2_fnc_deadActions;
			true;
		};
	}];

	_display displayAddEventHandler ["MouseZChanged", {
		params ["_displayOrControl", "_scroll"];
		if (WL_ISUP(player)) exitWith {};
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
		private _altitude = (player modelToWorld [0, 0, 0]) # 2;
		private _eligible = _altitude > 20;
		if (_eligible) then {
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

addMissionEventHandler ["MarkerCreated", {
	params ["_marker", "_channelNumber", "_owner", "_local"];
	if (!isPlayer _owner) exitWith {};

	// Global markers disabled
	if (_channelNumber == 0) exitWith {
		deleteMarker _marker;
	};

	private _markerText = toLower markerText _marker;
	if (_markerText == "") exitWith {};

	private _disallowList = getArray (missionConfigFile >> "adminFilter");
	private _triggeredFilters = _disallowList select {
		_x in _markerText
	};
	if (count _triggeredFilters > 0) exitWith {
		deleteMarker _marker;
	};
}];