params ["_side"];

while { !BIS_WL_missionEnd } do {
    private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
    private _strongholdScannedUnits = [];
    {
        private _strongholdSector = _x getVariable ["WL_strongholdSector", objNull];
        if (isNull _strongholdSector) then { continue; };
        private _sectorOwner = _strongholdSector getVariable ["BIS_WL_owner", independent];
        if (_sectorOwner != _side) then { continue; };
        private _strongholdArea = _strongholdSector getVariable ["WL_strongholdMarker", ""];
        private _scannedUnits = [_side, _strongholdArea] call WL2_fnc_detectUnits;
        _strongholdScannedUnits append _scannedUnits;
    } forEach _strongholds;
    {
        _side reportRemoteTarget [_x, 5];
    } forEach _strongholdScannedUnits;
    missionNamespace setVariable ["WL2_strongholdDetectedUnits", _strongholdScannedUnits];
    sleep 2;
};