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

    private _buys = _assetStats getOrDefault ["buys", 0];
    private _killValue = _assetStats getOrDefault ["killValue", 0];
    private _deaths = _assetStats getOrDefault ["deaths", 0];

    private _serverAsset = _serverStats getOrDefault [_asset, createHashMap];
    private _serverBuys = _serverAsset getOrDefault ["buys", 0];
    private _serverDeaths = _serverAsset getOrDefault ["deaths", 0];
    private _serverKillValue = _serverAsset getOrDefault ["killValue", 0];

    _serverAsset set ["buys", _serverBuys + _buys];
    _serverAsset set ["deaths", _serverDeaths + _deaths];
    _serverAsset set ["killValue", _serverKillValue + _killValue];

    _serverStats set [_asset, _serverAsset];
} forEach _stats;

private _gameWinner = missionNamespace getVariable ["WL2_gameWinner", sideUnknown];
if (_gameWinner == west) then {
    _serverStats set ["westWins", (_serverStats getOrDefault ["westWins", 0]) + 1];
};
if (_gameWinner == east) then {
   _serverStats set ["eastWins", (_serverStats getOrDefault ["eastWins", 0]) + 1];
};

profileNamespace setVariable ["WL_stats", _serverStats];
saveProfileNamespace;

private _totalStats = [_serverStats, "Total Stats"] call WL2_fnc_generateEndResultPage;
missionNamespace setVariable ["WL_endScreen2", _totalStats, true];