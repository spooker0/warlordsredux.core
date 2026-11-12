#include "includes.inc"

if (isDedicated) exitWith {};

private _missionName = localize "STR_WL_missionName";

player createDiarySubject [_missionName, _missionName];

call GFE_fnc_credits;

private _changeNotes = player createDiaryRecord [_missionName, "", taskNull, "", false];
private _changeNotesText = format ["<font color='#CCCCCC' size='18'>%1</font><br/><br/>%2", localize "STR_WL_diaryChangeNotes", (loadfile "update.txt") regexReplace ["\n", "<br />"]];
player setDiaryRecordText [[_missionName, _changeNotes], [localize "STR_WL_diaryChangeNotes", _changeNotesText]];

private _helpAA = player createDiaryRecord [_missionName, "", taskNull, "", false];
player setDiaryRecordText [[_missionName, _helpAA], [localize "STR_WL_diaryHelpAirDefense", (loadfile localize "STR_WL_fileHelpAA") regexReplace ["\n", "<br />"]]];

private _helpCap = player createDiaryRecord [_missionName, "", taskNull, "", false];
player setDiaryRecordText [[_missionName, _helpCap], [localize "STR_WL_diaryHelpCapture", (loadfile localize "STR_WL_fileHelpCapture") regexReplace ["\n", "<br />"]]];

private _infoAssetKeys = createHashMapFromArray [
    ["airRadar", localize "STR_WL_infoAesaRadarRange"],
    ["aps", localize "STR_WL_infoApsType"],
    ["buys", format ["<font color='#FF0000'>%1</font>", localize "STR_WL_infoBuys"]],
    ["capValue", localize "STR_WL_infoCapValue"],
    ["conversion", localize "STR_WL_infoConversion"],
    ["deaths", format ["<font color='#FF0000'>%1</font>", localize "STR_WL_infoDeaths"]],
    ["demolishable", localize "STR_WL_infoDemolishable"],
    ["demolishStepTime", localize "STR_WL_infoDemolishStepTime"],
    ["detonate", localize "STR_WL_infoDetonate"],
    ["disableDamage", localize "STR_WL_infoDisableDamage"],
    ["disableParadrop", localize "STR_WL_infoDisableParadrop"],
    ["disallowMagazines", localize "STR_WL_infoDisallowMagazines"],
    ["drone", localize "STR_WL_infoDrone"],
    ["dumbMine", localize "STR_WL_infoDumbMine"],
    ["fragileDrone", localize "STR_WL_infoFragileDrone"],
    ["hasAutoSam", localize "STR_WL_infoHasAutoSam"],
    ["hasDroneHunter", localize "STR_WL_infoHasDroneHunter"],
    ["hasFastTravel", localize "STR_WL_infoHasFastTravel"],
    ["hasGunnerAction", localize "STR_WL_infoHasGunnerAction"],
    ["hasHMD", localize "STR_WL_infoHasHmd"],
    ["hasRearm", localize "STR_WL_infoHasRearm"],
    ["hasReconOptics", localize "STR_WL_infoHasReconOptics"],
    ["hasRefuel", localize "STR_WL_infoHasRefuel"],
    ["hasRepair", localize "STR_WL_infoHasRepair"],
    ["hasSling", localize "STR_WL_infoHasSling"],
    ["hasTurretVisualizer", localize "STR_WL_infoHasTurretVisualizer"],
    ["hideTurret", localize "STR_WL_infoHideTurret"],
    ["isHeavyLift", localize "STR_WL_infoIsHeavyLift"],
    ["isLight", localize "STR_WL_infoIsLight"],
    ["isRadar", localize "STR_WL_infoIsRadar"],
    ["killValue", format ["<font color='#FF0000'>%1</font>", localize "STR_WL_infoKillValue"]],
    ["kvr", format ["<font color='#FF0000'>%1</font>", localize "STR_WL_infoKvr"]],
    ["loadable", localize "STR_WL_infoLoadable"],
    ["loaded", localize "STR_WL_infoLoaded"],
    ["nameShort", localize "STR_WL_infoNameShort"],
    ["obstacle", localize "STR_WL_infoObstacle"],
    ["offset", localize "STR_WL_infoOffset"],
    ["rearm", localize "STR_WL_infoRearm"],
    ["side", localize "STR_WL_infoSide"],
    ["singleton", localize "STR_WL_infoSingleton"],
    ["showToEnemies", localize "STR_WL_infoShowToEnemies"],
    ["threatDetection", localize "STR_WL_infoThreatDetection"],
    ["vehicleSpawn", localize "STR_WL_infoVehicleSpawn"],
    ["aircraftSpawn", localize "STR_WL_infoAircraftSpawn"],
    ["capValueEmpty", localize "STR_WL_infoCapValueEmpty"],
    ["cost", localize "STR_WL_infoCost"],
    ["decoy", localize "STR_WL_infoDecoy"],
    ["description", localize "STR_WL_infoDescription"],
    ["ewBoost", localize "STR_WL_infoEwBoost"],
    ["fragile", localize "STR_WL_infoFragile"],
    ["hasLoader", localize "STR_WL_infoHasLoader"],
    ["hasRailgun", localize "STR_WL_infoHasRailgun"],
    ["hideMap", localize "STR_WL_infoHideMap"],
    ["immobile", localize "STR_WL_infoImmobile"],
    ["lifetime", localize "STR_WL_infoLifetime"],
    ["loadRotate", localize "STR_WL_infoLoadRotate"],
    ["mineClear", localize "STR_WL_infoMineClear"],
    ["minElo", localize "STR_WL_infoMinElo"],
    ["paradrops", localize "STR_WL_infoParadrops"],
    ["reward", localize "STR_WL_infoReward"],
    ["scanner", localize "STR_WL_infoScanner"],
    ["smartMineAP", localize "STR_WL_infoSmartMineAP"],
    ["strongWheels", localize "STR_WL_infoStrongWheels"],
    ["teamLimit", localize "STR_WL_infoTeamLimit"],
    ["unitSpawn", localize "STR_WL_infoUnitSpawn"],
    ["variant", localize "STR_WL_infoVariant"],
    ["pod", localize "STR_WL_infoPod"],
    ["radius", localize "STR_WL_infoRadius"],
    ["range", localize "STR_WL_infoRange"],
    ["duration", localize "STR_WL_infoDuration"],
    ["cooldown", localize "STR_WL_infoCooldown"],
    ["ammo", localize "STR_WL_infoAmmo"],
    ["max", localize "STR_WL_infoMax"],
    ["min", localize "STR_WL_infoMin"],
    ["speed", localize "STR_WL_infoSpeed"],
    ["armor", localize "STR_WL_infoArmor"],
    ["health", localize "STR_WL_infoHealth"],
    ["damage", localize "STR_WL_infoDamage"],
    ["time", localize "STR_WL_infoTime"],
    ["delay", localize "STR_WL_infoDelay"],
    ["interval", localize "STR_WL_infoInterval"],
    ["count", localize "STR_WL_infoCount"],
    ["limit", localize "STR_WL_infoLimit"],
    ["type", localize "STR_WL_infoType"],
    ["mode", localize "STR_WL_infoMode"],
    ["capacity", localize "STR_WL_infoCapacity"],
    ["fuel", localize "STR_WL_infoFuel"]
];

