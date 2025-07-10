#include "includes.inc"
params ["_texture"];

private _weaponData = getArray (missionConfigFile >> "CfgWLCustomization" >> "weapons");

if (BIS_WL_playerSide == west) then {
    _weaponData append getArray (missionConfigFile >> "CfgWLCustomization" >> "West" >> "outfits");
} else {
    _weaponData append getArray (missionConfigFile >> "CfgWLCustomization" >> "East" >> "outfits");
};

private _weaponOptionArray = [];
private _allMagazines = [];
{
    private _weapon = _x # 0;
    private _weaponType = _x # 1;
    private _weaponLevel = _x # 2;

    private _weaponName = getText (configFile >> "CfgWeapons" >> _weapon >> "displayName");
    private _weaponIcon = (getText (configFile >> "CfgWeapons" >> _weapon >> "picture")) regexReplace ["^\\", ""];

    if (_weaponType in ["vest", "uniform", "helmet"]) then {
        private _maxLoad = getContainerMaxLoad _weapon;

        _weaponOptionArray pushBack [
            _weapon,
            _weaponType,
            _weaponName,
            _weaponIcon,
            _weaponLevel,
            _maxLoad
        ];
        continue;
    };

    if (_weaponType == "backpack") then {
        private _backpackName = getText (configFile >> "CfgVehicles" >> _weapon >> "displayName");
        private _backpackIcon = (getText (configFile >> "CfgVehicles" >> _weapon >> "picture")) regexReplace ["^\\", ""];

        private _maxLoad = getContainerMaxLoad _weapon;
        _weaponOptionArray pushBack [
            _weapon,
            _weaponType,
            _backpackName,
            _backpackIcon,
            _weaponLevel,
            _maxLoad
        ];
        continue;
    };

    private _optics = compatibleItems [_weapon, "CowsSlot"];
    private _opticsData = [];
    {
        private _optic = _x;
        private _opticName = getText (configFile >> "CfgWeapons" >> _optic >> "displayName");
        private _opticIcon = (getText (configFile >> "CfgWeapons" >> _optic >> "picture")) regexReplace ["^\\", ""];
        _opticsData pushBack [_optic, _opticName, _opticIcon];
    } forEach _optics;

    private _muzzles = if (_weapon == "hgun_esd_01_F") then {
        ["muzzle_antenna_01_f", "muzzle_antenna_02_f", "muzzle_antenna_03_f"]
    } else {
        compatibleItems [_weapon, "MuzzleSlot"];
    };
    private _muzzlesData = [];
    {
        private _muzzle = _x;
        private _muzzleName = getText (configFile >> "CfgWeapons" >> _muzzle >> "displayName");
        private _muzzleIcon = (getText (configFile >> "CfgWeapons" >> _muzzle >> "picture")) regexReplace ["^\\", ""];
        _muzzlesData pushBack [_muzzle, _muzzleName, _muzzleIcon];
    } forEach _muzzles;

    private _bipods = compatibleItems [_weapon, "UnderBarrelSlot"];
    private _bipodsData = [];
    {
        private _bipod = _x;
        private _bipodName = getText (configFile >> "CfgWeapons" >> _bipod >> "displayName");
        private _bipodIcon = (getText (configFile >> "CfgWeapons" >> _bipod >> "picture")) regexReplace ["^\\", ""];
        _bipodsData pushBack [_bipod, _bipodName, _bipodIcon];
    } forEach _bipods;

    private _weaponMuzzles = getArray (configFile >> "CfgWeapons" >> _weapon >> "muzzles");
    _weaponMuzzles = _weaponMuzzles apply {
        if (_x == "this") then {
            _weapon
        } else {
            _x
        };
    };

    private _magazines1 = if (_weapon == "hgun_esd_01_F") then {
        []
    } else {
        compatibleMagazines [_weapon, _weaponMuzzles # 0];
    };
    {
        _allMagazines pushBackUnique _x;
    } forEach _magazines1;

    private _magazines2 = if (count _weaponMuzzles >= 2 && _weapon != "hgun_esd_01_F") then {
        compatibleMagazines [_weapon, _weaponMuzzles # 1];
    } else {
        [];
    };
    {
        _allMagazines pushBackUnique _x;
    } forEach _magazines2;

    _weaponOptionArray pushBack [
        _weapon,
        _weaponType,
        _weaponName,
        _weaponIcon,
        _weaponLevel,
        _opticsData,
        _muzzlesData,
        _bipodsData,
        _magazines1,
        _magazines2
    ];
} forEach _weaponData;

private _magazineConfigData = getArray (missionConfigFile >> "CfgWLCustomization" >> "magazines");

private _magazineData = _allMagazines apply {
    private _magazine = _x;
    private _magazineName = getText (configFile >> "CfgMagazines" >> _magazine >> "displayName");
    private _magazineIcon = (getText (configFile >> "CfgMagazines" >> _magazine >> "picture")) regexReplace ["^\\", ""];
    private _mass = getNumber (configFile >> "CfgMagazines" >> _magazine >> "mass");
    private _count = getNumber (configFile >> "CfgMagazines" >> _magazine >> "count");
    [_magazine, _magazineName, _magazineIcon, _mass, _count];
};

private _magazineDataText = toJSON _magazineData;
private _magazineDataTextArray = toArray _magazineDataText;
{
    if (_x == 160) then {
        _magazineDataTextArray set [_forEachIndex, 32];
    };
} forEach _magazineDataTextArray;
_magazineDataText = toString _magazineDataTextArray;
_magazineDataText = _texture ctrlWebBrowserAction ["ToBase64", _magazineDataText];

private _weaponDataText = toJSON _weaponOptionArray;
private _weaponDataTextArray = toArray _weaponDataText;
{
    if (_x == 160) then {
        _weaponDataTextArray set [_forEachIndex, 32];
    };
} forEach _weaponDataTextArray;
_weaponDataText = toString _weaponDataTextArray;
_weaponDataText = _texture ctrlWebBrowserAction ["ToBase64", _weaponDataText];

private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];

private _loadout = profileNamespace getVariable [format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _loadoutIndex], []];
if (count _loadout == 0) then {
    _loadout = getUnitLoadout player;
};

private _loadoutText = toJSON _loadout;
_loadoutText = _texture ctrlWebBrowserAction ["ToBase64", _loadoutText];

private _imageCache = missionNamespace getVariable ["WLC_imageCache", createHashMap];
{
    private _imageUrl = _x;
    private _imageData = _y;

    _imageUrl = _texture ctrlWebBrowserAction ["ToBase64", _imageUrl];
    _imageData = _texture ctrlWebBrowserAction ["ToBase64", _imageData];

    private _addImageCacheScript = format [
        "addToImageCache(atob(""%1""), atob(""%2""));",
        _imageUrl,
        _imageData
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _addImageCacheScript];
} forEach _imageCache;

private _playerLevel = ["getLevel"] call WLC_fnc_getLevelInfo;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _themeIndex = _settingsMap getOrDefault ["loadoutTheme", 1];

private _script = format [
    "updateLoadout(atob(""%1""), %2, atob(""%3""), atob(""%4""), %5, %6);",
    _loadoutText,
    _loadoutIndex,
    _weaponDataText,
    _magazineDataText,
    _playerLevel,
    _themeIndex
];
_texture ctrlWebBrowserAction ["ExecJS", _script];