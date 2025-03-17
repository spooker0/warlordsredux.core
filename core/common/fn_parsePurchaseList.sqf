#include "..\warlords_constants.inc"

params ["_side"];

private _sortedArray = [];
private _lastLoadoutHandled = FALSE;
private _saveLoadoutHandled = FALSE;
private _savedLoadoutHandled = FALSE;

{
	_presetName = _x;
	_preset = configNull;

	if (isClass (missionConfigFile >> "CfgWLRequisitionPresets" >> _presetName)) then {
		_preset = missionConfigFile >> "CfgWLRequisitionPresets" >> _presetName;
	} else {
		if (isClass (configFile >> "CfgWLRequisitionPresets" >> _presetName)) then {
			_preset = configFile >> "CfgWLRequisitionPresets" >> _presetName;
		} else {
			[format ["Warlords error: Input preset class '%1' not found in any configs.", _presetName]] call BIS_fnc_error;
		};
	};

	if (isNull _preset) exitWith {};

	if (isClass (_preset >> str _side)) then {
		{
			if (_x in ["Fast Travel", "Strategy"]) exitWith {};

			_index = _forEachIndex;
			_category = _x;
			_category = (_category splitString " ") joinString "";
			_data = [];
			if (count _sortedArray >= (_index + 1)) then {
				_data = _sortedArray # _index
			};

			if (_category == "Infantry") then {
				private _buildABear = ["BuildABear", 300, [], "Customized Unit", "\A3\Data_F_Warlords\Data\preview_loadout.jpg", "Buy infantry with your customized loadout."];
				_data insert [0, [_buildABear]];
			};

			if (_category == "Gear") then {
				_data pushBack ["Arsenal", (getMissionConfigValue ["BIS_WL_arsenalCost", 1000]), [], (localize "STR_A3_Arsenal"), "\A3\Data_F_Warlords\Data\preview_arsenal.jpg", localize "STR_A3_WL_arsenal_open"];
				_data pushBack ["Customization", 0, [], "Customization", "\A3\Data_F_Warlords\Data\preview_arsenal.jpg", "Customization menu for respawn loadout."];
				_data pushBack ["BuyGlasses", 1000, [], "Buy AR Glasses", "\A3\Data_F_Warlords\Data\preview_arsenal.jpg", "Buy AR glasses."];
			};

			if (_category == "Gear" && !_lastLoadoutHandled) then {
				_lastLoadoutHandled = TRUE;
				_data pushBack ["LastLoadout", (getMissionConfigValue ["BIS_WL_lastLoadoutCost", 100]), [], (localize "STR_A3_WL_last_loadout"), "\A3\Data_F_Warlords\Data\preview_loadout.jpg", localize "STR_A3_WL_last_loadout_info"];
			};

			if (_category == "Gear" && !_savedLoadoutHandled) then {
				_savedLoadoutHandled = TRUE;
				_data pushBack ["SavedLoadout", (getMissionConfigValue ["BIS_WL_savedLoadoutCost", 500]), [], (localize "STR_A3_WL_saved_loadout"), "\A3\Data_F_Warlords\Data\preview_loadout.jpg", format [localize "STR_A3_WL_saved_loadout_info", "<br/>"]];
			};

			private _descriptionMap = missionNamespace getVariable ["WL2_descriptions", createHashMap];

			{
				_className = configName _x;
				_actualClassName = getText (_x >> "spawn");
				if (_actualClassName == "") then {_actualClassName = _className};
				_class = configFile >> "CfgVehicles" >> _actualClassName;
				_cost = getNumber (_x >> "cost");
				_requirements = getArray (_x >> "requirements");
				_offset = getArray (_x >> "offset");
				_notForAIUse = getNumber (_x >> "blacklistAI");
				_displayName = getText (_x >> "name");
				if (_displayName == "") then {
					_displayName = getText (_class >> "displayName");
				};
				_picture = getText (_class >> "editorPreview");
				_text = "";

				if (_cost == 0) then {
					continue;
				};

				if (_category == "Infantry") then {
					_wpns = getArray (_class >> "weapons");
					_wpnArrPrimary = _wpns select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 1};
					_wpnArrSecondary = _wpns select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 4};
					_wpnArrHandgun = _wpns select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 2};
					_wpn = if (count _wpnArrSecondary > 0) then {
						_wpnArrSecondary # 0;
					} else {
						if (count _wpnArrPrimary > 0) then {
							_wpnArrPrimary # 0;
						} else {
							if (count _wpnArrHandgun > 0) then {
								_wpnArrPrimary # 0;
							} else {
								""
							};
						};
					};
					{
						_text = _text + (getText (configFile >> "CfgWeapons" >> _x >> "displayName")) + "<br/>";
					} forEach (_wpnArrPrimary + _wpnArrSecondary + _wpnArrHandgun);
					_text = _text + "<br/>";
					_linked = getArray (_class >> "linkedItems");
					if (count _linked > 0) then {
						_text = _text + (getText (configFile >> "CfgWeapons" >> _linked # 0 >> "displayName")) + "<br/>";
					};
					_backpack = getText (_class >> "backpack");
					if (_backpack != "") then {_text = _text + (getText (configFile >> "CfgVehicles" >> _backpack >> "displayName"))};
				} else {
					if (_category in ["LightVehicles", "HeavyVehicles", "RotaryWing", "FixedWing", "RemoteControl", "AirDefense", "SectorDefense", "Naval"]) then {
						_text = getText (_class >> "Library" >> "LibTextDesc");
						if (_text == "") then {
							_text = getText (_class >> "Armory" >> "description");
						};
						if (_text == "") then {
							_validClassArr = "toLower getText (_x >> 'vehicle') == toLower _entryClass" configClasses (configFile >> "CfgHints");
							if (count _validClassArr > 0) then {
								_hintLibClass = ("toLower getText (_x >> 'vehicle') == toLower _entryClass" configClasses (configFile >> "CfgHints")) # 0;
								_text = getText (_hintLibClass >> "description");
								if (count _text > 0) then {
									if (((toArray _text) # 0) == 37) then {
										_text = localize (((getArray (_hintLibClass >> "arguments")) # 1) # 0);
									};
								};
							};
						};
					} else {
						if (_category == "Gear") then {
							_transportWeapons = _class >> "TransportWeapons";
							_weaponsCnt = count _transportWeapons;
							_i = 0;
							for "_i" from 0 to (_weaponsCnt - 1) do {
								_item = getText ((_transportWeapons select _i) >> "weapon");
								_text = _text + format ["%3%2x %1", getText (configFile >> "CfgWeapons" >> _item >> "displayName"), getNumber ((_transportWeapons select _i) >> "count"), if (_text == "") then {""} else {", "}];
							};

							_transportItems = _class >> "TransportItems";
							_itemsCnt = count _transportItems;
							_i = 0;
							for "_i" from 0 to (_itemsCnt - 1) do {
								_item = getText ((_transportItems select _i) >> "name");
								_text = _text + format ["%3%2x %1", getText (configFile >> "CfgWeapons" >> _item >> "displayName"), getNumber ((_transportItems select _i) >> "count"), if (_text == "") then {""} else {", "}];
							};

							_transportMags = _class >> "TransportMagazines";
							_magsCnt = count _transportMags;
							_i = 0;
							for "_i" from 0 to (_magsCnt - 1) do {
								_item = getText ((_transportMags select _i) >> "magazine");
								_text = _text + format ["%3%2x %1", getText (configFile >> "CfgMagazines" >> _item >> "displayName"), getNumber ((_transportMags select _i) >> "count"), if (_text == "") then {""} else {", "}];
							};

							_transportBPacks = _class >> "TransportBackpacks";
							_bPacksCnt = count _transportBPacks;
							_i = 0;
							for "_i" from 0 to (_bPacksCnt - 1) do {
								_item = getText ((_transportBPacks select _i) >> "backpack");
								_text = _text + format ["%3%2x %1", getText (configFile >> "CfgVehicles" >> _item >> "displayName"), getNumber ((_transportBPacks select _i) >> "count"), if (_text == "") then {""} else {", "}];
							};
						};
					};
				};

				if (_text != "") then {
					_textNew = (_text splitString "$") # 0;
					if (_textNew != _text) then {
						_text = localize _textNew
					} else {
						_text = _textNew
					};
					_text = _text regexReplace ["\. ", "="];
					_text = ((_text splitString "=") # 0) + ".";
				};

				private _description = _descriptionMap getOrDefault [_className, ""];
				if (_description != "") then {
					_text = _description;
				};

				if (_category in ["LightVehicles", "HeavyVehicles", "RotaryWing", "FixedWing", "RemoteControl", "AirDefense", "SectorDefense", "Naval"]) then {
					private _vehicleWeapons = [_className, _actualClassName] call WL2_fnc_getVehicleWeapons;
					private _scale = 1 call WL2_fnc_purchaseMenuGetUIScale;
					_text = _text + format ["<br/><t color='#ffffff' shadow='0' size='%1'>Armament</t><br/>%2", _scale, _vehicleWeapons];
				};

				if (_text == "") then {_text = " "};
				if (_picture == "") then {_picture = " "};

				_data pushBack [_className, _cost, _requirements, _displayName, _picture, _text, _offset, _notForAIUse];
			} forEach (configProperties [_preset >> str _side >> _category, "isClass _x"]);

			if (_category == "Gear" && !_saveLoadoutHandled) then {
				_saveLoadoutHandled = TRUE;
				_data pushBack ["SaveLoadout", 0, [], (localize "STR_A3_WL_save_loadout"), "\A3\Data_F_Warlords\Data\preview_loadout.jpg", localize "STR_A3_WL_save_loadout_info"];
			};

			_sortedArray set [_index, _data];
		} forEach WL_REQUISITION_CATEGORIES;
	} else {
		[format ["Warlords warning: Input preset class '%1' does not contain any data for side '%2'", _presetName, _side]] call BIS_fnc_error;
	};
} forEach BIS_WL_purchaseListTemplate;

private _fastTravelArr = [
	[
		"FTSeized",
		0,
		[],
		localize "STR_A3_WL_menu_fasttravel_seized",
		"\A3\Data_F_Warlords\Data\preview_ft_owned.jpg",
		localize "STR_A3_WL_menu_fasttravel_info"
	], [
		"FTConflict",
		getMissionConfigValue ["BIS_WL_fastTravelCostContested", 200],
		[],
		localize "STR_A3_WL_menu_fasttravel_conflict",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		localize "STR_A3_WL_menu_fasttravel_info"
	], [
		"FTAirAssault",
		getMissionConfigValue ["WL_airAssaultCost", 100],
		[],
		"Fast Travel Air Assault",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Attack the contested sector by dropping into it with a parachute."
	], [
		"FTParadropVehicle",
		getMissionConfigValue ["WL_vehicleParadropCost", 1000],
		[],
		"Fast Travel Vehicle Paradrop",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Move your vehicle to a friendly sector from a helipad/airfield sector by paradropping it.<br/>Requirements:<br/>1. In an owned sector.<br/>2. In a vehicle as the driver.<br/>3. No enemies nearby.<br/>4. Cooldown: 5 minutes."
	], [
		"RespawnVicFT",
		0,
		[],
		localize "STR_A3_WL_respawn_vicFT_ft",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"RespawnPodFT",
		0,
		[],
		"Fast Travel to Medical Pod (Free)",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"FTSquadLeader",
		getMissionConfigValue ["BIS_WL_fastTravelCostSquadLeader", 10],
		[],
		localize "STR_SQUADS_fastTravelToSquadLeader",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		localize "STR_SQUADS_fastTravelToSquadLeader"
	], [
		"RespawnBagFT",
		0,
		[],
		"Fast Travel to Tent (Free)",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"StrongholdFT",
		0,
		[],
		"Fast Travel to Sector Stronghold",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"RespawnVic",
		getMissionConfigValue ["BIS_WL_orderFTVehicleCost", 200],
		[],
		localize "STR_A3_WL_respawn_vicFT_order",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"RespawnPod",
		getMissionConfigValue ["BIS_WL_orderFTVehicleCost", 200],
		[],
		"Purchase Fast Travel Pod",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Order medical pod"
	], [
		"RespawnBag",
		50,
		[],
		"Purchase Fast Travel Tent",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Buy a deployable sleeping bag that respawns you at its location."
	], [
		"BuyFOB",
		500,
		[],
		"Purchase Forward Base Supplies",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		format ["Purchases equipment that can be airlifted or deployed into a forward position and setup into a base.<br/>Deploy requirements:<br/>1. Must be squad leader.<br/>2. Squad size >= 3.<br/>3. Outside of sectors.<br/>4. At least %1 away from other forward bases.<br/>5. Can have 3 total at once, including cooldown.", WL_FOB_MIN_DISTANCE]
	], [
		"BuyStronghold",
		500,
		[],
		"Purchase Sector Stronghold",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Fortifies the nearest building in your sector with a stronghold (one per sector at a time). This will replace the current stronghold if one exists. Strongholds provide a 5x bonus to infantry capture power in its small area, regardless of owner. Assets can be deployed onto strongholds. Strongholds can be used to speed up sector fortification process to reduce backcapping."
	]
];

#if WL_STRONGHOLD_ENABLE == 0
_fastTravelArr = _fastTravelArr select {
	!(_x # 0 in ["StrongholdFT", "BuyStronghold"])
};
#endif

#if WL_FOB_ENABLED == 0
_fastTravelArr = _fastTravelArr select {
	!(_x # 0 in ["BuyFOB"])
};
#endif

_sortedArray pushBack _fastTravelArr;

private _strategyArr = [
	[
		"Scan",
		getMissionConfigValue ["BIS_WL_scanCost", 750],
		[],
		localize "STR_A3_WL_param4_title",
		"\A3\Data_F_Warlords\Data\preview_scan.jpg",
		localize "STR_A3_WL_menu_scan_info"
	], [
		"FundsTransfer",
		getMissionConfigValue ["BIS_WL_fundsTransferCost", 2000],
		[],
		localize "STR_A3_WL_menu_moneytransfer",
		"\A3\Data_F_Warlords\Data\preview_cp_transfer.jpg",
		localize "STR_A3_WL_menu_fundstransfer_info"
	], [
		"TargetReset",
		getMissionConfigValue ["BIS_WL_targetResetCost", 500],
		[],
		localize "STR_A3_WL_menu_resetvoting",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		localize "STR_A3_WL_menu_resetvoting_info"
	], [
		"LockVehicles",
		0,
		[],
		localize "STR_A3_WL_feature_lock_all",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		""
	], [
		"UnlockVehicles",
		0,
		[],
		localize "STR_A3_WL_feature_unlock_all",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		""
	], [
		"ClearVehicles",
		0,
		[],
		"Kick players from all vehicles",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"This doesn't include you or your AI."
	], [
		"ResetVehicle",
		10,
		[],
		"Reset vehicle",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Reset vehicle. Must be within 15m and looking at the vehicle."
	], [
		"PruneAssets",
		0,
		[],
		"List/Prune Assets",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"List all your assets in the game and decide whether to take action to delete some of them."
	], [
		"WipeMap",
		0,
		[],
		"Wipe Map",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Wipes all user-defined markers from your own map locally. This includes your own."
	], [
		"AIGetIn",
		50,
		[],
		"AI Get In",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Your AI within 30m radius will be forced into the vehicle you are pointing at."
	], [
		"RemoveUnits",
		0,
		[],
		localize "STR_A3_WL_feature_dismiss_selected",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		""
	], [
		"WelcomeScreen",
		0,
		[],
		localize "STR_A3_WL_infoScreen",
		"src\img\wl_logo_ca.paa",
		""
	], [
		"ForfeitVote",
		0,
		[],
		localize "STR_A3_WL_feature_OrderForfeit",
		"\a3\data_f\flags\flag_white_dmg_co.paa",
		localize "STR_A3_WL_feature_OrderForfeit_info"
	]
];

#if WL_FACTION_THREE_ENABLED
	_strategyArr pushBack [
		"SwitchToGreen",
		0,
		[],
		"Switch to Green",
		"\a3\data_f\flags\flag_green_co.paa",
		"Switch to Green side"
	];
#endif

_sortedArray pushBack _strategyArr;

missionNamespace setVariable [format ["BIS_WL_purchasable_%1", _side], _sortedArray];