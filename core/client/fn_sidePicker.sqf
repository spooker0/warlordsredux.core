#include "includes.inc"
["main"] call BIS_fnc_endLoadingScreen;

private _sidePicked = independent;
uiNamespace setVariable ["WL2_sidePicker", independent];

private _dialog = createDialog ["RscWLSidePicker", true];
_dialog displayAddEventHandler ["KeyDown", {
    params ["_control", "_key"];
    _key == 1
}];

private _selectLabel = _dialog displayCtrl 101;
private _westButton = _dialog displayCtrl 102;
private _eastButton = _dialog displayCtrl 103;
private _explainText = _dialog displayCtrl 104;

private _players = allPlayers;

private _westPlayers = [];
private _eastPlayers = [];
{
    if (side group _x == west) then {
        _westPlayers pushBack _x;
    };
    if (side group _x == east) then {
        _eastPlayers pushBack _x;
    };
} forEach _players;

private _westPlayersText = [];
private _eastPlayersText = [];
{
    _x params ["_sidePlayers", "_playersText"];
    {
        private _index = _forEachIndex % 3;
        private _playerName = format ["%1 (%2)", (name _x) select [0, 15], _x getVariable ["WL2_playerRating", WL_RATING_STARTER]];
        if (_index == 0) then {
            _playersText pushBack format ["<t align='left'>%1</t>", _playerName];
        };
        if (_index == 1) then {
            _playersText pushBack format ["<t align='center'>%1</t>", _playerName];
        };
        if (_index == 2) then {
            _playersText pushBack format ["<t align='right'>%1</t><br/>", _playerName];
        };
    } forEach _sidePlayers;
} forEach [[_westPlayers, _westPlayersText], [_eastPlayers, _eastPlayersText]];

_westButton ctrlSetStructuredText parseText format [
    "<t align='center' shadow='0'><t size='2.5'><img size='5' image='\A3\ui_f\data\map\markers\flags\nato_ca.paa'/><br/>BLUFOR</t><br/><br/><t align='center'>%1</t></t>",
    _westPlayersText joinString ""
];
_eastButton ctrlSetStructuredText parseText format [
    "<t align='center' shadow='0'><t size='2.5'><img size='5' image='\A3\ui_f\data\map\markers\flags\CSAT_ca.paa'/><br/>OPFOR</t><br/><br/><t align='center'>%1</t></t>",
    _eastPlayersText joinString ""
];

private _selectText = format ["<t align='center' shadow='0'>%1</t>", localize "STR_WL_sideSelect"];
_selectLabel ctrlSetStructuredText parseText _selectText;

private _explainer = [
    "<t align='center' shadow='0'>",
    format ["<t color='#ff0000'>%1</t><br/>", localize "STR_WL_sideLockedWhy"],
    format [localize "STR_WL_sideLockedPlayerDifference", WL_RATING_NUMBALANCE],
    format [localize "STR_WL_sideLockedElo", WL_RATING_GATE],
    localize "STR_WL_sideLockedArmaUnit",
    "</t>"
];
_explainText ctrlSetStructuredText parseText (_explainer joinString "");

_westButton ctrlAddEventHandler ["ButtonClick", {
    uiNamespace setVariable ["WL2_sidePicker", west];
}];
_eastButton ctrlAddEventHandler ["ButtonClick", {
    uiNamespace setVariable ["WL2_sidePicker", east];
}];

private _eligibleSides = [];
_westButton ctrlEnable (west in _eligibleSides);
_eastButton ctrlEnable (east in _eligibleSides);
_explainText ctrlShow (count _eligibleSides < 2);

private _startTime = time;
while { _sidePicked == independent && !(isNull _dialog) } do {
    _eligibleSides = player getVariable ["WL2_playerEligibility", []];
    _westButton ctrlEnable (west in _eligibleSides);
    _eastButton ctrlEnable (east in _eligibleSides);
    _explainText ctrlShow (count _eligibleSides < 2);

    private _selectedSide = uiNamespace getVariable ["WL2_sidePicker", independent];
    if (_selectedSide != independent) then {
        _sidePicked = _selectedSide;
        break;
    };

    uiSleep 0.01;
};

["main"] call BIS_fnc_startLoadingScreen;
closeDialog 0;

player setVariable ["WL2_playerSide", _sidePicked, [2, clientOwner]];
_sidePicked;