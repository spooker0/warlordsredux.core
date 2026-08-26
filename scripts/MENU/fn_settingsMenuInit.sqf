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
    ["button", localize "STR_WL_spawn", "a3\3den\data\displays\display3den\panelright\modegroups_ca.paa", "spawn"],
    ["button", localize "STR_WL_badges", "a3\ui_f\data\gui\rsc\rscdisplayarsenal\insignia_ca.paa", "badges"],
    ["button", localize "STR_WL_report", "A3\ui_f\data\map\markers\handdrawn\warning_CA.paa", "report"],
    ["button", localize "STR_WL_poll", "A3\ui_f\data\map\markers\handdrawn\unknown_CA.paa", "poll"],
    ["button", localize "STR_WL_perf", "a3\ui_f\data\gui\rsccommon\rscdebugconsole\performance_ca.paa", "performance"],
    ["button", localize "STR_WL_resetAll", "a3\modules_f_curator\data\portraitrespawntickets_ca.paa", "resetAll"]
];

private _playerUid = getPlayerUID player;
private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
private _isModerator = _playerUid in getArray (missionConfigFile >> "moderatorIDs");
private _isSpectator = _playerUid in getArray (missionConfigFile >> "spectatorIDs");
private _isTempSpectator = _playerUid == missionNamespace getVariable ["WL2_tempSpectatorUID", ""];
_isSpectator = _isSpectator || _isTempSpectator;

if (_isAdmin) then {
    _settingsMenu pushBack ["button", "DEBUG", "a3\ui_f\data\igui\cfg\simpletasks\types\box_ca.paa", "debug"];
};

if (_isAdmin || _isSpectator) then {
    _settingsMenu pushBack ["button", "SPECTATE", "a3\3den\data\cfgwaypoints\seekanddestroy_ca.paa", "spectate"];
};

