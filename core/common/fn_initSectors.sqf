#include "includes.inc"
private _sectorConfig = missionConfigFile >> "CfgWarlordSectors";
private _sectors = "true" configClasses _sectorConfig;

private _logicCenter = createCenter sideLogic;
private _logicGroup = createGroup _logicCenter;

private _createdSectors = createHashMap;
private _initializedSectors = [];
private _destroyerId = 0;
{
    private _sector = _x;
    private _sectorClass = configName _sector;

    private _location = getArray (_sector >> "location");
    private _logic = _logicGroup createUnit ["Logic", _location, [], 0, "NONE"];

    private _name = getText (_sector >> "name");
    _logic setVariable ["WL2_name", _name, true];

    private _disableHome = getNumber (_sector >> "disableHome");
    _logic setVariable ["WL2_canBeBase", _disableHome != 1];

    private _services = getArray (_sector >> "services");
    _logic setVariable ["WL2_services", _services, true];

    private _area = getArray (_sector >> "area");
    _area set [3, _area # 3 == 1];
    _logic setVariable ["WL2_objectArea", _area, true];

    private _destroyer = getNumber (_sector >> "destroyer");
    private _carrier = getNumber (_sector >> "carrier");

    if ((_destroyer > 0 && _destroyer < random 1) || (_carrier == 1 && random 1 < WL_DESTROYER_CHANCE)) then {
        private _actualArea = [_location, _area # 0, _area # 1, _area # 2, _area # 3];
        private _objectsInCarrier = (allMissionObjects "") inAreaArray _actualArea;
        {
            deleteVehicle _x;
        } forEach _objectsInCarrier;
        deleteVehicle _logic;

        _location set [2, 0];
        [_location, 90 + (_area # 2), _name, _destroyerId] spawn WL2_fnc_createDestroyer;
        _destroyerId = _destroyerId + 1;

        continue;
    };
    if (_destroyer > 0) then {
        deleteVehicle _logic;
        continue;
    };

    if (_carrier == 1) then {
        _logic setVariable ["WL2_isAircraftCarrier", true, true];
    };

    _logic enableSimulationGlobal false;

    _createdSectors set [_sectorClass, _logic];
    _initializedSectors pushBack _logic;
} forEach _sectors;

private _connections = getArray (_sectorConfig >> "connections");
{
    private _connection = _x;

    private _from = _connection # 0;
    private _to = _connection # 1;

    private _fromSector = _createdSectors getOrDefault [_from, objNull];
    private _toSector = _createdSectors getOrDefault [_to, objNull];

    if (isNull _fromSector || isNull _toSector) then {
        continue;
    };

    _fromSector synchronizeObjectsAdd [_toSector];

    private _fromSectorConnections = _fromSector getVariable ["WL2_connectedSectors", []];
    _fromSectorConnections pushBackUnique _toSector;
    _fromSector setVariable ["WL2_connectedSectors", _fromSectorConnections];

    private _toSectorConnections = _toSector getVariable ["WL2_connectedSectors", []];
    _toSectorConnections pushBackUnique _fromSector;
    _toSector setVariable ["WL2_connectedSectors", _toSectorConnections];
} forEach _connections;

// Set on clients
{
    private _sectorConnections = _x getVariable ["WL2_connectedSectors", []];
    _x setVariable ["WL2_connectedSectors", _sectorConnections, true];
} forEach _initializedSectors;

missionNamespace setVariable ["WL2_sectorsInitializationComplete", _initializedSectors, true];