// Read mission config file for requisition costs
// Hierarchy: CfgWLRequisitionPresets >> A3ReduxAll >> side >> category >> class
private _nameHashMap = createHashMap;
private _descriptionHashMap = createHashMap;
private _spawnHashMap = createHashMap;
private _costHashMap = createHashMap;
private _rearmTimerHashMap = createHashMap;
private _killRewardHashMap = createHashMap;
private _texturesHashMap = createHashMap;
private _variantHashMap = createHashMap;
private _categoryHashMap = createHashMap;
private _containerHashMap = createHashMap;

private _capValueHashMap = createHashMap;
private _apsHashMap = createHashMap;
private _ammoOverridesHashMap = createHashMap;
private _garbageCollectHashMap = createHashMap;
private _demolishableHashMap = createHashMap;
private _loadableHashMap = createHashMap;
private _flagOffsetHashMap = createHashMap;

private _populateUnitPoolList = [];
private _populateVehiclePoolList = [];
private _populateAircraftPoolList = [];

private _disallowMagazinesForVehicle = createHashMap;
private _allowPylonMagazines = createHashMap;
private _hasESAM = createHashMap;
private _hasGPSMunition = createHashMap;
private _hasHMD = createHashMap;
private _hasReconOptics = createHashMap;
private _hasRemoteBomb = createHashMap;
private _hasScanner = createHashMap;
private _hasAWACS = createHashMap;
private _isLight = createHashMap;

private _turretOverridesHashMap = createHashMap;

