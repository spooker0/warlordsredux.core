if !(isServer) exitWith {};

params ["_database", "_uid"];

missionNamespace setVariable ["fundsDatabaseClients", _database];
private _allPlayers = call BIS_fnc_listPlayers;
{
    if (getPlayerUID _x == _uid) then {
        (owner _x) publicVariableClient "fundsDatabaseClients";
    };
} forEach _allPlayers;