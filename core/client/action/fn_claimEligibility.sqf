params ["_target", "_caller"];
private _callerSide = side group _caller;
private _isAlive = alive _target;
private _crew = crew _target;
private _hasNoCrew = count (_crew select {alive _x}) == 0;
private _isNotOwner = getPlayerUID _caller != (_target getVariable ["BIS_WL_ownerAsset", "123"]);
private _isNotSameSide = _callerSide != (_target getVariable ["BIS_WL_ownerAssetSide", sideUnknown]);
private _isNotUAV = !unitIsUAV _target;

private _assetActualType = _target getVariable ["WL2_orderedClass", typeOf _target];
private _demolishable = missionNamespace getVariable ["WL2_demolishable", createHashMap];
private _isStructureNotInEnemySector = if (_demolishable getOrDefault [_assetActualType, false]) then {
    private _currentSector = BIS_WL_allSectors select {
        _target inArea (_x getVariable "objectAreaComplete");
    };
    if (count _currentSector > 0) then {
        private _sector = _currentSector # 0;
        private _sectorSide = _sector getVariable ["BIS_WL_owner", sideUnknown];
        _callerSide == _sectorSide
    } else {
        true
    };
} else {
    true;
};

_isAlive && _hasNoCrew && _isNotOwner && _isNotSameSide && _isNotUAV && _isStructureNotInEnemySector;