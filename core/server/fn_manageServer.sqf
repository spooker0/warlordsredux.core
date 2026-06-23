#include "includes.inc"
params ["_sender", "_action", "_param1"];

if (remoteExecutedOwner != owner _sender) exitWith {};
private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
if (!_isAdmin) exitWith {};

if (_action == "getRating") exitWith {
    private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];
    _sender setVariable ["WL2_response", _ratings, owner _sender];
};

if (_action == "setRating") then {
    private _ratings = createHashMapFromArray _param1;
    profileNamespace setVariable ["WL2_playerRatings", _ratings];
    saveProfileNamespace;
};

if (_action == "setRatingPlayer") then {
    private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];
    _ratings set _param1;
    profileNamespace setVariable ["WL2_playerRatings", _ratings];
    saveProfileNamespace;
};

if (_action == "clearRating") then {
    profileNamespace setVariable ["WL2_playerRatings", createHashMap];
    saveProfileNamespace;
};

if (_action == "getBanlist") exitWith {
    private _banlist = profileNamespace getVariable ["WL2_banlist", []];
    _sender setVariable ["WL2_response", _banlist, owner _sender];
};

if (_action == "setBanlist") then {
    private _banlist = _param1;
    profileNamespace setVariable ["WL2_banlist", _banlist];
    saveProfileNamespace;
};

if (_action == "clearBanlist") then {
    profileNamespace setVariable ["WL2_banlist", []];
    saveProfileNamespace;
};