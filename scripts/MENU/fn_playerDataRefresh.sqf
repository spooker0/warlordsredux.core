private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));

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

    private _playerReports = profileNamespace getVariable ["WL2_playerReports", createHashMap];
    private _playerReportsCurrent = player getVariable ["WL2_playerReports", createHashMap];

    private _playerReportCount = count _playerReportsCurrent;
    private _playerReportDirty = if (count _playerReports != count _playerReportsCurrent) then {
        true
    } else {
        private _dirty = false;
        {
            private _key = _x;
            if (_playerReports getOrDefault [_key, ""] != _playerReportsCurrent getOrDefault [_key, ""]) then {
                _dirty = true;
                break;
            };
        } forEach _playerReportsCurrent;
        _dirty;
    };
    if (_playerReportDirty) then {
        player setVariable ["WL2_playerReports", _playerReports, true];
    };

    sleep 10;
};