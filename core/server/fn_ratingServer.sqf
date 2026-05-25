#include "includes.inc"
params ["_sender", "_action", "_param1"];

if (remoteExecutedOwner != owner _sender) exitWith {};
private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
if (!_isAdmin) exitWith {};

if (_action == "get") exitWith {
    private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];
    _ratings
};

if (_action == "set") then {
    private _ratings = createHashMapFromArray _param1;
    profileNamespace setVariable ["WL2_playerRatings", _ratings];
    saveProfileNamespace;
};

if (_action == "clear") then {
    profileNamespace setVariable ["WL2_playerRatings", createHashMap];
    saveProfileNamespace;
};