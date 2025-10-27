#include "includes.inc"
private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));

private _checkDirty = {
    params ["_varName"];
    private _storedVar = profileNamespace getVariable [_varName, createHashMap];
    private _currentVar = player getVariable [_varName, createHashMap];

    private _currentCount = count _currentVar;
    private _dirty = if (count _storedVar != _currentCount) then {
        true
    } else {
        private _isDirty = false;
        {
            private _key = _x;
            private _storedValue = _storedVar getOrDefault [_key, ""];
            private _currentValue = _currentVar getOrDefault [_key, ""];
            if (_storedValue isNotEqualTo _currentValue) then {
                _isDirty = true;
                break;
            };
        } forEach _currentVar;
        _isDirty;
    };
    if (_dirty) then {
        player setVariable [_varName, _storedVar, true];
    };
};

while { !BIS_WL_missionEnd } do {
    if (_isAdmin || _isModerator) then {
        private _allPlayers = call BIS_fnc_listPlayers;
        private _playerAliases = profileNamespace getVariable ["WL2_playerAliases", createHashMap];
        {
            private _uid = getPlayerUID _x;
            private _existingAliases = _playerAliases getOrDefault [_uid, []];
            _existingAliases pushBackUnique ([_x] call BIS_fnc_getName);
            _playerAliases set [_uid, _existingAliases];
        } forEach _allPlayers;
        profileNamespace setVariable ["WL2_playerAliases", _playerAliases];
    };

    ["WL2_playerReports"] call _checkDirty;
    ["WL2_playerTransfers"] call _checkDirty;
    ["WL2_afkLog"] call _checkDirty;

    uiSleep 10;
};