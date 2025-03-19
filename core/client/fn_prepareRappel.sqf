params ["_carrierData"];

if (isDedicated) exitWith {};

private _rappelPairs = _carrierData # 3;

{
    private _marker = _x # 0;
    private _rope = _x # 1;

    createMarkerLocal [_marker, _rope];
    _marker setMarkerTypeLocal "loc_Quay";
    _marker setMarkerTextLocal "Carrier Rappel Point";
    _marker setMarkerAlphaLocal 0;

    private _existingRopes = missionNamespace getVariable ["WL2_rappelRopes", []];
    _existingRopes pushBack _rope;
    missionNamespace setVariable ["WL2_rappelRopes", _existingRopes];
} forEach _rappelPairs;