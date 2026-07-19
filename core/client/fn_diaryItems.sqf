#include "includes.inc"

if (isDedicated) exitWith {};

player createDiarySubject ["Warlords Redux", "Warlords Redux"];

call GFE_fnc_credits;

private _changeNotes = player createDiaryRecord ["Warlords Redux","", taskNull, "", false];
private _changeNotesText = format ["<font color='#CCCCCC' size='18'>Changes Notes</font><br/><br/>%1", (loadfile "update.txt") regexReplace ["\n", "<br />"]];
player setDiaryRecordText [["Warlords Redux", _changeNotes], ["Change Notes", _changeNotesText]];

private _helpAA = player createDiaryRecord ["Warlords Redux","", taskNull, "", false];
player setDiaryRecordText [["Warlords Redux", _helpAA], ["Help: Air Defense", (loadfile localize "STR_WL_fileHelpAA") regexReplace ["\n", "<br />"]]];

private _helpCap = player createDiaryRecord ["Warlords Redux","", taskNull, "", false];
player setDiaryRecordText [["Warlords Redux", _helpCap], ["Help: Capture Rules", (loadfile localize "STR_WL_fileHelpCapture") regexReplace ["\n", "<br />"]]];

private _infoAssetKeys = createHashMapFromArray [
    ["airRadar", "AESA Radar Range"],
    ["aps", "APS Type"],
    ["buys", "[Server Stats] Buys"],
    ["capValue", "Capture Strength"],
    ["conversion", "Replace Deployer"],
    ["deaths", "[Server Stats] Deaths"],
    ["demolishable", "Demolish Health"],
    ["demolishStepTime", "Demolish Step Time"],
    ["detonate", "Explosion Damage (IED)"],
    ["disableDamage", "Disable External Damage"],
    ["disableParadrop", "Disable Paradrop"],
    ["disallowMagazines", "Disabled Magazines"],
    ["drone", "Manual Drone"],
    ["dumbMine", "AT Minefield Parameters"],
    ["fragileDrone", "Fragile Drone"],
    ["hasAutoSam", "Has Auto SAM"],
    ["hasDroneHunter", "Has Drone Jammer"],
    ["hasFastTravel", "Fast Travel Target"],
    ["hasGunnerAction", "Can Swap Pilot/Gunner"],
    ["hasHMD", "Has HMD"],
    ["hasRearm", "Has Rearm Capability"],
    ["hasReconOptics", "Has Recon Optics"],
    ["hasRefuel", "Has Refuel Capability"],
    ["hasRepair", "Has Repair Capability"],
    ["hasSling", "Can Slingload Vehicles"],
    ["hasTurretVisualizer", "Has Turret Visualizer"],
    ["hideTurret", "Hide Main Turret"],
    ["integralWeapon", "Integral Weapon Parameters"],
    ["isHeavyLift", "Can Lift Heavy Loads"],
    ["isLight", "Reduced Weight"],
    ["isRadar", "Has Auto Radar"],
    ["killValue", "[Server Stats] Kill Value Total"],
    ["kvr", "[Server Stats] KVR"],
    ["loadable", "Can Load On Helo/Flatbed"],
    ["loaded", "Can Deploy Item"],
    ["nameShort", "Shortened Name"],
    ["obstacle", "Obstacle Type"],
    ["offset", "Deploy Offset"],
    ["rearm", "Rearm Time"],
    ["side", "Spawnable By Sides"],
    ["singleton", "Maximum Personal Limit"],
    ["showToEnemies", "Visible To Enemy Maps Range"],
    ["threatDetection", "Threat Detector Range"],
    ["vehicleSpawn", "Independent Sector Can Spawn"]
];

private _infoAssetCategories = createHashMapFromArray [
    ["Air Defense", "Info: Air Defense"],
    ["Fixed Wing", "Info: Fixed Wing"],
    ["Gear", "Info: Gear"],
    ["Heavy Vehicles", "Info: Heavy Vehicles"],
    ["Infantry", "Info: Infantry"],
    ["Light Vehicles", "Info: Light Vehicles"],
    ["Naval", "Info: Naval"],
    ["Remote Control", "Info: Remote Control"],
    ["Rotary Wing", "Info: Rotary Wing"],
    ["Sector Defense", "Info: Sector Defense"],
    ["Structures", "Info: Structures"]
];

