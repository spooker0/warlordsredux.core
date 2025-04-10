params ["_inputStats", "_title"];

private _results = [];
_results pushBack format["<t size='1.5'>%1</t>", _title];

private _assetUses = [];
{
    private _asset = _x;
    private _assetStats = _y;

    private _westBuys = _assetStats getOrDefault ["westBuys", 0];
    private _eastBuys = _assetStats getOrDefault ["eastBuys", 0];
    private _killValue = _assetStats getOrDefault ["killValue", 0];
    private _totalBuys = _westBuys + _eastBuys;
    private _costMap = missionNamespace getVariable ["WL2_costs", createHashMap];
    private _assetCost = _costMap getOrDefault [_asset, 0];
    _assetCost = _assetCost max 1;
    private _killCostRatio = _killValue / _assetCost / _totalBuys * 100;

    if (_totalBuys > 0) then {
        private _actualTypeName = [objNull, _asset] call WL2_fnc_getAssetTypeName;
        _assetUses pushBack [_actualTypeName, _totalBuys, _westBuys, _eastBuys, _killValue, _killCostRatio toFixed 2];
    };
} forEach _inputStats;

_assetUses = [_assetUses, [], { _x # 4 }, "DESCEND"] call BIS_fnc_sortBy;
{
    private _displayString = format [
        "Bought: <t>%1</t> (<t color='#0000ff'>BLUFOR: %2</t>, <t color='#ff0000'>OPFOR: %3</t>), Kill Value: %4 (KVR: %5%6) <t align='right'>%7</t>",
        _x # 1,
        _x # 2,
        _x # 3,
        _x # 4,
        _x # 5,
        "%",
        _x # 0
    ];

    _results pushBack _displayString;
} forEach _assetUses;

_results joinString "<br/>";