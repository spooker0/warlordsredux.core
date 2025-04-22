#include "..\..\warlords_constants.inc"

params ["_asset", "_sender", "_orderedClass"];

private _side = side group _sender;
private _owner = owner _sender;

private _currentSector = BIS_WL_allSectors select {
	_asset inArea (_x getVariable "objectAreaComplete") &&
	_x getVariable ["BIS_WL_owner", sideUnknown] == _side
};

if (count _currentSector == 0) then {
	private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
	private _forwardBases = _potentialBases select {
		_asset distance2D _x < WL_FOB_RANGE &&
		_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side
	};

	if (count _forwardBases > 0) then {
		private _forwardBase = _forwardBases # 0;
		private _forwardBaseSupplies = _forwardBase getVariable ["WL2_forwardBaseSupplies", 0];
		private _costMap = missionNamespace getVariable ["WL2_costs", createHashMap];
		private _cost = _costMap getOrDefault [_orderedClass, 0];
		if (_cost > _forwardBaseSupplies) exitWith {
			deleteVehicle _asset;
			["Not enough supplies in forward base."] remoteExec ["systemChat", _sender];
			_sender setVariable ["BIS_WL_isOrdering", false, [2, _owner]];
		};
		_forwardBase setVariable ["WL2_forwardBaseSupplies", _forwardBaseSupplies - _cost, true];
	};
};

private _isAircraft = _asset isKindOf "Air";
private _variant = missionNamespace getVariable ["WL2_variant", createHashMap] getOrDefault [_orderedClass, 0];
if (!_isAircraft && _variant != 0) then {
	private _sideFlag = switch (_side) do {
		case west: {
			"\A3\Ui_f\data\Map\Markers\Flags\nato_ca.paa"
		};
		case east: {
			"\A3\Ui_f\data\Map\Markers\Flags\CSAT_ca.paa"
		};
		case independent: {
			"\A3\Ui_f\data\Map\Markers\Flags\AAF_ca.paa"
		};
	};

	private _flagMap = missionNamespace getVariable ["WL2_flagOffsets", createHashMap];
	private _flagOffset = _flagMap getOrDefault [_orderedClass, []];
	if (count _flagOffset > 0) then {
		private _flag = createVehicle ["FlagChecked_F", _asset, [], 0, "CAN_COLLIDE"];
		_flag setFlagTexture _sideFlag;
		_flag attachTo [_asset, _flagOffset, "otocvez", true];

		private _assetChildren = _asset getVariable ["WL2_children", []];
		_assetChildren pushBack _flag;
		_asset setVariable ["WL2_children", _assetChildren, [2, _sender]];
	} else {
		_asset forceFlagTexture _sideFlag;
	};
};

private _textureHashmap = missionNamespace getVariable ["WL2_textures", createHashMap];
private _assetTextures = _textureHashmap getOrDefault [_orderedClass, []];
{
	_asset setObjectTextureGlobal [_forEachIndex, _x];
} forEach _assetTextures;

private _turretOverrides = missionNamespace getVariable ["WL2_turretOverrides", createHashMap];
private _turretOverridesForVehicle = _turretOverrides getOrDefault [_orderedClass, []];
private _pylonInfo = getAllPylonsInfo _asset;

