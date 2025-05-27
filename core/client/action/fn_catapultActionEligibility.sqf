params ["_asset"];

private _isInCarrierSector = count (BIS_WL_allSectors select {
    _asset inArea (_x getVariable "objectAreaComplete") && _x getVariable ["WL2_isAircraftCarrier", false]
}) > 0;

private _readyForLaunch = speed _asset < 0.5 && (vehicle player == _asset || getConnectedUAV player == _asset);

alive _asset && _readyForLaunch && _isInCarrierSector;