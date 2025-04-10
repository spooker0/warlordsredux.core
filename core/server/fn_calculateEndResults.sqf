#include "..\warlords_constants.inc"

private _stats = missionNamespace getVariable ["WL_stats", createHashMap];
private _roundStats = [_stats, "Round Stats"] call WL2_fnc_generateEndResultPage;
missionNamespace setVariable ["WL_endScreen", _roundStats, true];

private _endResultCalculated = missionNamespace getVariable ["WL_hasCalculatedEndResults", false];
if (_endResultCalculated) exitWith {};
missionNamespace setVariable ["WL_hasCalculatedEndResults", true];

private _serverStats = profileNamespace getVariable ["WL_stats", createHashMap];
{
    private _asset = _x;
    private _assetStats = _y;

    private _westBuys = _assetStats getOrDefault ["westBuys", 0];
    private _eastBuys = _assetStats getOrDefault ["eastBuys", 0];
    private _killValue = _assetStats getOrDefault ["killValue", 0];

    private _serverAsset = _serverStats getOrDefault [_asset, createHashMap];
    private _serverWestBuys = _serverAsset getOrDefault ["westBuys", 0];
    private _serverEastBuys = _serverAsset getOrDefault ["eastBuys", 0];
    private _serverKillValue = _serverAsset getOrDefault ["killValue", 0];

    _serverAsset set ["westBuys", _serverWestBuys + _westBuys];
    _serverAsset set ["eastBuys", _serverEastBuys + _eastBuys];
    _serverAsset set ["killValue", _serverKillValue + _killValue];

    _serverStats set [_asset, _serverAsset];
} forEach _stats;
profileNamespace setVariable ["WL_stats", _serverStats];
saveProfileNamespace;

private _totalStats = [_serverStats, "Total Stats"] call WL2_fnc_generateEndResultPage;
missionNamespace setVariable ["WL_endScreen2", _totalStats, true];