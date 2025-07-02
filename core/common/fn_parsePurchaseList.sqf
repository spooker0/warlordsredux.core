#include "includes.inc"
params ["_side"];

private _purchaseable = [];

{
	private _category = (_x splitString " ") joinString "";
	if (_category in ["FastTravel", "Strategy"]) then {
		continue;
	};

	private _categoryData = [];

	switch (_category) do {
		case "Infantry": {
			_categoryData pushBack [
				"BuildABear",
				300,
				[],
				"Customized Unit",
				"\A3\Data_F_Warlords\Data\preview_loadout.jpg",
				"Buy infantry with your customized loadout."
			];
		};
		case "Gear": {
			_categoryData pushBack [
				"Arsenal",
				WL_COST_ARSENAL,
				[],
				localize "STR_A3_Arsenal",
				"\A3\Data_F_Warlords\Data\preview_arsenal.jpg",
				localize "STR_A3_WL_arsenal_open"
			];
			_categoryData pushBack [
				"Customization",
				0,
				[],
				"Customization",
				"\A3\Data_F_Warlords\Data\preview_arsenal.jpg",
				"Customization menu for respawn loadout."
			];
			#if WL_AR_GLASSES_TOGGLE
			_categoryData pushBack [
				"BuyGlasses",
				1000,
				[],
				"Buy AR Glasses",
				"\A3\Data_F_Warlords\Data\preview_arsenal.jpg",
				"Buy AR glasses, which show you enemies spotted by friendly datalink, while you are in range of an EW network. Use +/- keys to increase/decrease range."
			];
			#endif
			_categoryData pushBack [
				"LastLoadout",
				WL_COST_LASTLOADOUT,
				[],
				localize "STR_A3_WL_last_loadout",
				"\A3\Data_F_Warlords\Data\preview_loadout.jpg",
				localize "STR_A3_WL_last_loadout_info"
			];
			_categoryData pushBack [
				"SavedLoadout",\
				WL_COST_SAVEDLOADOUT,
				[],
				localize "STR_A3_WL_saved_loadout",
				"\A3\Data_F_Warlords\Data\preview_loadout.jpg",
				format [localize "STR_A3_WL_saved_loadout_info", "<br/>"]
			];
			_categoryData pushBack [
				"SaveLoadout",
				0,
				[],
				localize "STR_A3_WL_save_loadout",
				"\A3\Data_F_Warlords\Data\preview_loadout.jpg",
				localize "STR_A3_WL_save_loadout_info"
			];
		};
	};

	private _assetData = WL_ASSET_DATA;

	private _preset = missionConfigFile >> "CfgWLRequisitionPresets" >> "A3ReduxAll";
	{
		private _className = configName _x;
		private _actualClassName = getText (_x >> "spawn");

		if (_actualClassName == "") then {
			_actualClassName = _className;
		};

		private _class = configFile >> "CfgVehicles" >> _actualClassName;
		private _cost = getNumber (_x >> "cost");
		private _requirements = getArray (_x >> "requirements");
		private _offset = getArray (_x >> "offset");

		private _displayName = getText (_x >> "name");
		if (_displayName == "") then {
			_displayName = getText (_class >> "displayName");
		};

		private _picture = getText (_class >> "editorPreview");

		if (_cost == 0) then {
			continue;
		};

		private _text = switch (_category) do {
			case "Infantry": {
				private _wpns = getArray (_class >> "weapons");
				private _wpnArrPrimary = _wpns select { getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 1 };
				private _wpnArrSecondary = _wpns select { getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 4 };
				private _wpnArrHandgun = _wpns select { getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 2 };
				private _wpn = if (count _wpnArrSecondary > 0) then {
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

				private _infText = "";
				{
					_infText = format ["%1%2<br/>", _infText, getText (configFile >> "CfgWeapons" >> _x >> "displayName")];
				} forEach (_wpnArrPrimary + _wpnArrSecondary + _wpnArrHandgun);
				_infText = _infText + "<br/>";

				private _linked = getArray (_class >> "linkedItems");
				if (count _linked > 0) then {
					_infText = format ["%1%2<br/>", _infText, getText (configFile >> "CfgWeapons" >> _linked # 0 >> "displayName")];
				};

				private _backpack = getText (_class >> "backpack");
				if (_backpack != "") then {
					_infText = format ["%1%2<br/>", _infText, getText (configFile >> "CfgVehicles" >> _backpack >> "displayName")];
				};

				_infText;
			};
			case "LightVehicles";
			case "HeavyVehicles";
			case "RotaryWing";
			case "FixedWing";
			case "RemoteControl";
			case "AirDefense";
			case "SectorDefense";
			case "Structures";
			case "Naval": {
				private _assetText = getText (_class >> "Library" >> "LibTextDesc");
				if (_assetText == "") then {
					_assetText = getText (_class >> "Armory" >> "description");
				};
				if (_assetText == "") then {
					private _validClassArr = "toLower getText (_x >> 'vehicle') == toLower _entryClass" configClasses (configFile >> "CfgHints");
					if (count _validClassArr > 0) then {
						private _hintLibClass = ("toLower getText (_x >> 'vehicle') == toLower _entryClass" configClasses (configFile >> "CfgHints")) # 0;
						_assetText = getText (_hintLibClass >> "description");
					};
				};

				if (_assetText != "") then {
					_textNew = (_assetText splitString "$") # 0;
					if (_textNew != _assetText) then {
						_assetText = localize _textNew
					};
					_assetText = _assetText regexReplace ["\. ", "="];
					_assetText = ((_assetText splitString "=") # 0) + ".";
				};

				private _description = WL_ASSET_FIELD(_assetData, _className, "description", "");
				if (_description != "") then {
					_assetText = _description;
				};

				private _vehicleWeapons = [_className, _actualClassName] call WL2_fnc_getVehicleWeapons;
				private _scale = 1 call WL2_fnc_purchaseMenuGetUIScale;
				_assetText = format ["%1<br/><t color='#ffffff' shadow='0' size='%2'>Armament</t><br/>%3", _assetText, _scale, _vehicleWeapons];

				_assetText;
			};
			default {
				WL_ASSET_FIELD(_assetData, _className, "description", "")
			};
		};

		if (_text == "") then {_text = " "};
		if (_picture == "") then {_picture = " "};

		_categoryData pushBack [_className, _cost, _requirements, _displayName, _picture, _text, _offset];
	} forEach (configProperties [_preset >> str _side >> _category, "isClass _x"]);

	_purchaseable pushBack _categoryData;
} forEach WL_REQUISITION_CATEGORIES;

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
		WL_COST_FTCONTESTED,
		[],
		localize "STR_A3_WL_menu_fasttravel_conflict",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		localize "STR_A3_WL_menu_fasttravel_info"
	], [
		"FTAirAssault",
		WL_COST_AIRASSAULT,
		[],
		"Fast travel air assault",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Attack the contested sector by dropping into it with a parachute."
	], [
		"FTParadropVehicle",
		WL_COST_PARADROP,
		[],
		"Fast travel vehicle paradrop",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Move your vehicle to a friendly sector from a helipad/airfield sector by paradropping it.<br/>Requirements:<br/>1. In an owned sector.<br/>2. In a vehicle as the driver.<br/>3. No enemies nearby.<br/>4. Cooldown: 5 minutes."
	], [
		"FTSquadLeader",
		WL_COST_FTSL,
		[],
		localize "STR_SQUADS_fastTravelToSquadLeader",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		localize "STR_SQUADS_fastTravelToSquadLeader"
	], [
		"RespawnBagFT",
		0,
		[],
		"Fast travel to tent",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"StrongholdFT",
		0,
		[],
		"Fast travel to sector stronghold",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"RespawnBag",
		50,
		[],
		"Purchase fast travel tent",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Buy a deployable sleeping bag that respawns you at its location."
	], [
		"BuyFOB",
		500,
		[],
		"Purchase forward base supplies",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		format ["Purchases equipment that can be airlifted or deployed into a forward position and setup into a base.<br/>Deploy requirements:<br/>1. Must be squad leader.<br/>2. Squad size >= 3.<br/>3. Outside of sectors.<br/>4. At least %1 away from other forward bases.<br/>5. Can have 3 total at once.<br/>Can also be used to add 20,000 supplies to an existing FOB.", WL_FOB_MIN_DISTANCE]
	], [
		"BuyStronghold",
		500,
		[],
		"Purchase sector stronghold",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Fortifies the nearest building in your sector with a stronghold (one per sector at a time). This will replace the current stronghold if one exists. Strongholds provide a 5x bonus to infantry capture power in its small area, regardless of owner. Assets can be deployed onto strongholds. Strongholds can be used to speed up sector fortification process to reduce backcapping."
	]
];

_purchaseable pushBack _fastTravelArr;

private _strategyArr = [
	[
		"Scan",
		WL_COST_SCAN,
		[],
		localize "STR_A3_WL_param4_title",
		"\A3\Data_F_Warlords\Data\preview_scan.jpg",
		localize "STR_A3_WL_menu_scan_info"
	], [
		"FundsTransfer",
		WL_COST_FUNDTRANSFER,
		[],
		localize "STR_A3_WL_menu_moneytransfer",
		"\A3\Data_F_Warlords\Data\preview_cp_transfer.jpg",
		localize "STR_A3_WL_menu_fundstransfer_info"
	], [
		"TargetReset",
		WL_COST_TARGETRESET,
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
		"Camouflage",
		500,
		[],
		"Camouflage",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Camouflage your current position with tall plants. Disappears after 5 minutes."
	], [
		"CruiseMissiles",
		15000,
		[],
		"Call missile strike",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Call a volley of cruise missiles on your designation. Requires all targets (vehicles or infantry) to be on datalink."
	], [
		"PruneAssets",
		0,
		[],
		"Prune assets",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"List all your assets in the game and decide whether to take action to delete some of them."
	], [
		"WipeMap",
		0,
		[],
		"Wipe map",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Wipes all user-defined markers from your own map locally. This includes your own."
	], [
		"ControlCollaborator",
		2000,
		[],
		"Control collaborator",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Find and control a collaborator in the local population within 4km, that is not in the sector your team is attacking."
	], [
		"AIGetIn",
		0,
		[],
		"AI get in",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Your AI within 50m radius will be forced into the vehicle you are driving."
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
	]
];

#if WL_PERF_TEST
	_strategyArr pushBack [
		"StressTestSector",
		0,
		[],
		"Stress test: assets in current sector",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Order up to 50 vehicles in current sector to test performance under stress."
	];
	_strategyArr pushBack [
		"StressTestMap",
		0,
		[],
		"Stress test: assets in every sector",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Order up to 5 vehicles in every sector to test performance under stress."
	];
#endif

#if WL_FACTION_THREE_ENABLED
	_strategyArr pushBack [
		"SwitchToGreen",
		0,
		[],
		"Switch to green",
		"\a3\data_f\flags\flag_green_co.paa",
		"Switch to Green side"
	];
#endif

_strategyArr = [_strategyArr, [], { _x # 3 }, "ASCEND"] call BIS_fnc_sortBy;

_purchaseable pushBack _strategyArr;

missionNamespace setVariable [format ["WL2_purchasable_%1", _side], _purchaseable];