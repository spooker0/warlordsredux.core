#include "includes.inc"
private _carriers = allMissionObjects "Land_Carrier_01_base_F";
if (count _carriers == 0) exitWith {};

{
    private _carrier = _x;
    private _sector = BIS_WL_allSectors select {
        _x distance2D _carrier < 500;
    };
    if (count _sector == 0) then {
        continue;
    };
    _sector = _sector # 0;
    _carrier setVariable ["WL_carrierSector", _sector];

    [_x, _forEachIndex] call WL2_fnc_setupCarrier;
} forEach _carriers;