private _assetData = +WL_ASSET_DATA;
private _infoAssetPages = createHashMap;
private _serverStats = missionNamespace getVariable ["WL_serverStats", createHashMap];

{
    private _assetId = _x;
    private _assetInfo = _y;
    private _category = _assetInfo getOrDefault ["category", "Category"];

    private _sides = _assetInfo getOrDefault ["side", []];
    if (count _sides == 0) then {
        continue;
    };

    private _cost = _assetInfo getOrDefault ["cost", 0];
    if (_cost <= 0) then {
        continue;
    };

    private _assetName = [objNull, _assetId] call WL2_fnc_getAssetTypeName;

    private _infoAssetPage = _infoAssetPages getOrDefault [_category, []];
    private _existingEntry = _infoAssetPage select { _x # 0 == _assetName };
    if (count _existingEntry > 0) then {
        _existingEntry = _existingEntry # 0;
        private _existingInfo = _existingEntry # 1;
        private _existingSides = _existingInfo getOrDefault ["side", []];
        _existingSides append _sides;
    } else {
        private _assetStats = _serverStats getOrDefault [_assetId, createHashMap];
        private _buys = _assetStats getOrDefault ["buys", 0];
        _assetInfo set ["buys", _buys];

        private _deaths = _assetStats getOrDefault ["deaths", 0];
        _assetInfo set ["deaths", _deaths];

        private _killValue = _assetStats getOrDefault ["killValue", 0];
        _assetInfo set ["killValue", _killValue toFixed 0];

        private _kvr = _killValue / (_cost * (_deaths max 1)) * 100;
        _assetInfo set ["kvr", format ["%1%%", _kvr toFixed 2]];

        _infoAssetPage pushBack [_assetName, _assetInfo];
    };

    _infoAssetPages set [_category, _infoAssetPage];
} forEach _assetData;

private _infoPages = [];
{
    private _categoryId = _x;
    private _title = _y;
    private _assetsInCategory = _infoAssetPages getOrDefault [_categoryId, []];
    _assetsInCategory = [_assetsInCategory, [], {
        private _info = _x # 1;
        _info getOrDefault ["cost"]
    }, "ASCEND"] call BIS_fnc_sortBy;

    private _categoryPage = format ["<font size='18'>%1</font><br/><br/>", _title];
    {
        private _asset = _x # 0;
        private _assetInfo = _x # 1;

        private _entryTitle = format ["<font size='16'>%1</font><br/>", _asset];
        _categoryPage = _categoryPage + _entryTitle;

        private _entryLines = [];
        {
            private _key = _x;
            private _value = _y;

            if (_key in ["category", "name", "spawn", "textures", "turretOverrides"]) then {
                continue;
            };

            if (_value isEqualType 0) then {
                if (_value == 0) then {
                    continue;
                };
            };

            private _capitalizedKey = toUpper (_key select [0, 1]) + (_key select [1, count _key - 1]);
            private _keyDisplay = _infoAssetKeys getOrDefault [_key, _capitalizedKey];

            private _entryLine = format ["%1: %2<br/>", _keyDisplay, _value];
            _entryLines pushBack _entryLine;
        } forEach _assetInfo;

        _entryLines sort true;
        {
            _categoryPage = _categoryPage + _x;
        } forEach _entryLines;

        _categoryPage = _categoryPage + "<br/>";
    } forEach _assetsInCategory;

    _infoPages pushBack [_title, _categoryPage];
} forEach _infoAssetCategories;
_infoPages = [_infoPages, [], { _x # 0 }, "DESCEND"] call BIS_fnc_sortBy;

{
    private _infoDiaryRecord = player createDiaryRecord ["Warlords Redux","", taskNull, "", false];
    player setDiaryRecordText [["Warlords Redux", _infoDiaryRecord], _x];
} forEach _infoPages;