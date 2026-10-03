#include "includes.inc"
if (!hasInterface) exitWith {};
if (!canSuspend) exitWith { _this spawn INTRO_fnc_play };
disableSerialization;

if (!isNull (uiNamespace getVariable ["INTRO_display", displayNull])) exitWith {};
private _parent = findDisplay 46;
if (isNull _parent) exitWith {};

private _sectorData = createHashMap;
{
    _sectorData set [_x, [_x] call INTRO_fnc_sectorData];
} forEach ["Molos", "SkoposCastleRuins", "Airbase", "AirbaseCompound", "MainPower", "LakkaFactory", "SouthTelos", "Anthrakia", "Rodopoli", "Paros"];
if (((values _sectorData) findIf { count _x == 0 }) != -1) exitWith {
    hint localize "STR_WL_introMissingSector";
};

private _neighbors = [];
{
    _x params ["_from", "_to"];
    if (_from == "Airbase") then { _neighbors pushBackUnique _to; };
    if (_to == "Airbase") then { _neighbors pushBackUnique _from; };
} forEach getArray (missionConfigFile >> "CfgWarlordSectors" >> "connections");
private _links = ["LakkaFactory", "MainPower", "AirbaseCompound"] select { _x in _neighbors };
{
    if (count _links >= 3) exitWith {};
    if (count ([_x] call INTRO_fnc_sectorData) > 0) then { _links pushBackUnique _x; };
} forEach _neighbors;
if (count _links < 3) exitWith {
    hint localize "STR_WL_introMissingConnections";
};
{
    _sectorData set [_x, [_x] call INTRO_fnc_sectorData];
} forEach _links;

private _assets = [
    ["a3\ui_f\data\map\vehicleicons\iconman_ca.paa", localize "STR_WL_infantry", "+1", 70, 70],
    [getText (configFile >> "CfgVehicles" >> "B_MRAP_01_hmg_F" >> "picture"), localize "STR_WL_introTransport", "+2", 180, 100],
    [getText (configFile >> "CfgVehicles" >> "O_APC_Tracked_02_cannon_F" >> "picture"), localize "STR_WL_introAPC", "+3", 180, 100],
    [getText (configFile >> "CfgVehicles" >> "B_MBT_01_cannon_F" >> "picture"), localize "STR_WL_introTank", "+5", 180, 100]
];

private _display = _parent createDisplay "INTRO_Display";
if (isNull _display) exitWith {};
uiNamespace setVariable ["INTRO_display", _display];
_display setVariable ["INTRO_closed", false];
_display setVariable ["INTRO_sectors", _sectorData];
_display setVariable ["INTRO_links", _links];
_display setVariable ["INTRO_assets", _assets];
_display setVariable ["INTRO_incomeData", [_sectorData] call INTRO_fnc_incomeData];
_display setVariable ["INTRO_skipBindings", (actionKeysEx "Gear") select {
    _x params ["_main", "_combo"];
    (_main # 1) in ["KEYBOARD", "MOUSE_BUTTON"] && { count _combo == 0 || { (_combo # 1) in ["KEYBOARD", "MOUSE_BUTTON"] } }
}];
_display setVariable ["INTRO_skipKeys", []];
_display setVariable ["INTRO_skipStart", -1];

_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    [_display, "KEYBOARD", _key, true, [_shift, _ctrl, _alt]] call INTRO_fnc_updateSkip;
    // Consume Escape and other keys before the display's default handling.
    true
}];
_display displayAddEventHandler ["KeyUp", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    [_display, "KEYBOARD", _key, false, [_shift, _ctrl, _alt]] call INTRO_fnc_updateSkip;
}];
_display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "", "", "_shift", "_ctrl", "_alt"];
    [_display, "MOUSE_BUTTON", _button, true, [_shift, _ctrl, _alt]] call INTRO_fnc_updateSkip;
    true
}];
_display displayAddEventHandler ["MouseButtonUp", {
    params ["_display", "_button", "", "", "_shift", "_ctrl", "_alt"];
    [_display, "MOUSE_BUTTON", _button, false, [_shift, _ctrl, _alt]] call INTRO_fnc_updateSkip;
}];

