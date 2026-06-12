#include "includes.inc"

uiSleep 5;

private _factories = [];
private _factoriesConfig = missionConfigFile >> "CfgWarlordFactories";
private _factoriesClasses = "true" configClasses _factoriesConfig;
{
    private _position = getArray (_x >> "position");
    private _direction = getNumber (_x >> "direction");
    private _factory = createSimpleObject ["Land_RepairDepot_01_tan_F", [0 , 0, 0]];

    _factory setDir _direction;
    _factory setPosASL (AGLtoASL _position);

    _factories pushBack _factory;
} forEach _factoriesClasses;

private _factoryTypes = getArray (_factoriesConfig >> "factoryTypes");

{
    if (count _factoryTypes == 0) then {
        continue;
    };

    private _factory = _x;

    private _findCurrentOwnedSector = BIS_WL_allSectors select {
        _factory inArea (_x getVariable "objectAreaComplete")
    };
    private _sector = if (count _findCurrentOwnedSector > 0) then {
        _findCurrentOwnedSector # 0;
    } else {
        objNull;
    };
    if (isNull _sector) then {
        continue;
    };
    _factory setVariable ["WL2_factorySector", _sector];

    private _factoryType = selectRandom _factoryTypes;
    _factory setVariable ["WL2_factoryType", _factoryType];

    private _computer = createVehicle ["Land_MultiScreenComputer_01_sand_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];

    private _computerPos = _factory modelToWorldWorld [-0.5, 0, -0.6];
    _computer setDir (getDir _factory + 90);
    _computer setPosWorld _computerPos;

    _computer allowDamage false;
    _computer enableSimulationGlobal false;

    private _className = _factoryType # 0;

    private _spawnClass = WL_ASSET(_className, "spawn", _className);
    private _spawnClassIcon = getText (configFile >> "CfgVehicles" >> _spawnClass >> "picture");
    private _factoryTypeName = [objNull, _className] call WL2_fnc_getAssetTypeName;

    _computer setObjectTextureGlobal [1, format ["#(rgb,512,512,3)text(1,1,""PuristaBold"",0.1,""#000000"",""#ffffff"",""%1"")", _factoryTypeName]];
    _computer setObjectTextureGlobal [2, _spawnClassIcon];
    _computer setObjectTextureGlobal [3, "#(rgb,512,512,3)text(1,1,""PuristaBold"",0.15,""#000000"",""#ff0000"",""CAPTURE\nSECTOR"")"];

    _factory setVariable ["WL2_factoryComputer", _computer];

    private _marker = format ["factory_%1", _forEachIndex];
    createMarkerLocal [_marker, _computerPos];
    _marker setMarkerTypeLocal "loc_use";
    _marker setMarkerColorLocal "ColorBlack";
    _marker setMarkerAlphaLocal 1;
    _marker setMarkerSize [1, 1];   // broadcast global
    _factory setVariable ["WL2_factoryMarker", _marker];
} forEach _factories;

while { !BIS_WL_missionEnd } do {
    {
        private _factory = _x;

        private _factoryInstallable = _factory getVariable ["WL2_installable", ""];
        if (_factoryInstallable != "") then {
            _factory setVariable ["WL2_lastProduced", serverTime];
            continue;
        };

        private _factorySector = _factory getVariable ["WL2_factorySector", objNull];
        if (isNull _factorySector) then {
            continue;
        };
        private _sectorOwner = _factorySector getVariable ["BIS_WL_owner", independent];
        if (_sectorOwner == independent) then {
            continue;
        };

        private _computer = _factory getVariable ["WL2_factoryComputer", objNull];
        private _factoryType = _factory getVariable ["WL2_factoryType", ["", 0]];
        _factoryType params ["_className", "_productionTime"];

        private _lastProduced = _factory getVariable ["WL2_lastProduced", -1000];
        private _timeSinceProduced = serverTime - _lastProduced;
        if (_timeSinceProduced < _productionTime) then {
            private _spawnTime = ceil ((_productionTime - _timeSinceProduced) / 60);
            private _cachedSpawnTime = _factory getVariable ["WL2_cachedSpawnTime", -1];
            if (_spawnTime != _cachedSpawnTime) then {
                _factory setVariable ["WL2_cachedSpawnTime", _spawnTime];
                _computer setObjectTextureGlobal [3, format ["#(rgb,512,512,3)text(1,1,""PuristaBold"",0.15,""#000000"",""#ff0000"",""PRODUCING\n%1 MIN"")", _spawnTime]];
                private _marker = _factory getVariable ["WL2_factoryMarker", ""];
                _marker setMarkerColor "ColorRed";
            };
        } else {
            _factory setVariable ["WL2_lastProduced", serverTime];
            _factory setVariable ["WL2_installable", _className, true];
            _computer setObjectTextureGlobal [3, "#(rgb,512,512,3)text(1,1,""PuristaBold"",0.2,""#000000"",""#00ff00"",""READY"")"];
            private _marker = _factory getVariable ["WL2_factoryMarker", ""];
            _marker setMarkerColor "ColorBlack";
        };
    } forEach _factories;

    uiSleep 10;
};