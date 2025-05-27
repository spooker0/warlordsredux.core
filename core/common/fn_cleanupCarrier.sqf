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

    [_x, _forEachIndex] call WL2_fnc_setupCarrier;
} forEach _carriers;

// Ensure sync
[_carriers, _changeAttackStatus] spawn {
    params ["_carriers", "_changeAttackStatus"];

    while { !BIS_WL_missionEnd } do {
        {
            private _carrier = _x;
            [_carrier] call _changeAttackStatus;
        } forEach _carriers;
        sleep 30;
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