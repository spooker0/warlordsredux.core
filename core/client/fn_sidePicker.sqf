#include "includes.inc"
["main"] call BIS_fnc_endLoadingScreen;

disableSerialization;

0 fadeEnvironment 0;

private _sidePicked = independent;
uiNamespace setVariable ["WL2_sidePicker", independent];
uiNamespace setVariable ["WL2_sidePickerBackgroundControls", []];

private _dialog = createDialog ["RscWLSidePicker", true];
_dialog displayAddEventHandler ["KeyDown", {
    params ["_control", "_key"];
    _key == 1
}];

_dialog displayAddEventHandler ["Unload", {
    params ["_display", "_exitCode"];
    {
        if !(isNull _x) then {
            _x ctrlSetText "";
        };
    } forEach (uiNamespace getVariable ["WL2_sidePickerBackgroundControls", []]);
    uiNamespace setVariable ["WL2_sidePickerBackgroundControls", nil];
}];

private _backgroundVideos = [
    ["a3\data_f_argo\video\preview_argo.ogv", 724 / 1024],
    ["a3\data_f_exp\video\preview_expansion.ogv", 724 / 1024],
    ["a3\data_f_heli\video\preview_heli.ogv", 724 / 1024],
    ["a3\data_f_jets\video\preview_jets.ogv", 724 / 1024],
    ["a3\data_f_mark\video\preview_mark.ogv", 724 / 1024],
    ["a3\data_f_tacops\video\preview_tacops.ogv", 724 / 1024],
    ["a3\data_f_tank\video\preview_tank.ogv", 724 / 1024],
    ["a3\map_altis_scenes_f\video\previewvideo.ogv", 1024 / 1024],
    ["a3\ui_f_aow\video\spotlight_future.ogv", 1024 / 1024],
    ["a3\ui_f_enoch\video\spotlight_B.ogv", 1024 / 1024],
    ["a3\ui_f_orange\video\spotlight_A.ogv", 1024 / 1024],
    ["a3\ui_f_tacops\video\spotlight_A.ogv", 1024 / 1024],
    ["a3\ui_f_tacops\video\spotlight_B.ogv", 1024 / 1024],
    ["a3\ui_f_tacops\video\spotlight_C.ogv", 1024 / 1024],
    ["a3\ui_f_tank\video\spotlight_a.ogv", 1024 / 1024],
    ["a3\ui_f_tank\video\spotlight_b.ogv", 1024 / 1024]
];

private _thinVids = _backgroundVideos select { (_x select 1) < 1 };
private _backgrounds = [];
private _video1 = selectRandom _thinVids;
_backgrounds set [0, _video1];
_thinVids = _thinVids - [_video1];
private _video3 = selectRandom _thinVids;
_backgrounds set [2, _video3];
private _unusedVids = _backgroundVideos - [_video1, _video3];
private _video2 = selectRandom _unusedVids;
_backgrounds set [1, _video2];

private _backgroundGroup = _dialog displayCtrl 100;

private _leftBackground = _backgrounds select 0;
private _centerBackground = _backgrounds select 1;
private _rightBackground = _backgrounds select 2;

private _leftWidth = safeZoneH * (_leftBackground select 1) * 3 / 4;
private _centerWidth = safeZoneH * (_centerBackground select 1) * 3 / 4;
private _rightWidth = safeZoneH * (_rightBackground select 1) * 3 / 4;

private _centerX = safeZoneW / 2 - _centerWidth / 2;
private _centerRightX = _centerX + _centerWidth;
private _leftRegionWidth = _centerX;
private _rightRegionWidth = safeZoneW - _centerRightX;

private _leftX = (_leftRegionWidth - _leftWidth) / 2;
private _rightX = _centerRightX + (_rightRegionWidth - _rightWidth) / 2;

private _backgroundControls = [];

{
    _x params ["_background", "_xPos", "_width"];
    _background params ["_video", "_aspectRatio"];

    private _backgroundControl = _dialog ctrlCreate ["RscWLVideo", -1, _backgroundGroup];
    _backgroundControl ctrlEnable false;
    _backgroundControl ctrlSetPosition [_xPos, 0, _width, safeZoneH];
    _backgroundControl ctrlCommit 0;
    _backgroundControl ctrlSetText _video;
    _backgroundControls pushBack _backgroundControl;
} forEach [
    [_centerBackground, _centerX, _centerWidth],
    [_leftBackground, _leftX, _leftWidth],
    [_rightBackground, _rightX, _rightWidth]
];