private _map = _display displayCtrl INTRO_MAP_IDC;
private _logo = _display displayCtrl INTRO_LOGO_IDC;
private _logoBackground = _display displayCtrl INTRO_LOGO_BACKGROUND_IDC;
private _caption = _display displayCtrl INTRO_CAPTION_IDC;
private _progress = _display displayCtrl INTRO_PROGRESS_IDC;
private _hold = _display displayCtrl INTRO_HOLD_IDC;
(_display displayCtrl INTRO_BLACKOUT_IDC) ctrlShow false;
(_display displayCtrl INTRO_ENDLOGO_IDC) ctrlShow false;
private _gearKey = ((actionKeysNames ["Gear", 1, "Combo"]) splitString (toString [34])) joinString "";
private _skipText = format [localize "STR_WL_introSkip", if (_gearKey == "") then { localize "STR_WL_introGear" } else { _gearKey }];
private _skip = _display displayCtrl INTRO_SKIP_IDC;
_skip ctrlSetText _skipText;
private _skipWidth = ((_skipText getTextWidth ["RobotoCondensed", safeZoneH * 0.026]) + safeZoneW * 0.025) max (safeZoneW * 0.17);
private _skipLeft = safeZoneX + safeZoneW * 0.965 - _skipWidth;
{
    _x ctrlSetPositionX _skipLeft;
    _x ctrlSetPositionW _skipWidth;
    _x ctrlCommit 0;
} forEach [_skip, _display displayCtrl INTRO_SKIP_FILL_IDC, _display displayCtrl INTRO_SKIP_BACKGROUND_IDC];
(_display displayCtrl INTRO_SCENE_IDC) ctrlSetPositionW (_skipLeft - safeZoneX - safeZoneW * 0.065);
(_display displayCtrl INTRO_SCENE_IDC) ctrlCommit 0;
(_display displayCtrl INTRO_SKIP_FILL_IDC) progressSetPosition 0;
_hold ctrlSetText format [localize "STR_WL_introHold", if (_gearKey == "") then { localize "STR_WL_introInventory" } else { _gearKey }];
_hold ctrlShow false;
_map ctrlEnable false;
_map ctrlShow true;
_map ctrlAddEventHandler ["Draw", { _this call INTRO_fnc_drawMap; }];

private _scenes = [
    [2, "STR_WL_introWelcome"],
    [5, "STR_WL_introObjective"],
    [5, "STR_WL_introCapturing"],
    [3, "STR_WL_introOwners"],
    [5, "STR_WL_introPurchase"],
    [4, "STR_WL_introFastTravel"],
    [6, "STR_WL_introCapturePower"],
    [8, "STR_WL_introConnections"],
    [10, "STR_WL_introRegions"],
    [8.5, "STR_WL_introFrontlineIncome"],
    [6, "STR_WL_introGoodLuck"]
];
private _narration = [] call INTRO_fnc_narrationData;
private _sceneStarts = _narration get "sceneStarts";
private _sceneDurations = _narration get "sceneDurations";
private _speechEnds = _narration get "speechEnds";
private _totalDuration = _narration get "duration";
private _overallStart = 0;
private _narrationId = -1;
private _soundtrackId = -1;
private _completed = false;
private _wait = {
    params ["_until"];
    waitUntil {
        uiSleep 0.01;
        if (!isNull _display) then {
            _progress progressSetPosition (((diag_tickTime - _overallStart) / _totalDuration) min 1);
            [_display, "update"] call INTRO_fnc_menuScene;
            if ((_display getVariable ["INTRO_scene", 0]) == 11) then {
                [_display] call INTRO_fnc_updateEnding;
            };
            [_display] call INTRO_fnc_updateSkip;
        };
        isNull _display || { _display getVariable ["INTRO_closed", false] } || { diag_tickTime >= _until }
    };
    !isNull _display && { !(_display getVariable ["INTRO_closed", false]) }
};