private _requisitionPreset = missionConfigFile >> "CfgWLRequisitionPresets" >> "A3ReduxAll";
private _requisitionSides = configProperties [_requisitionPreset];
{
	private _requisitionSide = _x;
	private _requisitionCategories = configProperties [_x];
	{
		private _requisitionCategory = configName _x;
		private _requisitionClasses = configProperties [_x];
		{
			private _requisitonName = configName _x;
			private _requisitionNameOverride = getText (_x >> "name");
			private _requisitionDescription = getText (_x >> "description");
			private _requisitionSpawn = getText (_x >> "spawn");
			private _requisitionVariant = getNumber (_x >> "variant");
			private _requisitionCost = getNumber (_x >> "cost");
			private _requisitionRearmTime = getNumber (_x >> "rearm");
			private _requisitionKillReward = getNumber (_x >> "killReward");
			private _requisitionTextures = getArray (_x >> "textures");
			private _requisitionContainer = getArray (_x >> "container");

			private _requisitionCapValue = getNumber (_x >> "capValue");
			private _requisitionAps = getNumber (_x >> "aps");
			private _requisitionAmmoOverrides = getArray (_x >> "ammoOverrides");

			private _requisitionGarbageCollect = getNumber (_x >> "garbageCollect");
			private _requisitionDemolishable = getNumber (_x >> "demolishable");

			private _requisitionLoadable = getArray (_x >> "loadable");
			private _requisitionFlagOffset = getArray (_x >> "flagOffset");

			private _requisitionDisallowMagazines = getArray (_x >> "disallowMagazines");
			private _requisitionAllowPylonMagazines = getArray (_x >> "allowPylonMagazines");
			private _requisitionHasESAM = getNumber (_x >> "hasESAM");
			private _requisitionHasGPSMunition = getNumber (_x >> "hasGPSMunition");
			private _requisitionHasHMD = getNumber (_x >> "hasHMD");
			private _requisitionHasReconOptics = getNumber (_x >> "hasReconOptics");
			private _requisitionHasRemoteBomb = getNumber (_x >> "hasRemoteBomb");
			private _requisitionHasScanner = getNumber (_x >> "hasScanner");
			private _requisitionHasAWACS = getNumber (_x >> "hasAWACS");
			private _requisitionIsLight = getNumber (_x >> "isLight");

			private _requisitionUnitSpawn = getNumber (_x >> "unitSpawn");
			private _requisitionVehicleSpawn = getNumber (_x >> "vehicleSpawn");
			private _requisitionAircraftSpawn = getNumber (_x >> "aircraftSpawn");

			private _requisitionTurretOverrides = "inheritsFrom _x == (missionConfigFile >> 'WLTurretDefaults')" configClasses _x;

			_categoryHashMap set [_requisitonName, _requisitionCategory];

			if (_requisitionNameOverride != "") then {
				_nameHashMap set [_requisitonName, _requisitionNameOverride];
			};

			if (_requisitionDescription != "") then {
				_descriptionHashMap set [_requisitonName, _requisitionDescription];
			};

			if (_requisitionSpawn != "") then {
				_spawnHashMap set [_requisitonName, _requisitionSpawn];
			};

			if (_requisitionVariant != 0) then {
				_variantHashMap set [_requisitonName, _requisitionVariant];
			};

			if (_requisitionCost != 0) then {
				_costHashMap set [_requisitonName, _requisitionCost];
			};

			if (_requisitionRearmTime != 0) then {
				_rearmTimerHashMap set [_requisitonName, _requisitionRearmTime];
			};

			if (_requisitionKillReward != 0) then {
				_killRewardHashMap set [_requisitonName, _requisitionKillReward];
			};

			if (count _requisitionTextures > 0) then {
				_texturesHashMap set [_requisitonName, _requisitionTextures];
			};

			if (count _requisitionContainer > 0) then {
				_containerHashMap set [_requisitonName, _requisitionContainer];
			};

			if (_requisitionCapValue != 0) then {
				_capValueHashMap set [_requisitonName, _requisitionCapValue];
			};

			if (_requisitionAps != 0) then {
				_apsHashMap set [_requisitonName, _requisitionAps - 1]; // 0-indexed
			};

			if (_requisitionGarbageCollect != 0) then {
				_garbageCollectHashMap set [_requisitonName, true];
			};

			if (_requisitionDemolishable != 0) then {
				_demolishableHashMap set [_requisitonName, true];
			};

			if (count _requisitionLoadable > 0) then {
				_loadableHashMap set [_requisitonName, _requisitionLoadable];
			};

			if (count _requisitionFlagOffset > 0) then {
				_flagOffsetHashMap set [_requisitonName, _requisitionFlagOffset];
			};

			if (_requisitionUnitSpawn != 0) then {
				_populateUnitPoolList pushBack _requisitonName;
			};

			if (_requisitionVehicleSpawn != 0) then {
				_populateVehiclePoolList pushBack _requisitonName;
			};

			if (_requisitionAircraftSpawn != 0) then {
				_populateAircraftPoolList pushBack _requisitonName;
			};

			if (count _requisitionDisallowMagazines > 0) then {
				private _disallowListForVehicle = [];
				{
					_disallowListForVehicle pushBack _x;
				} forEach _requisitionDisallowMagazines;
				_disallowMagazinesForVehicle set [_requisitonName, _disallowListForVehicle];
			};

			if (count _requisitionAllowPylonMagazines > 0) then {
				private _allowListForAircraft = [];
				{
					_allowListForAircraft pushBack _x;
				} forEach _requisitionAllowPylonMagazines;
				_allowPylonMagazines set [_requisitonName, _allowListForAircraft];
			};

			if (_requisitionHasESAM != 0) then {
				_hasESAM set [_requisitonName, true];
			};

			if (_requisitionHasGPSMunition != 0) then {
				_hasGPSMunition set [_requisitonName, true];
			};

			if (_requisitionHasHMD != 0) then {
				_hasHMD set [_requisitonName, true];
			};

			if (_requisitionHasReconOptics != 0) then {
				_hasReconOptics set [_requisitonName, true];
			};

			if (_requisitionHasRemoteBomb != 0) then {
				_hasRemoteBomb set [_requisitonName, true];
			};

			if (_requisitionHasScanner != 0) then {
				_hasScanner set [_requisitonName, true];
			};

			if (_requisitionHasAWACS != 0) then {
				_hasAWACS set [_requisitonName, true];
			};

			if (_requisitionIsLight != 0) then {
				_isLight set [_requisitonName, true];
			};

			if (count _requisitionTurretOverrides > 0) then {
				_turretOverridesHashMap set [_requisitonName, _requisitionTurretOverrides];
			};

			if (count _requisitionAmmoOverrides > 0) then {
				private _ammoOverridesMap = createHashMap;
				{
					_ammoOverridesMap set [_x # 0, _x # 1];
				} forEach _requisitionAmmoOverrides;
				_ammoOverridesHashMap set [_requisitonName, _ammoOverridesMap];
			};
		} forEach _requisitionClasses;
	} forEach _requisitionCategories;
} forEach _requisitionSides;

if (isServer) then {
	serverNamespace setVariable ["fundsDatabase", createHashMap];
	serverNamespace setVariable ["playerList", createHashMap];

	serverNamespace setVariable ["WL2_cappingValues", _capValueHashMap];

	serverNamespace setVariable ["WL2_populateUnitPoolList", _populateUnitPoolList];
	serverNamespace setVariable ["WL2_populateVehiclePoolList", _populateVehiclePoolList];
	serverNamespace setVariable ["WL2_populateAircraftPoolList", _populateAircraftPoolList];

	serverNamespace setVariable ["WL2_staticsGarbageCollector", _garbageCollectHashMap];
	serverNamespace setVariable ["garbageCollector",
		createHashMapFromArray [
			["Steerable_Parachute_F", true],
			["Land_Cargo_Tower_V4_ruins_F", true],
			["Land_MobileRadar_01_radar_ruins_F", true],
			["B_Ejection_Seat_Plane_Fighter_01_F", true],
			["O_Ejection_Seat_Plane_Fighter_02_F", true],
			["I_Ejection_Seat_Plane_Fighter_03_F", true],
			["B_Ejection_Seat_Plane_CAS_01_F", true],
			["O_Ejection_Seat_Plane_CAS_02_F", true],
			["Plane_Fighter_03_Canopy_F", true],
			["Plane_CAS_02_Canopy_F", true],
			["Plane_CAS_01_Canopy_F", true],
			["Plane_Fighter_01_Canopy_F", true],
			["Plane_Fighter_02_Canopy_F", true],
			["Plane_Fighter_04_Canopy_F", true] //<--no comma on last item
		]
	];
};

missionNamespace setVariable ["WL2_killRewards", _killRewardHashMap];
missionNamespace setVariable ["WL2_costs", _costHashMap];
missionNamespace setVariable ["WL2_categories", _categoryHashMap];
missionNamespace setVariable ["WL2_container", _containerHashMap];

missionNamespace setVariable ["WL2_nameOverrides", _nameHashMap];
missionNamespace setVariable ["WL2_descriptions", _descriptionHashMap];
missionNamespace setVariable ["WL2_spawnClass", _spawnHashMap];
missionNamespace setVariable ["WL2_variant", _variantHashMap];
missionNamespace setVariable ["WL2_aps", _apsHashMap];
missionNamespace setVariable ["WL2_textures", _texturesHashMap];

missionNamespace setVariable ["WL2_demolishable", _demolishableHashMap];

missionNamespace setVariable ["WL2_loadable", _loadableHashMap];
missionNamespace setVariable ["WL2_flagOffsets", _flagOffsetHashMap];

missionNamespace setVariable ["WL2_disallowMagazinesForVehicle", _disallowMagazinesForVehicle];
missionNamespace setVariable ["WL2_allowPylonMagazines", _allowPylonMagazines];
missionNamespace setVariable ["WL2_hasESAM", _hasESAM];
missionNamespace setVariable ["WL2_hasGPSMunition", _hasGPSMunition];
missionNamespace setVariable ["WL2_hasHMD", _hasHMD];
missionNamespace setVariable ["WL2_hasReconOptics", _hasReconOptics];
missionNamespace setVariable ["WL2_hasRemoteBomb", _hasRemoteBomb];
missionNamespace setVariable ["WL2_hasScanner", _hasScanner];
missionNamespace setVariable ["WL2_hasAWACS", _hasAWACS];
missionNamespace setVariable ["WL2_isLightweight", _isLight];
missionNamespace setVariable ["WL2_rearmTimers", _rearmTimerHashMap];
missionNamespace setVariable ["WL2_turretOverrides", _turretOverridesHashMap];
missionNamespace setVariable ["WL2_ammoOverrides", _ammoOverridesHashMap];