private _buildings = nearestObjects [player, ["House", "Building"], 50, true];
_buildings = _buildings select {
    private _boundingBox = boundingBoxReal _x;
    private _minBound = _boundingBox # 0;
    private _maxBound = _boundingBox # 1;
    private _buildingArea = (_maxBound # 0 - _minBound # 0) * (_maxBound # 1 - _minBound # 1);
    private _xMin = _boundingBox # 0 # 0;
    private _xMax = _boundingBox # 1 # 0;
    private _yMin = _boundingBox # 0 # 1;
    private _yMax = _boundingBox # 1 # 1;
    private _playerPosModel = _x worldToModel (getPosATL player);
    _playerPosModel = _playerPosModel vectorMultiply 0.8;

    _playerPosModel # 0 > _xMin && _playerPosModel # 0 < _xMax &&
    _playerPosModel # 1 > _yMin && _playerPosModel # 1 < _yMax &&
    _buildingArea > 80 &&
    (_x getVariable ["BIS_WL_ownerAsset", "123"]) == "123"
};
_buildings = [_buildings, [], {
    getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "cost");
}, "DESCEND"] call BIS_fnc_sortBy;

_buildings