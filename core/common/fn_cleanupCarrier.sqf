#include "..\warlords_constants.inc"

private _carriers = allMissionObjects "Land_Carrier_01_base_F";

private _changeAttackStatus = {
    params ["_carrier", "_markers"];

    private _sector = _carrier getVariable ["WL_carrierSector", objNull];

    private _carrierProps = _carrier getVariable ["WL_carrierProps", []];
    private _isUnderAttack = _carrier getVariable ["WL_carrierUnderAttack", false];
    {
        _x hideObject !_isUnderAttack;
    } forEach _carrierProps;

    private _carrierData = _sector getVariable ["WL_aircraftCarrier", []];
    private _markers = _carrierData # 3;

    if (_isUnderAttack) then {
        {
            _x setMarkerAlphaLocal 1;
        } forEach _markers;
    } else {
        {
            _x setMarkerAlphaLocal 0;
        } forEach _markers;
    };
};

{
    private _carrier = _x;
    private _sector = (BIS_WL_allSectors select {
        _x distance2D _carrier < 500;
    }) # 0;
    _carrier setVariable ["WL_carrierSector", _sector];

    private _carrierProps = (allMissionObjects "") select {
        _x inArea (_sector getVariable "objectAreaComplete") && { damage _x == 0.5 };
    };
    _carrier setVariable ["WL_carrierProps", _carrierProps];

    private _carrierData = _sector getVariable ["WL_aircraftCarrier", []];
    private _carrierMarkers = _carrierData # 2;

    private _carrierMarkerPos = _carrierMarkers apply {getMarkerPos _x};
    private _carrierLines = [];
    for "_i" from 0 to (count _carrierMarkers - 1) do {
        private _markerPos = _carrierMarkerPos # _i;
        _carrierLines pushBack (_markerPos # 0);
        _carrierLines pushBack (_markerPos # 1);
    };
    _carrierLines pushBack (_carrierMarkerPos # 0 # 0);
    _carrierLines pushBack (_carrierMarkerPos # 0 # 1);

    private _lineMarker = createMarkerLocal [format ["carrierPolyline_%1", _forEachIndex], _carrier];
    _lineMarker setMarkerShapeLocal "POLYLINE";
    _lineMarker setMarkerColorLocal "ColorRed";
    _lineMarker setMarkerPolylineLocal _carrierLines;

    [_carrierData] call WL2_fnc_prepareRappel;
} forEach _carriers;

// Ensure sync
[_carriers, _changeAttackStatus] spawn {
    params ["_carriers", "_changeAttackStatus"];

    while { !BIS_WL_missionEnd } do {
        sleep 30;
        {
            private _carrier = _x;
            [_carrier] call _changeAttackStatus;
        } forEach _carriers;
    };
};

while { !BIS_WL_missionEnd } do {
    {
        if (isNil "BIS_WL_currentTarget_west" || isNil "BIS_WL_currentTarget_east") then {
            sleep 5;
            continue;
        };
        private _carrier = _x;

        private _sector = _carrier getVariable ["WL_carrierSector", objNull];
        private _wasUnderAttack = _carrier getVariable ["WL_carrierUnderAttack", false];
        private _isUnderAttack = BIS_WL_currentTarget_west == _sector || BIS_WL_currentTarget_east == _sector;
        if (_wasUnderAttack != _isUnderAttack) then {
            _carrier setVariable ["WL_carrierUnderAttack", _isUnderAttack];
            [_carrier] call _changeAttackStatus;
        };
    } forEach _carriers;

    sleep 5;
};