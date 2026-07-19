#include "includes.inc"
params [["_searchQuery", ""]];

private _existingDisplay = findDisplay SETTINGS_IDD;
if (!isNull _existingDisplay) exitWith {};

private _display = createDialog ["WL2_SettingsMenu", true];
if (isNull _display) exitWith {};

uiNamespace setVariable ["WL2_SettingsMenu", _display];

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
missionProfileNamespace setVariable ["WL2_settings", _settingsMap];

_display setVariable ["WL2_settingsMap", _settingsMap];
_display setVariable ["WL2_settingsDirty", false];

private _dynamicBlurHandle = ppEffectCreate ["DynamicBlur", 600];
_dynamicBlurHandle ppEffectEnable true;
_dynamicBlurHandle ppEffectAdjust [3];
_dynamicBlurHandle ppEffectCommit 0;

_display setVariable ["WL2_dynamicBlurHandle", _dynamicBlurHandle];

_display displayAddEventHandler ["Unload", {
    params ["_display"];
    if (_display getVariable ["WL2_settingsDirty", false]) then {
        saveMissionProfileNamespace;
    };
}];

private _closeControl = _display displayCtrl SETTINGS_CLOSE_ID;
_closeControl ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    private _display = ctrlParent _control;
    _display closeDisplay 2;
}];

private _settingsMenu = [
    ["button", "SPAWN", "a3\3den\data\displays\display3den\panelright\modegroups_ca.paa"],
    ["button", "BADGES", "a3\ui_f\data\gui\rsc\rscdisplayarsenal\insignia_ca.paa"],
    ["button", "REPORT", "A3\ui_f\data\map\markers\handdrawn\warning_CA.paa"],
    ["button", "POLL", "A3\ui_f\data\map\markers\handdrawn\unknown_CA.paa"],
    ["button", "PERF", "a3\ui_f\data\gui\rsccommon\rscdebugconsole\performance_ca.paa"],
    ["button", "RESET ALL", "a3\modules_f_curator\data\portraitrespawntickets_ca.paa"]
];

private _playerUid = getPlayerUID player;
private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
private _isModerator = _playerUid in getArray (missionConfigFile >> "moderatorIDs");
private _isSpectator = _playerUid in getArray (missionConfigFile >> "spectatorIDs");
private _isTempSpectator = _playerUid == missionNamespace getVariable ["WL2_tempSpectatorUID", ""];
_isSpectator = _isSpectator || _isTempSpectator;

if (_isAdmin) then {
    _settingsMenu pushBack ["button", "DEBUG", "a3\ui_f\data\igui\cfg\simpletasks\types\box_ca.paa"];
};

if (_isAdmin || _isSpectator) then {
    _settingsMenu pushBack ["button", "SPECTATE", "a3\3den\data\cfgwaypoints\seekanddestroy_ca.paa"];
};