if (_isAdmin || _isModerator) then {
    _settingsMenu pushBack ["button", "MODERATE", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa", "moderate"];
};

_settingsMenu append [
    ["category", localize "STR_WL_viewDistance"],
    ["slider", localize "STR_WL_infantry", [200, 4000, 50, 2000, "infantryViewDistance"]],
    ["slider", localize "STR_WL_groundVehicle", [200, 4000, 50, 4000, "groundViewDistance"]],
    ["slider", localize "STR_WL_airVehicle", [200, 4000, 50, 4000, "airViewDistance"]],
    ["slider", localize "STR_WL_drone", [200, 4000, 50, 4000, "droneViewDistance"]],
    ["slider", localize "STR_WL_objectDistance", [200, 4000, 50, 4000, "objectViewDistance"]],
    ["slider", localize "STR_WL_cqbModeDeleteKey", [200, 2000, 50, 200, "cqbViewDistance"]],

    ["category", localize "STR_WL_performance"],
    ["slider", localize "STR_WL_mapIconRefreshRate", [1, 100, 1, 4, "mapRefresh"]],
    ["slider", localize "STR_WL_terrainDetails", [1, 4, 1, 3, "terrainDetails"]],
    ["slider", localize "STR_WL_incendiaryStrands", [5, 20, 1, 20, "incendiaryStrands"]],

    ["category", localize "STR_WL_volumeSettings"],
    ["slider", localize "STR_WL_announcer", [0, 1, 0.1, 1, "announcerVolume"]],
    ["slider", localize "STR_WL_apsWarning", [0, 1, 0.1, 1, "apsVolume"]],
    ["slider", localize "STR_WL_earplugs", [0, 0.5, 0.05, 0.1, "earplugVolume"]],
    ["slider", localize "STR_WL_hitmarker", [0, 1, 0.1, 0.5, "hitmarkerVolume"]],
    ["slider", localize "STR_WL_levelUpMusic", [0, 1, 0.1, 0.8, "levelUpMusic"]],
    ["slider", localize "STR_WL_spawnNearbyBirds", [0.1, 1, 0.1, 1, "spawnNearbyVolume"]],
    ["slider", localize "STR_WL_squadChatNotification", [0, 5, 0.1, 1, "squadChatNotificationVolume"]],
    ["slider", localize "STR_WL_squadImportantNotification", [1, 5, 0.1, 3, "squadImportantNotificationVolume"]],
    ["slider", localize "STR_WL_nearbyCommNotification", [1, 5, 0.1, 5, "nearbyNotificationVolume"]],
    ["slider", localize "STR_WL_voteCountdown", [0, 1, 0.1, 1, "voteVolume"]],
    ["slider", localize "STR_WL_dronePing", [0, 1, 0.1, 1, "dronePingVolume"]],
    ["slider", localize "STR_WL_cockpitPullUp", [0, 1, 0.1, 0.3, "rwr1"]],
    ["slider", localize "STR_WL_cockpitAltitude", [0, 1, 0.1, 0.3, "rwr2"]],
    ["slider", localize "STR_WL_cockpitFuel", [0, 1, 0.1, 0.3, "rwr3"]],
    ["slider", localize "STR_WL_cockpitTargeting", [0, 1, 0.1, 1, "rwr4"]],
    ["slider", localize "STR_WL_cockpitThreats", [0, 1, 0.1, 1, "rwr5"]],
    ["slider", localize "STR_WL_targetLock", [0, 1, 0.1, 1, "loalLockVolume"]],
    ["slider", localize "STR_WL_mineWarningVolume", [0, 5, 0.1, 1.5, "mineWarnVolume"]],
    ["slider", localize "STR_WL_killfeedNotification", [0, 1, 0.1, 1, "killfeedNotification"]],
    ["slider", localize "STR_WL_killfeedCelebration", [0, 1, 0.1, 1, "killfeedCelebration"]],
    ["slider", localize "STR_WL_eventMusic", [0, 1, 0.1, 1, "eventMusicVolume"]],

    ["category", localize "STR_WL_adjustableSettings"],
    ["slider", localize "STR_WL_mineWarningTime", [0, 10, 1, 4, "mineWarnTime"]],
    ["slider", localize "STR_WL_strongholdIconSize", [0, 1, 0.1, 1, "strongholdIconSize"]],
    ["slider", localize "STR_WL_parachuteAutoDeployHeight", [0, 500, 5, 50, "parachuteAutoDeployHeight"]],
    ["slider", localize "STR_WL_mapMarkerScaleThreshold", [0, 1, 0.05, 0.4, "sectorMarkerTextThreshold"]],
    ["slider", localize "STR_WL_mapIconScale", [0.5, 2, 0.05, 1.0, "mapIconScale"]],
    ["slider", localize "STR_WL_mapIconTextScale", [0.5, 2, 0.05, 1.0, "mapIconTextScale"]],
    ["slider", localize "STR_WL_missileCameraPositionLeft", [0, 100, 1, 0, "missileCameraLeft"]],
    ["slider", localize "STR_WL_missileCameraPositionTop", [0, 100, 1, 100, "missileCameraTop"]],
    ["slider", localize "STR_WL_killfeedTotalTimeout", [0, 20, 0.5, 3, "killfeedTotalTimeout"]],
    ["slider", localize "STR_WL_killfeedTimeout", [3, 20, 0.5, 10, "killfeedTimeout"]],
    ["slider", localize "STR_WL_killfeedBadgeShowTime", [1, 10, 0.5, 5, "ribbonMinShowTime"]],
    ["slider", localize "STR_WL_killfeedPositionLeft", [0, 100, 1, 50, "killfeedLeft"]],
    ["slider", localize "STR_WL_killfeedPositionTop", [0, 100, 1, 95, "killfeedTop"]],
    ["slider", localize "STR_WL_targetingMenuPositionLeft", [0, 100, 1, 65, "targetingMenuLeft"]],
    ["slider", localize "STR_WL_targetingMenuPositionTop", [0, 100, 1, 30, "targetingMenuTop"]],
    ["slider", localize "STR_WL_targetingMenuFontSize", [10, 30, 1, 18, "targetingMenuFontSize"]],
    ["slider", localize "STR_WL_captureInterfaceFontSize", [8, 20, 1, 10, "captureInterfaceFontSize"]],
    ["slider", localize "STR_WL_incomingIndicatorPositionLeft", [0, 100, 1, 5, "incomingIndicatorLeft"]],
    ["slider", localize "STR_WL_incomingIndicatorPositionTop", [0, 100, 1, 20, "incomingIndicatorTop"]],
    ["slider", "Capture indicator (top %)", [0, 100, 1, 18, "captureIndicatorTop"]],
    ["slider", localize "STR_WL_mapButtonScale", [0.75, 1.5, 0.05, 1, "mapButtonScale"]],
    ["slider", localize "STR_WL_mapSectorLineGrayscale", [0, 1, 0.05, 1, "mapSectorLineGrayscale"]],
    ["slider", localize "STR_WL_mapSectorLineRevealTime", [0, 1, 0.05, 0.25, "mapSectorLineSpeed"]],
    ["slider", localize "STR_WL_mapSectorModifierSize", [0, 2, 0.05, 1, "mapSectorModifierSize"]],

    ["category", localize "STR_WL_generalSettings"],
    ["checkbox", localize "STR_WL_disableThirdPersonView", ["3rdPersonDisabled", false]],
    ["checkbox", localize "STR_WL_autonomousModeOffByDefault", ["enableAuto", false]],
    ["checkbox", localize "STR_WL_disableMissileCameras", ["disableMissileCameras", false]],
    ["checkbox", localize "STR_WL_noVoiceSpeaker", ["noVoiceSpeaker", false]],
    ["checkbox", localize "STR_WL_disableIncomingMissileIndicator", ["disableIncomingMissileDisplay", false]],
    ["checkbox", localize "STR_WL_deleteSmallTransportsOnExit", ["deleteSmallTransports", true]],
    ["checkbox", localize "STR_WL_addKillfeedToChat", ["addKillfeedToChat", false]],
    ["checkbox", localize "STR_WL_useNewKillSound", ["useNewKillSound", true]],
    ["checkbox", localize "STR_WL_enableAlliedDemolition", ["enableAlliedDemolition", false]],
    ["checkbox", localize "STR_WL_showWelcomeMenu", ["showWelcomeMenu", true]],
    ["checkbox", localize "STR_WL_spawnWithUavTerminal", ["spawnWithUAVTerminal", true]],
    ["checkbox", localize "STR_WL_spawnWithRangefinder", ["spawnWithRangefinder", true]],
    ["checkbox", localize "STR_WL_aiFollowDefault", ["aiFollowDefault", true]],
    ["checkbox", localize "STR_WL_aiVehicleTp", ["aiVehicleTp", true]],
    ["checkbox", localize "STR_WL_defaultVtolAutoModeOff", ["defaultOffVtolAuto", false]],
    ["checkbox", localize "STR_WL_camperWarningProtection", ["camperWarning", true]],
    ["checkbox", localize "STR_WL_showStrongholdInstructions", ["showStrongholdInfo", true]],
    ["checkbox", localize "STR_WL_showPlayerLevelInsteadOfElo", ["showPlayerLevel", false]],
    ["checkbox", localize "STR_WL_hideNonMandatoryConscriptionNotices", ["hideConscriptionNotices", true]],
    ["checkbox", localize "STR_WL_railgunSecondClickToFire", ["railgunSecondClick", true]],
    ["checkbox", localize "STR_WL_additionalSubtitles", ["additionalSubs", false]],
    ["checkbox", localize "STR_WL_mapAlwaysShowDetailedText", ["alwaysShowDetailedText", false]],

    ["category", localize "STR_WL_hideScrollMenus"],
    ["checkbox", localize "STR_WL_hideBuyMenu", ["hideBuyMenu", false]],
    ["checkbox", localize "STR_WL_hideFrontlineAction", ["hideFrontlineMenu", false]],

    ["category", localize "STR_WL_controlHints"],
    ["checkbox", localize "STR_WL_showHintDeployment", ["showHintDeploy", true]],
    ["checkbox", localize "STR_WL_showHintReconOptics", ["showHintRecon", true]],
    ["checkbox", localize "STR_WL_showHintGpsMunitions", ["showHintGPS", true]],
    ["checkbox", localize "STR_WL_showHintSeadMunitions", ["showHintSEAD", true]],
    ["checkbox", localize "STR_WL_showHintTvMunitions", ["showHintTV", true]],
    ["checkbox", localize "STR_WL_showHintRemoteMunitions", ["showHintRemote", true]],
    ["checkbox", localize "STR_WL_showHintAdvancedSams", ["showHintAdvancedSam", true]],
    ["checkbox", localize "STR_WL_showHintLaser", ["showHintLaser", true]],
    ["checkbox", localize "STR_WL_showHintLoal", ["showHintLoal", true]],
    ["checkbox", localize "STR_WL_showHintBlackfish", ["showHintBlackfish", true]],
    ["checkbox", localize "STR_WL_showHintHmdSettings", ["showHintHMDSettings", true]],
    ["checkbox", localize "STR_WL_showHintAnimation", ["showHintAnimation", true]],
    ["checkbox", localize "STR_WL_showHintParadrop", ["showHintParadrop", true]],
    ["checkbox", localize "STR_WL_showHintMapLayers", ["showHintMap", true]]
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
    _x params ["", "_actionText", "_icon", "_actionId"];

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
    _buttonControl ctrlSetText _actionText;
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
                _labelText = format ["<t color='#cc6666'>%1* [%2: %3]</t>", _labelText, localize "STR_WL_default", _default];
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