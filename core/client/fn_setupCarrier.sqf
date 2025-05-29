params ["_carrier", "_carrierIndex"];

private _ropeLocations = [
    [35.9911, 180.624, 21.3177],
    [-32.1693, -98.2178, 20.4236],
    [-42.1925, 181.745, 21.385],
    [27.6964, -120.231, 17.6292]
];
private _ropeDirections = [-140, -234, -238, -60];

{
    private _ropeLocation = _x;

    private _ropePosition = _carrier modelToWorldWorld _ropeLocation;
    private _rope = createSimpleObject ["Land_Rope_F", _ropePosition, true];
    _rope setDir (getDir _carrier + _ropeDirections # _forEachIndex);
    _rope setPosASL _ropePosition;

    private _marker = format ["carrier%1_rappel%2", _carrierIndex, _forEachIndex];
    createMarkerLocal [_marker, _ropePosition];
    _marker setMarkerTypeLocal "loc_Quay";
    if (_forEachIndex == 0) then {
        _marker setMarkerTextLocal "Rappels";
    };
    _marker setMarkerAlphaLocal 0.4;
    _marker setMarkerSizeLocal [0.7, 0.7];

    private _existingRopes = missionNamespace getVariable ["WL2_rappelRopes", []];
    _existingRopes pushBack _rope;
    missionNamespace setVariable ["WL2_rappelRopes", _existingRopes];
} forEach _ropeLocations;

private _mapCorners = [
    [-42.1613, 181.279],
    [35.7542, 180.22],
    [45.2289, 151.741],
    [48.8496, -64.2634],
    [25.8689, -93.7058],
    [15.1261, -184.609],
    [-14.4983, -184.502],
    [-22.39, -98.7155],
    [-41.8882, -70.9325]
];

private _carrierLines = [];
for "_i" from 0 to (count _mapCorners - 1) do {
    private _mapCorner = _mapCorners # _i;
    private _cornerPosition = _carrier modelToWorld _mapCorner;
    _carrierLines pushBack (_cornerPosition # 0);
    _carrierLines pushBack (_cornerPosition # 1);
};

private _firstPosition = _carrier modelToWorld (_mapCorners # 0);
_carrierLines pushBack (_firstPosition # 0);
_carrierLines pushBack (_firstPosition # 1);

private _lineMarkerName = format ["carrier%1_polyline", _carrierIndex];
private _lineMarker = createMarkerLocal [_lineMarkerName, _carrier];
_lineMarker setMarkerShapeLocal "POLYLINE";
_lineMarker setMarkerColorLocal "ColorRed";
_lineMarker setMarkerPolylineLocal _carrierLines;

private _airSpawns = [
    [-21.3942, -62.6318, 24],
    [5.91833, -62.445, 24],
    [21.9563, 38.583, 24],
    [36.9741, 58.3865, 24]
];
private _airSpawnDirections = [-185.425, -181.902, -183.587, -180];

private _carrierSector = _carrier getVariable ["WL_carrierSector", objNull];
private _carrierAirSpawns = [];
{
    private _spawnPosition = _carrier modelToWorld _x;
    _spawnPosition = AGLtoASL _spawnPosition;
    _spawnPosition = ASLtoATL _spawnPosition;   // AGL -> ASL -> ATL
    private _spawnDirection = (_airSpawnDirections # _forEachIndex) + getDir _carrier;
    _carrierAirSpawns pushBack [_spawnPosition, _spawnDirection];
} forEach _airSpawns;
_carrierSector setVariable ["WL2_aircraftCarrierAir", _carrierAirSpawns];

private _infSpawns = [
    [2.3512, -68.5667, 23.5344],
    [16.9811, -28.2469, 23.5392],
    [8.98328, -2.32001, 23.5359],
    [-14.2877, 6.54578, 23.5385],
    [25.2404, 14.5646, 23.5462],
    [25.3763, 58.7053, 23.538],
    [-21.733, 84.2269, 23.5282],
    [-5.87646, 99.9138, 23.5284],
    [9.86609, 128.98, 23.5283],
    [27.082, 167.024, 19.7198],
    [-15.99, 159.867, 23.5421]
];
private _carrierInfSpawns = [];
{
    private _spawnPosition = _carrier modelToWorld _x;
    _carrierInfSpawns pushBack _spawnPosition;
} forEach _infSpawns;
_carrierSector setVariable ["WL2_aircraftCarrierInf", _carrierInfSpawns];