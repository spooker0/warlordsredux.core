APS_projectileConfig = createHashMap;

private _projectileConfig = missionConfigFile >> "WLProjectilesConfig";
private _projectileClasses = "inheritsFrom _x == (missionConfigFile >> 'WLProjectile')" configClasses _projectileConfig;
{
    private _projectileClass = configName _x;
    private _projectileAmmos = getArray (_x >> "ammo");
    private _projectileAps = getNumber (_x >> "aps");
    private _projectileCamera = getNumber (_x >> "camera") == 1;
    private _projectileConsumption = getNumber (_x >> "consumption");
    private _projectileCRAM = getNumber (_x >> "cram") == 1;
    private _projectileDazzleable = getNumber (_x >> "dazzleable") == 1;
    private _projectileESam = getNumber (_x >> "esam") == 1;
    private _projectileGPS = getNumber (_x >> "gps") == 1;
    private _projectileRemote = getNumber (_x >> "remote") == 1;
    private _projectileSam = getNumber (_x >> "sam") == 1;
    private _projectileSead = getNumber (_x >> "sead") == 1;
    private _projectileSpeedOverride = getNumber (_x >> "speed");
    private _projectileTv = getNumber (_x >> "tv") == 1;

    {
        private _ammo = _x;

        private _projectileConfig = createHashMapFromArray [
            ["aps", _projectileAps],
            ["camera", _projectileCamera],
            ["consumption", _projectileConsumption],
            ["cram", _projectileCRAM],
            ["dazzleable", _projectileDazzleable],
            ["esam", _projectileESam],
            ["gps", _projectileGPS],
            ["remote", _projectileRemote],
            ["sam", _projectileSam],
            ["sead", _projectileSead],
            ["speed", _projectileSpeedOverride],
            ["tv", _projectileTv]
        ];

        APS_projectileConfig set [_ammo, _projectileConfig];
    } forEach _projectileAmmos;
} forEach _projectileClasses;