private _infoAssetCategories = createHashMapFromArray [
    ["Air Defense", localize "STR_WL_diaryInfoAirDefense"],
    ["Fixed Wing", localize "STR_WL_diaryInfoFixedWing"],
    ["Gear", localize "STR_WL_diaryInfoGear"],
    ["Heavy Vehicles", localize "STR_WL_diaryInfoHeavyVehicles"],
    ["Infantry", localize "STR_WL_diaryInfoInfantry"],
    ["Light Vehicles", localize "STR_WL_diaryInfoLightVehicles"],
    ["Naval", localize "STR_WL_diaryInfoNaval"],
    ["Remote Control", localize "STR_WL_diaryInfoRemoteControl"],
    ["Rotary Wing", localize "STR_WL_diaryInfoRotaryWing"],
    ["Sector Defense", localize "STR_WL_diaryInfoSectorDefense"],
    ["Structures", localize "STR_WL_diaryInfoStructures"]
];

private _ignoredProperties = [
    "allowPylonMagazines", "ammoOverrides", "attachments", "category", "container", "disallowMagazines", "integralWeapon", "name", "spawn", "textures", "turretOverrides"
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

            if (_key in _ignoredProperties) then {
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
    private _infoDiaryRecord = player createDiaryRecord [_missionName, "", taskNull, "", false];
    player setDiaryRecordText [[_missionName, _infoDiaryRecord], _x];
} forEach _infoPages;