{
	private _turretOverride = _x;
	private _turret = getArray (_turretOverride >> "turret");
	private _removeMagazines = getArray (_turretOverride >> "removeMagazines");
	private _removeWeapons = getArray (_turretOverride >> "removeWeapons");
	private _addMagazines = getArray (_turretOverride >> "addMagazines");
	private _addWeapons = getArray (_turretOverride >> "addWeapons");
	private _reloadOverride = getNumber (_turretOverride >> "reloadOverride");
	private _hideTurret = getNumber (_turretOverride >> "hideTurret");
	private _deviceJammer = getNumber (_turretOverride >> "deviceJammer");

	{
		_asset removeMagazinesTurret [_x, _turret];
	} forEach _removeMagazines;

	{
		_asset removeWeaponTurret [_x, _turret];
	} forEach _removeWeapons;

	private _existingMagazines = _asset magazinesTurret _turret;
	private _existingWeapons = _asset weaponsTurret _turret;

	// exclude pylons
	// private _pylonInfo = getAllPylonsInfo _asset;
	// _existingMagazines = _existingMagazines - (_pylonInfo apply {_x # 3});
	// _existingWeapons = _existingWeapons select {
	// 	private _intersection = (compatibleMagazines _x) arrayIntersect _existingMagazines;
	// 	count _intersection != 0;
	// };

	private _removePylonMagazines = _pylonInfo apply {_x # 3};
	private _removePylonWeapons = _existingWeapons select {
		private _intersection = (compatibleMagazines _x) arrayIntersect _removePylonMagazines;
		count _intersection != 0;
	};

	{
		_asset removeMagazineTurret [_x, _turret];
	} forEach _existingMagazines;

	{
		_asset removeWeaponTurret [_x, _turret];
	} forEach _existingWeapons;

	{
		_asset addMagazineTurret [_x, _turret];
	} forEach _existingMagazines;

	{
		_asset addMagazineTurret [_x, _turret];
	} forEach _addMagazines;

	{
		_asset addWeaponTurret [_x, _turret];
	} forEach _existingWeapons;

	{
		_asset addWeaponTurret [_x, _turret];
	} forEach _addWeapons;

	{
		_asset removeMagazineTurret [_x, _turret];
	} forEach _removePylonMagazines;

	{
		_asset removeWeaponTurret [_x, _turret];
	} forEach _removePylonWeapons;

	if (_reloadOverride != 0) then {
		_asset setVariable ["WL2_reloadOverride", [_reloadOverride, _turret]];
		_asset addEventHandler ["Fired", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
			private _reloadOverride = _unit getVariable ["WL2_reloadOverride", []];
			private _reloadTime = _reloadOverride # 0;
			private _turret = _reloadOverride # 1;

			private _weaponState = weaponState [_unit, _turret];
			if (_weaponState # 6 > 0) then {
				[_unit, _weapon, _turret, _reloadTime] remoteExec ["WL2_fnc_reloadOverride", _gunner];
			};
		}];
	};

	if (_hideTurret != 0) then {
		_asset animateSource ["HideTurret", 1, true];
	};

	if (_deviceJammer != 0) then {
		[_asset, _turret] remoteExec ["APS_fnc_deviceJammer", _asset];
	};
} forEach _turretOverridesForVehicle;

if (count (_pylonInfo) > 0) then {
	private _attachments = _pylonInfo apply {
		[_x # 3, _x # 2];
	};
	[_asset, _attachments, true] call WLM_fnc_applyPylon;
};

private _disallowListForPylon = missionNamespace getVariable ["WL2_disallowMagazinesForVehicle", createHashMap];
private _disallowListForAsset = _disallowListForPylon getOrDefault [_orderedClass, []];
{
	private _disallowedMagazine = _x;
	{
		private _pylonIndex = _x # 0;
		private _pylonMagazine = _x # 3;
		if (_pylonMagazine == _disallowedMagazine) then {
			_asset setPylonLoadout [_pylonIndex, ""];
			private _assetWeapons = weapons _asset;
			_assetWeapons = _assetWeapons select {
				_disallowedMagazine in (compatibleMagazines _x);
			};
			{
				_asset removeWeaponGlobal _x;
			} forEach _assetWeapons;
		};
	} forEach (getAllPylonsInfo _asset);
} forEach _disallowListForAsset;

private _defaultMags = magazinesAllTurrets _asset;
_asset setVariable ["BIS_WL_defaultMagazines", _defaultMags, true];
_asset setVariable ["WLM_savedDefaultMags", _defaultMags, true];

[_asset] spawn WLM_fnc_checkTurretLocality;

_asset lock false;

private _ownerUid = getPlayerUID _sender;
if (_ownerUid != "") then {
	_asset setVariable ["BIS_WL_ownerAsset", _ownerUid, true];
};
_asset setVariable ["BIS_WL_lastActive", 0, _owner];
_asset setVariable ["WL2_orderedClass", _orderedClass, true];
[_asset, _sender] remoteExec ["WL2_fnc_newAssetHandle", _owner];
_sender setVariable ["BIS_WL_isOrdering", false, [2, _owner]];