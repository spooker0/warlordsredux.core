#include "includes.inc"
if (WL_VotePhase == 2) then {
    BIS_WL_selection_availableSectors = BIS_WL_sectorsArray # 1;
    BIS_WL_selection_showLinks = true;
    BIS_WL_selection_dimSectors = true;
};

switch (BIS_WL_currentSelection) do {
    case WL_ID_SELECTION_NONE: {
        if (WL_VotePhase == 0) then {
            BIS_WL_selection_availableSectors = [];
            BIS_WL_selection_showLinks = false;
            BIS_WL_selection_dimSectors = false;
        };
    };
    case WL_ID_SELECTION_ORDERING_NAVAL: {
        BIS_WL_selection_availableSectors = [];
        BIS_WL_selection_showLinks = false;
        BIS_WL_selection_dimSectors = false;
    };
    case WL_ID_SELECTION_FAST_TRAVEL: {
        BIS_WL_selection_availableSectors = (BIS_WL_sectorsArray # 2) select {
            (_x getVariable ["BIS_WL_owner", independent]) == (side group player)
        };
        BIS_WL_selection_showLinks = false;
        BIS_WL_selection_dimSectors = true;
    };
    case WL_ID_SELECTION_FAST_TRAVEL_CONTESTED: {
        BIS_WL_selection_availableSectors = [WL_TARGET_FRIENDLY];
        BIS_WL_selection_showLinks = false;
        BIS_WL_selection_dimSectors = true;
    };
    case WL_ID_SELECTION_FAST_TRAVEL_VEHICLE: {
        BIS_WL_selection_availableSectors = (BIS_WL_sectorsArray # 2) select {
            private _isCarrierSector = _x getVariable ["WL2_isAircraftCarrier", false];
            private _sectorNotUnderAttack = _x != WL_TARGET_ENEMY;
            !_isCarrierSector && _sectorNotUnderAttack;
        };
        BIS_WL_selection_showLinks = false;
        BIS_WL_selection_dimSectors = true;
    };
    case WL_ID_SELECTION_ORDERING_AIRCRAFT: {
        private _airfieldSectors = (BIS_WL_sectorsArray # 2) select {
            private _services = _x getVariable ["WL2_services", []];
            "A" in _services;
        };

        BIS_WL_selection_availableSectors = _airfieldSectors;
        BIS_WL_selection_showLinks = false;
        BIS_WL_selection_dimSectors = true;
    };
    case WL_ID_SELECTION_FAST_TRAVEL_STRONGHOLD: {
        BIS_WL_selection_availableSectors = (BIS_WL_sectorsArray # 2) select {
            !isNull (_x getVariable ["WL_stronghold", objNull])
        };
        BIS_WL_selection_showLinks = false;
        BIS_WL_selection_dimSectors = true;
    };
    case WL_ID_SELECTION_SCAN: {
        private _allScannableSectors = BIS_WL_sectorsArray # 3;
        private _lastScanEligible = serverTime - WL_COOLDOWN_SCAN;
        private _currentScannedSectors = missionNamespace getVariable ["WL2_scanningSectors", []];
        private _availableSectors = _allScannableSectors select {
            _x getVariable ["WL2_lastScanned", -9999] < _lastScanEligible &&
            !(_x in _currentScannedSectors)
        };
        BIS_WL_selection_availableSectors = _availableSectors;
        BIS_WL_selection_showLinks = false;
        BIS_WL_selection_dimSectors = true;
    };
    case WL_ID_SELECTION_COMBAT_AIR: {
        private _airfieldSectors = (BIS_WL_sectorsArray # 2) select {
            private _services = _x getVariable ["WL2_services", []];
            "A" in _services;
        };
        private _availableSectors = _airfieldSectors select {
            (_x getVariable ["WL2_nextCombatAir", -9999]) < serverTime &&
            !(_x getVariable ["WL2_combatAirActive", false]);
        };
        BIS_WL_selection_availableSectors = _availableSectors;
        BIS_WL_selection_showLinks = false;
        BIS_WL_selection_dimSectors = true;
    };
};

if (WL_VotePhase == 1) then {
    BIS_WL_selection_availableSectors = BIS_WL_sectorsArray # 1;
    BIS_WL_selection_showLinks = true;
    BIS_WL_selection_dimSectors = true;
};

if (WL_IsSpectator || WL_IsReplaying) then {
    BIS_WL_selection_showLinks = true;
};

if (BIS_WL_selection_showLinks) then {
    {
        _x setMarkerAlphaLocal 1;
    } forEach BIS_WL_sectorLinks;
} else {
    {
        _x setMarkerAlphaLocal 0;
    } forEach BIS_WL_sectorLinks;
};

private _targetedSector = WL_SectorActionTarget;
private _sectorLinks = WL_linkSectorMarkers getOrDefault [hashValue _targetedSector, []];
{
    _x setMarkerAlphaLocal 1;
} forEach _sectorLinks;

{
    private _alpha = if (BIS_WL_selection_dimSectors && !(_x in BIS_WL_selection_availableSectors)) then {
        0.3;
    } else {
        1;
    };
    private _markers = _x getVariable ["BIS_WL_markers", []];
    (_markers # 0) setMarkerAlphaLocal _alpha;
    (_markers # 1) setMarkerAlphaLocal (_alpha * 0.5);
} forEach BIS_WL_allSectors;

private _markers = _targetedSector getVariable ["BIS_WL_markers", []];
if (count _markers > 1) then {
    private _markerArea = _markers # 1;
    private _highlightMarker = createMarkerLocal ["WL_highlightSector", getMarkerPos _markerArea];
    _highlightMarker setMarkerShapeLocal (markerShape _markerArea);
    _highlightMarker setMarkerTypeLocal (markerType _markerArea);
    _highlightMarker setMarkerColorLocal (markerColor _markerArea);
    _highlightMarker setMarkerSizeLocal (markerSize _markerArea);
    _highlightMarker setMarkerDirLocal (markerDir _markerArea);
    _highlightMarker setMarkerBrushLocal "Solid";
    _highlightMarker setMarkerAlphaLocal 1;
} else {
    deleteMarkerLocal "WL_highlightSector";
};