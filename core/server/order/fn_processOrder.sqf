#include "includes.inc"
params ["_asset", "_sender", "_orderedClass"];

private _side = side group _sender;
private _owner = if (isNull _sender) then { 2 } else { owner _sender };
private _cost = WL_ASSET(_orderedClass, "cost", 0);

private _drone = WL_ASSET(_orderedClass, "drone", 0);
if (_drone > 0) then {
    private _side = if (isNull _sender) then {
        independent;
    } else {
        side group _sender;
    };
    private _assetGrp = createGroup _side;

    private _aiUnit = switch (_side) do {
        case west: { "B_UAV_AI" };
        case east: { "O_UAV_AI" };
        case independent: { "I_UAV_AI" };
    };

    for "_i" from 1 to _drone do {
        private _unit = _assetGrp createUnit [_aiUnit, _pos, [], 0, "NONE"];
		_unit linkItem "ItemMap";
        _unit moveInAny _asset;
        if (!isNull _sender) then {
            _unit setSkill 1;
            _unit setVariable ["BIS_WL_ownerAsset", getPlayerUID _sender, true];
        };
    };

    _asset lockDriver true;
    _asset setVariable ["WL2_manualDrone", true, true];
    _assetGrp deleteGroupWhenEmpty true;
};

if (_asset isKindOf "Air") then {
	[_asset] spawn WL2_fnc_airWreckHandler;
};

private _immobile = WL_ASSET(_orderedClass, "immobile", 0);
if (_immobile > 0) then {
	if (unitIsUAV _asset) then {
		deleteVehicle (driver _asset);
	} else {
		_asset lockDriver true;
	};

	{
		_asset setHitPointDamage [_x, 1.0];
	} forEach ["HitLMWheel", "HitRMWheel", "HitLFWheel", "HitRFWheel", "HitLF2Wheel", "HitRF2Wheel", "HitLBWheel", "HitRBWheel"];

	_asset setFuel 0;
	_asset setFuelConsumptionCoef 1000;
};

private _assetChildren = _asset getVariable ["WL2_children", []];
private _attachments = WL_ASSET(_orderedClass, "attachments", []);
{
	_x params ["_attachClass", "_attachOffset", "_attachDir", "_attachMemoryPoint", "_attachScale"];
	private _attachment = createSimpleObject [_attachClass, [0, 0, 0]];
    if (_attachMemoryPoint == "") then {
        _attachment attachTo [_asset, _attachOffset];
    } else {
        _attachment attachTo [_asset, _attachOffset, _attachMemoryPoint, true];
    };
	_attachment setDir _attachDir;
	if (_attachScale != 1) then {
		_attachment setObjectScale _attachScale;
	};
	_assetChildren pushBack _attachment;
} forEach _attachments;

private _hideTurret = WL_ASSET(_orderedClass, "hideTurret", 0);
if (_hideTurret != 0) then {
	_asset animateSource ["HideTurret", 1, true];
};

_asset setVariable ["WL2_children", _assetChildren, [2, _sender]];

private _assetTextures = WL_ASSET(_orderedClass, "textures", []);
{
	_asset setObjectTextureGlobal [_forEachIndex, _x];
} forEach _assetTextures;

private _turretOverridesForVehicle = WL_ASSET(_orderedClass, "turretOverrides", []);
private _pylonInfo = getAllPylonsInfo _asset;

{
	private _turretOverride = _x;
	private _turret = _x getOrDefault ["turret", []];
	private _removeMagazines = _x getOrDefault ["removeMagazines", []];
	private _removeWeapons = _x getOrDefault ["removeWeapons", []];
	private _addMagazines = _x getOrDefault ["addMagazines", []];
	private _addWeapons = _x getOrDefault ["addWeapons", []];

	{
		_asset removeMagazinesTurret [_x, _turret];
	} forEach _removeMagazines;

	{
		_asset removeWeaponTurret [_x, _turret];
	} forEach _removeWeapons;

	private _existingMagazines = _asset magazinesTurret _turret;
	private _existingWeapons = _asset weaponsTurret _turret;

	private _removePylonMagazines = _pylonInfo apply { _x # 3 };
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
} forEach _turretOverridesForVehicle;

if (count (_pylonInfo) > 0) then {
	private _pylonAttachments = _pylonInfo apply {
		[_x # 1, _x # 3, _x # 2];
	};

	private _replacePylons = WL_ASSET(_orderedClass, "replacePylons", []);
	{
		_x params ["_pylonName", "_pylonTurret", "_pylonMagazine"];
		private _indexToReplace = _pylonAttachments findIf { _x # 0 == _pylonName };
		if (_indexToReplace == -1) then {
			continue;
		};
		_pylonAttachments set [_indexToReplace, [_pylonName, _pylonMagazine, _pylonTurret]];
	} forEach _replacePylons;

	_pylonAttachments = _pylonAttachments apply {
		[_x # 1, _x # 2];
	};

	[_asset, _pylonAttachments, true] call WLM_fnc_applyPylon;
};

private _disallowListForAsset = WL_ASSET(_orderedClass, "disallowMagazines", []);
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

private _turrets = [[-1]] + allTurrets _asset;
{
	private _disallowedMag = _x;
	{
		private _turret = _x;
		_asset removeMagazinesTurret [_disallowedMag, _turret];
	} forEach _turrets;
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
_asset setVariable ["WL2_orderedClass", _orderedClass, true];
[_asset, _sender] remoteExec ["WL2_fnc_newAssetHandle", _owner];
_sender setVariable ["BIS_WL_isOrdering", false, [2, _owner]];

private _lifetime = WL_ASSET(_orderedClass, "lifetime", 0);
if (_lifetime > 0) then {
	[_asset, _lifetime] spawn {
		params ["_asset", "_lifetime"];
		uiSleep _lifetime;
		if (alive _asset) then {
			deleteVehicle _asset;
		};
	};
};

_asset;