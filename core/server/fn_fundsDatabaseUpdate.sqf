#include "includes.inc"
if !(isServer) exitWith {};

private _nextFullUpdate = serverTime + 60;
while { !BIS_WL_missionEnd } do {
    uiSleep 1;

    private _database = serverNamespace getVariable "fundsDatabase";
    private _allPlayers = call BIS_fnc_listPlayers;
    if (serverTime >= _nextFullUpdate) then {
        private _trimmedDatabase = createHashMap;
        {
            private _uid = getPlayerUID _x;
            if (_uid != "" && _uid in _database) then {
                private _funds = _database getOrDefault [_uid, 0];
                _trimmedDatabase set [_uid, _funds];
                _x setVariable ["WL2_lastFundsUpdate", _funds];
            };
        } forEach _allPlayers;

        missionNamespace setVariable ["fundsDatabaseClients", _trimmedDatabase, true];
        _nextFullUpdate = serverTime + 60;
    } else {
        {
            private _uid = getPlayerUID _x;
            if (_uid == "" || !(_uid in _database)) then {
                continue;
            };

            private _funds = _database getOrDefault [_uid, 0];
            private _lastFunds = _x getVariable ["WL2_lastFundsUpdate", -1];

            if (_funds isEqualTo _lastFunds) then {
                continue;
            };

            [_uid, _funds] remoteExec ["WL2_fnc_fundsDatabaseClient", owner _x];
            _x setVariable ["WL2_lastFundsUpdate", _funds];
        } forEach _allPlayers;
    };
};