if (_isAdmin || _isModerator) then {
    _settingsMenu pushBack ["button", "MODERATE", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"];
};

_settingsMenu append [
    ["category", "View distance"],
    ["slider", "Infantry", [200, 4000, 50, 2000, "infantryViewDistance"]],
    ["slider", "Ground vehicle", [200, 4000, 50, 4000, "groundViewDistance"]],
    ["slider", "Air vehicle", [200, 4000, 50, 4000, "airViewDistance"]],
    ["slider", "Drone", [200, 4000, 50, 4000, "droneViewDistance"]],
    ["slider", "Object distance", [200, 4000, 50, 4000, "objectViewDistance"]],
    ["slider", "CQB mode (DELETE key)", [200, 2000, 50, 200, "cqbViewDistance"]],

    ["category", "Performance"],
    ["slider", "Map icon refresh rate", [1, 100, 1, 10, "mapRefresh"]],
    ["slider", "Terrain details", [1, 4, 1, 3, "terrainDetails"]],
    ["slider", "Incendiary strands", [5, 20, 1, 20, "incendiaryStrands"]],

    ["category", "Volume settings"],
    ["slider", "Announcer", [0, 1, 0.1, 1, "announcerVolume"]],
    ["slider", "APS warning", [0, 1, 0.1, 1, "apsVolume"]],
    ["slider", "Earplugs", [0, 0.5, 0.05, 0.1, "earplugVolume"]],
    ["slider", "Hitmarker", [0, 1, 0.1, 0.5, "hitmarkerVolume"]],
    ["slider", "Level up music", [0, 1, 0.1, 0.8, "levelUpMusic"]],
    ["slider", "Spawn nearby (birds)", [0.1, 1, 0.1, 1, "spawnNearbyVolume"]],
    ["slider", "Squad chat notification", [0, 5, 0.1, 1, "squadChatNotificationVolume"]],
    ["slider", "Squad important notification", [1, 5, 0.1, 3, "squadImportantNotificationVolume"]],
    ["slider", "Nearby comm notification", [1, 5, 0.1, 5, "nearbyNotificationVolume"]],
    ["slider", "Vote countdown", [0, 1, 0.1, 1, "voteVolume"]],
    ["slider", "Drone ping", [0, 1, 0.1, 1, "dronePingVolume"]],
    ["slider", "Cockpit: Pull up", [0, 1, 0.1, 0.3, "rwr1"]],
    ["slider", "Cockpit: Altitude", [0, 1, 0.1, 0.3, "rwr2"]],
    ["slider", "Cockpit: Fuel", [0, 1, 0.1, 0.3, "rwr3"]],
    ["slider", "Cockpit: Targeting", [0, 1, 0.1, 1, "rwr4"]],
    ["slider", "Cockpit: Threats", [0, 1, 0.1, 1, "rwr5"]],
    ["slider", "Target lock", [0, 1, 0.1, 1, "loalLockVolume"]],
    ["slider", "Mine warning volume", [0, 5, 0.1, 1.5, "mineWarnVolume"]],
    ["slider", "Killfeed: Notification", [0, 1, 0.1, 1, "killfeedNotification"]],
    ["slider", "Killfeed: Celebration", [0, 1, 0.1, 1, "killfeedCelebration"]],
    ["slider", "Event music", [0, 1, 0.1, 1, "eventMusicVolume"]],

    ["category", "Adjustable settings"],
    ["slider", "Mine warning time", [0, 10, 1, 4, "mineWarnTime"]],
    ["slider", "Stronghold icon size", [0, 1, 0.1, 1, "strongholdIconSize"]],
    ["slider", "Parachute auto deploy height", [0, 500, 5, 50, "parachuteAutoDeployHeight"]],
    ["slider", "Map marker scale threshold", [0, 1, 0.05, 0.4, "sectorMarkerTextThreshold"]],
    ["slider", "Map icon scale", [0.5, 2, 0.05, 1.0, "mapIconScale"]],
    ["slider", "Map icon text scale", [0.5, 2, 0.05, 1.0, "mapIconTextScale"]],
    ["slider", "Missile camera position (left %)", [0, 100, 1, 0, "missileCameraLeft"]],
    ["slider", "Missile camera position (top %)", [0, 100, 1, 100, "missileCameraTop"]],
    ["slider", "Killfeed total timeout (s)", [0, 20, 0.5, 3, "killfeedTotalTimeout"]],
    ["slider", "Killfeed timeout (s)", [3, 20, 0.5, 10, "killfeedTimeout"]],
    ["slider", "Killfeed badge show time (s)", [1, 10, 0.5, 5, "ribbonMinShowTime"]],
    ["slider", "Killfeed position (left %)", [0, 100, 1, 50, "killfeedLeft"]],
    ["slider", "Killfeed position (top %)", [0, 100, 1, 95, "killfeedTop"]],
    ["slider", "Targeting menu position (left %)", [0, 100, 1, 65, "targetingMenuLeft"]],
    ["slider", "Targeting menu position (top %)", [0, 100, 1, 30, "targetingMenuTop"]],
    ["slider", "Targeting menu font size", [10, 30, 1, 18, "targetingMenuFontSize"]],
    ["slider", "Capture interface font size", [8, 20, 1, 10, "captureInterfaceFontSize"]],
    ["slider", "Incoming indicator position (left %)", [0, 100, 1, 5, "incomingIndicatorLeft"]],
    ["slider", "Incoming indicator position (top %)", [0, 100, 1, 20, "incomingIndicatorTop"]],
    ["slider", "Map button scale", [0.75, 1.5, 0.05, 1, "mapButtonScale"]],
    ["slider", "Map sector line color (grayscale)", [0, 1, 0.05, 1, "mapSectorLineGrayscale"]],
    ["slider", "Map sector line reveal time", [0, 1, 0.05, 0.25, "mapSectorLineSpeed"]],
    ["slider", "Map sector modifier size", [0, 2, 0.05, 1, "mapSectorModifierSize"]],

    ["category", "General settings"],
    ["checkbox", "Disable 3rd person view (2x reward)", ["3rdPersonDisabled", false]],
    ["checkbox", "Autonomous mode off by default", ["enableAuto", false]],
    ["checkbox", "Disable missile cameras", ["disableMissileCameras", false]],
    ["checkbox", "No voice speaker", ["noVoiceSpeaker", false]],
    ["checkbox", "Disable incoming missile indicator", ["disableIncomingMissileDisplay", false]],
    ["checkbox", "Delete quad bike/water scooter on exit", ["deleteSmallTransports", true]],
    ["checkbox", "Add killfeed to chat", ["addKillfeedToChat", false]],
    ["checkbox", "Use new kill sound", ["useNewKillSound", true]],
    ["checkbox", "Enable allied demolition (punishable)", ["enableAlliedDemolition", false]],
    ["checkbox", "Show welcome menu", ["showWelcomeMenu", true]],
    ["checkbox", "Spawn with UAV Terminal", ["spawnWithUAVTerminal", true]],
    ["checkbox", "Spawn with rangefinder", ["spawnWithRangefinder", true]],
    ["checkbox", "AI follow default", ["aiFollowDefault", true]],
    ["checkbox", "Default VTOL auto mode off", ["defaultOffVtolAuto", false]],
    ["checkbox", "Camper warning / protection", ["camperWarning", true]],
    ["checkbox", "Show stronghold instructions", ["showStrongholdInfo", true]],
    ["checkbox", "Show player level instead of ELO", ["showPlayerLevel", false]],
    ["checkbox", "Hide non-mandatory conscription notices", ["hideConscriptionNotices", false]],
    ["checkbox", "Railgun second click to fire", ["railgunSecondClick", true]],
    ["checkbox", "Additional subtitles (hearing impaired)", ["additionalSubs", false]],

    ["category", "Hide scroll menus (requires respawn)"],
    ["checkbox", "Hide: Buy menu", ["hideBuyMenu", false]],
    ["checkbox", "Hide: Frontline action", ["hideFrontlineMenu", false]],

    ["category", "Control hints"],
    ["checkbox", "Show hint: Deployment", ["showHintDeploy", true]],
    ["checkbox", "Show hint: Recon Optics", ["showHintRecon", true]],
    ["checkbox", "Show hint: GPS Munitions", ["showHintGPS", true]],
    ["checkbox", "Show hint: SEAD Munitions", ["showHintSEAD", true]],
    ["checkbox", "Show hint: TV Munitions", ["showHintTV", true]],
    ["checkbox", "Show hint: Remote Munitions", ["showHintRemote", true]],
    ["checkbox", "Show hint: Advanced SAMs", ["showHintAdvancedSam", true]],
    ["checkbox", "Show hint: Laser", ["showHintLaser", true]],
    ["checkbox", "Show hint: LOAL", ["showHintLoal", true]],
    ["checkbox", "Show hint: Blackfish", ["showHintBlackfish", true]],
    ["checkbox", "Show hint: HMD Settings", ["showHintHMDSettings", true]],
    ["checkbox", "Show hint: Animation", ["showHintAnimation", true]],
    ["checkbox", "Show hint: Paradrop", ["showHintParadrop", true]],
    ["checkbox", "Show hint: Map Layers", ["showHintMap", true]]
];

if (_isAdmin || _isModerator) then {
    _settingsMenu append [
        ["category", "Moderator Options"],
        ["checkbox", "Show player uids (requires respawn)", ["showPlayerUids", false]],
        ["checkbox", "Hide my identity (requires respawn)", ["hideMyIdentity", false]]
    ];
};

private _buttons = _settingsMenu select { (_x # 0) == "button" };
private _settings = _settingsMenu select { (_x # 0) != "button" };

private _buttonsGroup = _display displayCtrl SETTINGS_BUTTONS_GROUP_ID;
private _buttonRows = ceil ((count _buttons) / SETTINGS_BUTTON_COLUMNS);

private _buttonsHeight = (_buttonRows * SETTINGS_BUTTON_H) + (((_buttonRows - 1) max 0) * SETTINGS_BUTTON_GAP_Y);
_buttonsGroup ctrlSetPosition [SETTINGS_INNER_X, SETTINGS_BUTTONS_Y, SETTINGS_INNER_W, _buttonsHeight];
_buttonsGroup ctrlCommit 0;

{
    _x params ["", "_actionId", "_icon"];

    private _column = _forEachIndex % SETTINGS_BUTTON_COLUMNS;
    private _row = floor (_forEachIndex / SETTINGS_BUTTON_COLUMNS);

    private _buttonGroup = _display ctrlCreate ["WL2_SettingsMenu_Button", -1, _buttonsGroup];
    _buttonGroup ctrlSetPosition [
        _column * (SETTINGS_BUTTON_W + SETTINGS_BUTTON_GAP_X),
        _row * (SETTINGS_BUTTON_H + SETTINGS_BUTTON_GAP_Y),
        SETTINGS_BUTTON_W,
        SETTINGS_BUTTON_H
    ];
    _buttonGroup ctrlCommit 0;

    private _buttonControl = _buttonGroup controlsGroupCtrl SETTINGS_BUTTON_CONTROL_ID;
    private _iconControl = _buttonGroup controlsGroupCtrl SETTINGS_BUTTON_ICON_ID;
    _buttonControl ctrlSetText _actionId;
    _iconControl ctrlSetText _icon;

    _buttonControl setVariable ["WL2_actionId", _actionId];
    _buttonControl ctrlAddEventHandler ["ButtonClick", MENU_fnc_settingsMenuButton];
} forEach _buttons;

private _searchControl = _display displayCtrl SETTINGS_SEARCH_ID;

private _searchY = SETTINGS_BUTTONS_Y + _buttonsHeight + SETTINGS_CONTENT_GAP;
_searchControl ctrlSetPosition [SETTINGS_INNER_X, _searchY, SETTINGS_INNER_W, SETTINGS_SEARCH_H];
_searchControl ctrlCommit 0;

private _contentY = _searchY + SETTINGS_SEARCH_H + SETTINGS_SEARCH_GAP;
private _contentHeight = SETTINGS_CONTENT_BOTTOM - _contentY;
private _contentGroup = _display displayCtrl SETTINGS_CONTENT_GROUP_ID;
_contentGroup ctrlSetPosition [SETTINGS_INNER_X, _contentY, SETTINGS_INNER_W, _contentHeight];
_contentGroup ctrlCommit 0;

private _searchRows = [];
private _currentY = 0;
private _optionNumber = 1;

{
    _x params ["_type", "_text", ["_params", []]];

    switch (_type) do {
        case "category": {
            private _categoryControl = _display ctrlCreate ["WL2_SettingsMenu_Category", -1, _contentGroup];
            _categoryControl ctrlSetText _text;
            _categoryControl ctrlSetPosition [0, _currentY, SETTINGS_CONTENT_ROW_W, SETTINGS_CATEGORY_H];
            _categoryControl ctrlCommit 0;

            _searchRows pushBack [_categoryControl, "category", "", SETTINGS_CATEGORY_H, -1];

            _currentY = _currentY + SETTINGS_CATEGORY_H +SETTINGS_ROW_GAP;
        };

        case "slider": {
            _params params ["_minimum", "_maximum", "_step", "_default", "_settingId"];

            private _value = _settingsMap getOrDefault [_settingId, _default];

            private _rowControl = _display ctrlCreate ["WL2_SettingsMenu_Slider", -1, _contentGroup];
            _rowControl ctrlSetPosition [0, _currentY, SETTINGS_CONTENT_ROW_W, SETTINGS_SLIDER_H];
            _rowControl ctrlCommit 0;

            private _labelControl = _rowControl controlsGroupCtrl SETTINGS_SLIDER_LABEL_ID;
            private _sliderControl = _rowControl controlsGroupCtrl SETTINGS_SLIDER_CONTROL_ID;
            private _valueControl = _rowControl controlsGroupCtrl SETTINGS_SLIDER_VALUE_ID;

            private _labelText = format ["%1) %2", _optionNumber, _text];
            _labelControl setVariable ["WL2_labelText", _labelText];

            _sliderControl sliderSetRange [_minimum, _maximum];
            _sliderControl sliderSetSpeed [_step, _step, _step];
            _sliderControl sliderSetPosition _value;

            _valueControl ctrlSetText (str _value);

            _sliderControl setVariable ["WL2_settingId", _settingId];
            _sliderControl setVariable ["WL2_valueControl", _valueControl];
            _sliderControl setVariable ["WL2_default", _default];

            if (_value != _default) then {
                _labelText = format ["<t color='#cc6666'>%1* [Default: %2]</t>", _labelText, _default];
            };
            _labelControl ctrlSetStructuredText parseText format ["%1", _labelText];

            private _updateViewDistance = _settingId in [
                "infantryViewDistance",
                "groundViewDistance",
                "airViewDistance",
                "droneViewDistance",
                "objectViewDistance",
                "cqbViewDistance"
            ];
            _sliderControl setVariable ["WL2_updateViewDistance", _updateViewDistance];
            _sliderControl ctrlAddEventHandler ["SliderPosChanged", MENU_fnc_settingsMenuSliderChanged];

            _searchRows pushBack [_rowControl, "setting", toLower _labelText, SETTINGS_SLIDER_H, _optionNumber];

            _currentY = _currentY + SETTINGS_SLIDER_H + SETTINGS_ROW_GAP;
            _optionNumber = _optionNumber + 1;
        };

        case "checkbox": {
            _params params ["_settingId", "_default"];

            private _value = _settingsMap getOrDefault [_settingId, _default];

            private _rowControl = _display ctrlCreate ["WL2_SettingsMenu_Checkbox", -1, _contentGroup];
            _rowControl ctrlSetPosition [0, _currentY, SETTINGS_CONTENT_ROW_W, SETTINGS_CHECKBOX_H];
            _rowControl ctrlCommit 0;

            private _labelControl = _rowControl controlsGroupCtrl SETTINGS_CHECKBOX_LABEL_ID;
            private _checkboxControl = _rowControl controlsGroupCtrl SETTINGS_CHECKBOX_CONTROL_ID;

            private _labelText = format ["%1) %2", _optionNumber, _text];
            _searchRows pushBack [_rowControl, "setting", toLower _labelText, SETTINGS_CHECKBOX_H, _optionNumber];

            _labelControl setVariable ["WL2_labelText", _labelText];
            if (_value != _default) then {
                _labelText = format ["<t color='#cc6666'>%1*</t>", _labelText];
            };
            _labelControl ctrlSetStructuredText parseText format ["%1", _labelText];

            _checkboxControl cbSetChecked _value;
            _checkboxControl setVariable ["WL2_settingId", _settingId];
            _checkboxControl setVariable ["WL2_defaultValue", _default];
            _checkboxControl ctrlAddEventHandler ["CheckedChanged", MENU_fnc_settingsMenuCheckboxChanged];

            _currentY = _currentY + SETTINGS_CHECKBOX_H + SETTINGS_ROW_GAP;
            _optionNumber = _optionNumber + 1;
        };
    };
} forEach _settings;

_display setVariable ["WL2_settingsSearchRows", _searchRows];

_searchControl ctrlAddEventHandler ["KeyUp", MENU_fnc_settingsMenuSearch];
if (_searchQuery != "") then {
    _searchControl ctrlSetText _searchQuery;
    [_searchControl] call MENU_fnc_settingsMenuSearch;
};
ctrlSetFocus _searchControl;

waitUntil {
    uiSleep 0.01;
    isNull _display;
};

ppEffectDestroy _dynamicBlurHandle;