uiNamespace setVariable ["WL2_sidePickerBackgroundControls", _backgroundControls];

private _westButton = _dialog displayCtrl 102;
private _eastButton = _dialog displayCtrl 103;
private _explainText = _dialog displayCtrl 104;
private _unassignedText = _dialog displayCtrl 105;

private _soundtrack = playSoundUI ["a3\music_f_orange\music\leadtrack01_f_orange.ogg", 1, 1, false, 0, true];

private _updatePlayers = {
    params ["_displayCounts"];

    private _players = call BIS_fnc_listPlayers;

    private _westPlayers = [];
    private _eastPlayers = [];
    private _unassignedPlayers = [];
    {
        if (side group _x == west) then {
            _westPlayers pushBack _x;
        };
        if (side group _x == east) then {
            _eastPlayers pushBack _x;
        };
        if (side group _x == independent) then {
            _unassignedPlayers pushBack _x;
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
        "<t align='center' shadow='0'><t size='2.5'><img size='5' image='\A3\ui_f\data\map\markers\flags\nato_ca.paa'/><br/>BLUFOR (%1)</t><br/><br/><t align='center'>%2</t></t>",
        _displayCounts # 0, _westPlayersText joinString ""
    ];
    _eastButton ctrlSetStructuredText parseText format [
        "<t align='center' shadow='0'><t size='2.5'><img size='5' image='\A3\ui_f\data\map\markers\flags\CSAT_ca.paa'/><br/>OPFOR (%1)</t><br/><br/><t align='center'>%2</t></t>",
        _displayCounts # 1, _eastPlayersText joinString ""
    ];

    private _endTime = [(estimatedEndServerTime - serverTime) max 0, "HH:MM:SS"] call BIS_fnc_secondsToString;
    private _centerTextArray = [
        "<t shadow='2' align='left'><img size='1' image='a3\ui_f\data\igui\cfg\actions\settimer_ca.paa'/></t>",
        format ["<t shadow='2' align='right'>%1</t>", _endTime],
        "<br/>", "<br/>",
        "<t shadow='2' align='left'><img size='1' color='#33ff33' image='a3\ui_f\data\igui\cfg\simpletasks\types\wait_ca.paa'/></t>",
        format ["<t shadow='2' color='#33ff33' align='right'>%1</t>", count _unassignedPlayers]
    ];
    _unassignedText ctrlSetStructuredText parseText (_centerTextArray joinString "");
};

[[0, 0]] call _updatePlayers;

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
_westButton ctrlEnable false;
_eastButton ctrlEnable false;
_explainText ctrlShow false;

private _dummyButton = _dialog displayCtrl 101;
ctrlSetFocus _dummyButton;

private _lastUpdateTime = time;
while { _sidePicked == independent && !(isNull _dialog) } do {
    private _playerEligibility = player getVariable ["WL2_playerEligibility", []];
    _playerEligibility params ["_eligibleSides", "_playerCounts"];

    _westButton ctrlEnable (west in _eligibleSides);
    _eastButton ctrlEnable (east in _eligibleSides);
    _explainText ctrlShow (count _eligibleSides < 2);

    private _selectedSide = uiNamespace getVariable ["WL2_sidePicker", independent];
    if (_selectedSide != independent) then {
        _sidePicked = _selectedSide;
        break;
    };

    if (time - _lastUpdateTime > 1) then {
        _lastUpdateTime = time;
        [_playerCounts] call _updatePlayers;
    };

    uiSleep 0.01;
};

["main"] call BIS_fnc_startLoadingScreen;

{
    if !(isNull _x) then {
        _x ctrlSetText "";
    };
} forEach _backgroundControls;

uiNamespace setVariable ["WL2_sidePickerBackgroundControls", nil];

closeDialog 0;
stopSound _soundtrack;
0 fadeEnvironment 1;

player setVariable ["WL2_playerSide", _sidePicked, [2, clientOwner]];
_sidePicked;