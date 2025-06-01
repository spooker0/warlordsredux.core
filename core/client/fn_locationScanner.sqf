#include "..\warlords_constants.inc"

0 spawn {
    while { !BIS_WL_missionEnd } do {
        sleep 1;
        private _nearbyCharges = player nearObjects ["DemoCharge_F", 50];
        private _chargeIcons = [];
        {
            _chargeIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
                [1, 0, 0, 1],
                _x modelToWorldVisual [0, 0, 0],
                0.8,
                0.8,
                0,
                "DEMO CHARGE",
                true,
                0.035,
                "RobotoCondensedBold",
                "center",
                true
            ];
        } forEach _nearbyCharges;
        uiNamespace setVariable ["WL2_chargesDrawIcons", _chargeIcons];
    };
};

addMissionEventHandler ["Draw3D", {
    private _drawIcons = uiNamespace getVariable ["WL2_chargesDrawIcons", []];
    {
        drawIcon3D _x;
    } forEach _drawIcons;
}];

private _side = BIS_WL_playerSide;
while { !BIS_WL_missionEnd } do {
    private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
    private _allScannedUnits = [];
    {
        private _stronghold = _x;
        private _strongholdInSector = BIS_WL_allSectors select {
            _stronghold inArea (_x getVariable "objectAreaComplete")
        };
        if (count _strongholdInSector == 0) then {
            continue;
        };

        private _strongholdSector = _strongholdInSector # 0;
        _stronghold setVariable ["WL_strongholdSector", _strongholdSector];

        private _sectorOwner = _strongholdSector getVariable ["BIS_WL_owner", independent];
        if (_sectorOwner != _side) then { continue; };
        private _strongholdArea = _strongholdSector getVariable ["WL_strongholdMarker", ""];
        private _scannedUnits = [_side, _strongholdArea] call WL2_fnc_detectUnits;
        _allScannedUnits append _scannedUnits;
    } forEach _strongholds;

    private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];

    {
        private _forwardBase = _x;

        if (_forwardBase getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side) then {
            private _forwardBaseArea = [_forwardBase, WL_FOB_RANGE, WL_FOB_RANGE, 0, false];
            private _scannedUnits = [_side, _forwardBaseArea] call WL2_fnc_detectUnits;
            _allScannedUnits append _scannedUnits;
        } else {
            private _sectorsInRange = _forwardBase getVariable ["WL2_forwardBaseSectors", []];
            _sectorsInRange = _sectorsInRange select {
                _x getVariable ["BIS_WL_owner", independent] == _side
            };
            _forwardBase setVariable ["WL2_forwardBaseShowOnMap", count _sectorsInRange > 0];
        };
    } forEach _forwardBases;

    {
        _side reportRemoteTarget [_x, 5];
    } forEach _allScannedUnits;

    missionNamespace setVariable ["WL2_detectedUnits", _allScannedUnits];
    sleep 2;
};