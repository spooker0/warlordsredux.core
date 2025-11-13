#include "includes.inc"
private _selectedPlayerTarget = cameraOn getVariable ["WL2_selectedTargetPlayer", objNull];

private _playerInList = false;
private _playerTargetList = [["none", "NO PLAYER SELECTED", false]];
private _allSquadmates = ["getSquadmates", [getPlayerID player, true]] call SQD_fnc_query;

{
    private _squadmate = _x;

    if (_playerTargetList findIf { _x # 0 == netid _squadmate } > -1) then {
        continue;
    };

    private _isSelected = _squadmate == _selectedPlayerTarget;
    if (_isSelected) then {
        _playerInList = true;
    };

    private _distance = cameraOn distance _squadmate;
    private _name = format ["%1 [%2KM]", toUpper (name _squadmate), (_distance / 1000) toFixed 1];
    _playerTargetList pushBack [netid _squadmate, _name, _isSelected];
} forEach _allSquadmates;

if (!_playerInList) then {
    private _autoOption = _playerTargetList # 0;
    _autoOption set [2, true];
};

_playerTargetList;