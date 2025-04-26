params ["_inputStats", "_title"];

private _results = [];
_results pushBack format["<t size='1.5'>%1</t>", _title];

if (_title == "Total Stats") then {
    private _westWins = _inputStats getOrDefault ["westWins", 0];
    private _eastWins = _inputStats getOrDefault ["eastWins", 0];
    private _totalGames = _westWins + _eastWins;

    _results pushBack format["<t>Total Games: %1</t>", _totalGames];
    _results pushBack format["<t color='#004C99'>BLUFOR Wins: %1 (%2%%)</t>", _westWins, round (_westWins / _totalGames * 100)];
    _results pushBack format["<t color='#800000'>OPFOR Wins: %1 (%2%%)</t>", _eastWins, round (_eastWins / _totalGames * 100)];
    _results pushBack "<t size='1.5'>Assets</t>";
};

private _assetUses = [];
{
    private _asset = _x;
    private _assetStats = _y;

    if (typename _assetStats != "HASHMAP") then {
        continue;
    };

    private _buys = _assetStats getOrDefault ["buys", 0];
    private _deaths = _assetStats getOrDefault ["deaths", 0];
    private _killValue = _assetStats getOrDefault ["killValue", 0];
    private _costMap = missionNamespace getVariable ["WL2_costs", createHashMap];
    private _assetCost = _costMap getOrDefault [_asset, 0];

    if (_buys > 0) then {
        _assetCost = _assetCost max 1;
        private _kvr = _killValue / (_assetCost * (_deaths max 1)) * 100;
        private _actualTypeName = [objNull, _asset] call WL2_fnc_getAssetTypeName;
        private _color = "#ffffff";
        private _firstLetter = _asset select [0, 1];
        if (_firstLetter == "B") then {
            _color = "#004C99";
        };
        if (_firstLetter == "O") then {
            _color = "#800000";
        };
        _assetUses pushBack [_color, _buys, _deaths, _killValue, _kvr, _actualTypeName];
    };
} forEach _inputStats;

_assetUses = [_assetUses, [], { _x # 2 }, "DESCEND"] call BIS_fnc_sortBy;
{
    _x params ["_color", "_buys", "_deaths", "_killValue", "_kvr", "_actualTypeName"];
    private _displayString = format [
        "<t color='%1'>Bought: <t>%2</t>, Deaths: %3, Kill Value: %4 (KVR: %5%%) <t align='right'>%6</t></t>",
        _color,
        _buys,
        _deaths,
        _killValue,
        _kvr toFixed 2,
        _actualTypeName
    ];

    _results pushBack _displayString;
} forEach _assetUses;

_results joinString "<br/>";