private _molos = (_sectorData get "Molos") get "position";
private _skopos = (_sectorData get "SkoposCastleRuins") get "position";
private _airbase = (_sectorData get "Airbase") get "position";
private _green = (_sectorData get "MainPower") get "position";
private _red = (_sectorData get "LakkaFactory") get "position";
private _area = (_sectorData get "Airbase") get "area";
private _captureZoom = ((((_area # 0) max (_area # 1)) * 3) / worldSize) max 0.018;
private _captureCenter = _airbase vectorAdd [0, -(_area # 1) * 0.3, 0];

_overallStart = diag_tickTime;
_narrationId = playSoundUI [localize "STR_WL_introNarrationSound", 2, 1, false];
_display setVariable ["INTRO_narrationId", _narrationId];
_soundtrackId = playSoundUI ["a3\music_f_tank\maintheme_f_tank.ogg", 0.2, 1, false];
_display setVariable ["INTRO_soundtrackId", _soundtrackId];
{
    if (isNull _display || { _display getVariable ["INTRO_closed", false] }) exitWith {};
    _x params ["_animationDuration", "_captionKey"];
    private _text = localize _captionKey;
    private _scene = _forEachIndex + 1;
    private _duration = _sceneDurations # _forEachIndex;
    private _started = _overallStart + (_sceneStarts # _forEachIndex);
    private _timeScale = _duration / _animationDuration;
    private _animateMap = {
        params ["_seconds", "_zoom", "_position"];
        _map ctrlMapAnimAdd [_seconds * _timeScale, _zoom, _position];
    };
    _display setVariable ["INTRO_scene", _scene];
    _display setVariable ["INTRO_sceneStart", _started];
    _display setVariable ["INTRO_sceneDuration", _duration];
    _display setVariable ["INTRO_animationScale", 1 / _timeScale];
    _display setVariable ["INTRO_speechEnd", _speechEnds # _forEachIndex];
    _display setVariable ["INTRO_cutTime", (_narration get "connectionCutAt") / _timeScale];
    [_display, "hide"] call INTRO_fnc_menuScene;
    { _x ctrlShow false; } forEach (_display getVariable ["INTRO_labelPool", []]);
    _hold ctrlShow (_scene == 5);
    _caption ctrlSetStructuredText parseText format ["<t align='center'>%1</t>", _text];
    private _captionHeight = (ctrlTextHeight _caption + safeZoneH * 0.008) max (safeZoneH * 0.078);
    _caption ctrlSetPositionY (safeZoneY + safeZoneH * 0.983 - _captionHeight);
    _caption ctrlSetPositionH _captionHeight;
    _caption ctrlCommit 0;
    _caption ctrlSetFade 1;
    _caption ctrlCommit 0;
    _caption ctrlSetFade 0;
    _caption ctrlCommit 0.25;
    _logo ctrlShow (_scene == 1);
    _logoBackground ctrlShow (_scene == 1);
    _map ctrlShow (_scene != 5);
    ctrlMapAnimClear _map;

    switch (_scene) do {
        case 1: {
            [0, 0.65, (_molos vectorAdd _skopos) vectorMultiply 0.5] call _animateMap;
            _logo ctrlSetFade 0;
            _logo ctrlSetPosition [safeZoneX + safeZoneW * 0.36, safeZoneY + safeZoneH * 0.32, safeZoneW * 0.28, safeZoneH * 0.22];
            _logo ctrlCommit 0;
            _logo ctrlSetPosition [safeZoneX + safeZoneW * 0.12, safeZoneY + safeZoneH * 0.12, safeZoneW * 0.76, safeZoneH * 0.62];
            _logo ctrlCommit (1.65 * _timeScale);
        };
        case 2: {
            private _overview = (_molos vectorAdd _skopos) vectorMultiply 0.5;
            // Restart the visible sequence at its own overview after preloading.
            [0, 0.65, _overview] call _animateMap;
            [0.7, 0.12, _molos] call _animateMap;
            [1.1, 0.12, _molos] call _animateMap;
            [0.65, 0.65, _overview] call _animateMap;
            [1.2, 0.12, _skopos] call _animateMap;
            [1.35, 0.12, _skopos] call _animateMap;
        };
        case 3: {
            [0.65, _captureZoom, _captureCenter] call _animateMap;
        };
        case 4: {
            [0.45, 0.045, _green] call _animateMap;
            [1, 0.045, _green] call _animateMap;
            [0.65, 0.045, _red] call _animateMap;
            [0.9, 0.045, _red] call _animateMap;
        };
        case 5: {
            [_display, "purchase"] call INTRO_fnc_menuScene;
        };
        case 6: {
            [0.45, 0.06, _green vectorAdd [250, -100, 0]] call _animateMap;
            [_display, "travel"] call INTRO_fnc_menuScene;
        };
        case 7: {
            [0.5, _captureZoom, _captureCenter] call _animateMap;
        };
        case 8: {
            private _positions = [_airbase] + (_links apply { (_sectorData get _x) get "position" });
            private _minX = 1e10;
            private _maxX = -1e10;
            private _minY = 1e10;
            private _maxY = -1e10;
            {
                _minX = _minX min (_x # 0);
                _maxX = _maxX max (_x # 0);
                _minY = _minY min (_x # 1);
                _maxY = _maxY max (_x # 1);
            } forEach _positions;
            private _span = ((_maxX - _minX) max (_maxY - _minY)) + 1200;
            private _center = [(_minX + _maxX) * 0.5, (_minY + _maxY) * 0.5 - 250, 0];
            [0, (_span / worldSize) max 0.07, _center] call _animateMap;
        };
        case 9: {
            private _positions = (_display getVariable "INTRO_incomeData") get "positions";
            private _minX = 1e10;
            private _maxX = -1e10;
            private _minY = 1e10;
            private _maxY = -1e10;
            {
                _minX = _minX min (_x # 0);
                _maxX = _maxX max (_x # 0);
                _minY = _minY min (_x # 1);
                _maxY = _maxY max (_x # 1);
            } forEach _positions;
            private _span = ((_maxX - _minX) max (_maxY - _minY)) + 1500;
            private _center = [(_minX + _maxX) * 0.5, (_minY + _maxY) * 0.5 - 250, 0];
            [0.6, (_span / worldSize) max 0.07, _center] call _animateMap;
        };
        case 10: {
            private _data = _display getVariable "INTRO_incomeData";
            private _positions = _data get "positions10";
            private _departures = _data get "departures10";
            private _arrivals = _data get "arrivals10";
            [0, 0.045, _positions # 0] call _animateMap;
            {
                private _arrived = _arrivals # _forEachIndex;
                private _nextDeparture = if (_forEachIndex < (count _positions - 1)) then {
                    _departures # (_forEachIndex + 1)
                } else {
                    _animationDuration
                };
                if (_forEachIndex > 0) then {
                    [_arrived - (_departures # _forEachIndex), 0.045, _x] call _animateMap;
                };
                private _holdFrom = if (_forEachIndex == 0) then { 0 } else { _arrived };
                [_nextDeparture - _holdFrom, 0.045, _x] call _animateMap;
            } forEach _positions;
        };
        case 11: {
            private _side = missionNamespace getVariable ["BIS_WL_playerSide", side group player];
            private _baseVariable = switch (_side) do {
                case west: { "WL2_base1" };
                case east: { "WL2_base2" };
                default { "" };
            };
            private _home = if (_baseVariable == "") then { objNull } else {
                missionNamespace getVariable [_baseVariable, objNull]
            };
            if (isNull _home && _side == independent) then {
                private _owned = (missionNamespace getVariable ["BIS_WL_allSectors", []]) select {
                    _x getVariable ["BIS_WL_owner", sideUnknown] == _side
                };
                if (count _owned > 0) then { _home = _owned # 0; };
            };
            private _homePosition = if (!isNull _home) then { getPosASL _home } else {
                (_sectorData get (if (_side == east) then { "SkoposCastleRuins" } else { "Molos" })) get "position"
            };
            private _fallback = _sectorData get (if (_side == east) then { "SkoposCastleRuins" } else { "Molos" });
            private _homeSectorData = createHashMapFromArray [
                ["position", _homePosition],
                ["area", _fallback get "area"]
            ];
            private _homeArea = if (isNull _home) then { [] } else { _home getVariable ["objectAreaComplete", []] };
            if (count _homeArea >= 5) then {
                _homePosition = _homeArea # 0;
                _homeSectorData set ["position", _homePosition];
                _homeSectorData set ["area", [abs (_homeArea # 1), abs (_homeArea # 2), _homeArea # 3, _homeArea # 4]];
            };
            private _homeColor = switch (_side) do {
                case east: { [1, 0.24, 0.22, 1] };
                case independent: { [0.2, 0.85, 0.42, 1] };
                default { [0.15, 0.56, 1, 1] };
            };
            private _flag = switch (_side) do {
                case east: { "\A3\ui_f\data\map\markers\flags\csat_ca.paa" };
                case independent: { "\A3\ui_f\data\map\markers\flags\Altis_ca.paa" };
                default { "\A3\ui_f\data\map\markers\flags\nato_ca.paa" };
            };
            _display setVariable ["INTRO_homePosition", _homePosition];
            _display setVariable ["INTRO_homeFlag", _flag];
            _display setVariable ["INTRO_homeSectorData", _homeSectorData];
            _display setVariable ["INTRO_homeColor", _homeColor];
            _display setVariable ["INTRO_endingStep", 0];
            _display setVariable ["INTRO_endingFlashAt", _narration get "endingFlashAt"];
            [0.7, 0.16, _homePosition] call _animateMap;
            [1.1, 0.001, _homePosition] call _animateMap;
        };
    };
    if (isNull _display || { _display getVariable ["INTRO_closed", false] }) exitWith {};
    ctrlMapAnimCommit _map;
    if !([_started + _duration] call _wait) exitWith {};
    if (_scene == count _scenes) then { _completed = true; };
} forEach _scenes;

if (!isNull _display) then { _display closeDisplay 1; };
{
    if (_x >= 0) then { stopSound _x; };
} forEach [_narrationId, _soundtrackId];
[_display, "hide"] call INTRO_fnc_menuScene;

if (_completed && { !isNull (findDisplay 46) }) then {
    0 spawn WL2_fnc_welcome;
};
