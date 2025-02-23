#include "..\warlords_constants.inc"

private _results = [];
_results pushBack "<t size='1.5'>Purchase Summary</t>";

private _stats = missionNamespace getVariable ["WL_stats", createHashMap];
{
    private _side = _x;

    private _sideDisplay = if (_side == west) then {
        "BLUFOR"
    } else {
        "OPFOR"
    };
    _results pushBack format ["<t size='1.2'>%1</t>", _sideDisplay];

    private _assetUses = [];
    private _sideBuysVarStat = format ["%1Buys", toLower str _side];
    {
        private _asset = _x;
        private _assetStats = _y;

        private _buys = _assetStats getOrDefault [_sideBuysVarStat, 0];
        if (_buys > 0) then {
            private _actualTypeName = [objNull, _asset] call WL2_fnc_getAssetTypeName;
            _assetUses pushBack [_actualTypeName, _buys];
        };
    } forEach _stats;

    _assetUses = [_assetUses, [], { _x # 1}, "DESCEND"] call BIS_fnc_sortBy;
    {
        _results pushBack format ["<t>%1: %2</t>", _x # 0, _x # 1];
    } forEach _assetUses;
} forEach BIS_WL_competingSides;

missionNamespace setVariable ["WL_endScreen", _results joinString "<br/>", true];