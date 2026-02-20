#include "includes.inc"

params ["_texture"];
private _playersOnTeam = (call BIS_fnc_listPlayers) select {
    side group _x == BIS_WL_playerSide
};

private _playerContributions = missionNamespace getVariable ["WL_PlayerSquadContribution", createHashMap];

private _playerInfoText = toJSON [
    getPlayerID player,
    _playersOnTeam apply {
        private _playerLevel = _x getVariable ["WL_playerLevel", "Recruit"];
        private _playerName = format ["%1 [%2]", name _x, _playerLevel];
        private _playerContribution = _playerContributions getOrDefault [getPlayerUID _x, 0];

        [getPlayerID _x, _playerName, _playerContribution]
    }
];
_playerInfoText = _texture ctrlWebBrowserAction ["ToBase64", _playerInfoText];

private _squadInfo = missionNamespace getVariable ["SQUAD_MANAGER", []];
private _squadInfoText = toJSON (_squadInfo apply {
    private _newSquadInfo = [];

    private _squadName = _x getOrDefault ["name", ""];
    _newSquadInfo set [0, _squadName];

    private _squadLeader = _x getOrDefault ["leader", ""];
    _newSquadInfo set [1, _squadLeader];

    private _squadMemberIds = _x getOrDefault ["members", []];
    private _squadMembers = [];
    {
        private _playerId = _x;
        private _player = _playersOnTeam select { getPlayerID _x == _playerId };
        if (count _player == 0) then {
            continue;
        };
        _player = _player select 0;

        private _playerLevel = _player getVariable ["WL_playerLevel", "Recruit"];
        private _playerName = format ["%1 [%2]", name _player, _playerLevel];
        private _playerContribution = _playerContributions getOrDefault [getPlayerUID _player, 0];
        private _canFastTravel = ([_player, "fastTravelSquad"] call WL2_fnc_mapButtonConditions) == "ok";
        private _canFastTravelSL = ([_player, "fastTravelSL"] call WL2_fnc_mapButtonConditions) == "ok";
        private _addFastTravelButton = (_canFastTravel || _canFastTravelSL) && {
            private _checkFastTravel = ["FTSeized", [], "", "", "", [], 0, "FastTravel"] call WL2_fnc_purchaseMenuAssetAvailability;
            _checkFastTravel # 0
        };

        _squadMembers pushBack [_playerId, _playerName, _playerContribution, _addFastTravelButton];
    } forEach _squadMemberIds;
    _newSquadInfo set [2, _squadMembers];

    _newSquadInfo set [3, [_x getOrDefault ["side", ""], false] call WL2_fnc_sideToFaction];
    _newSquadInfo
});
_squadInfoText = _texture ctrlWebBrowserAction ["ToBase64", _squadInfoText];

private _script = format [
    "updateSquadData(atobr(""%1""), atobr(""%2""));",
    _playerInfoText,
    _squadInfoText
];
_texture ctrlWebBrowserAction ["ExecJS", _script];