#include "includes.inc"
private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\settings.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_control", "_isConfirmDialog", "_message"];
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    private _params = fromJSON _message;
    _params params ["_controlType", "_id", "_value"];

    if (_controlType == "slider") then {
        private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
        _settingsMap set [_id, _value];
        [] call MENU_fnc_updateViewDistance;
    };
    if (_controlType == "checkbox") then {
        private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
        _settingsMap set [_id, _value];
        profileNamespace setVariable ["WL2_settings", _settingsMap];
    };

    if (_controlType == "button") then {
        closeDialog 0;
        switch (_id) do {
            case "SQUADS": {
                [true] spawn SQD_fnc_menu;
            };
            case "VEHICLES": {
                0 spawn WL2_fnc_vehicleManager;
            };
            case "BADGES": {
                0 spawn RWD_fnc_badgeMenu;
            };
            case "REPORT": {
                [false] spawn MENU_fnc_moderatorMenu;
            };
            case "POLL": {
                0 spawn POLL_fnc_pollMenu;
            };
            case "PERF": {
                0 spawn PERF_fnc_perfMenuInit;
            };
            case "RESET ALL": {
                0 spawn MENU_fnc_resetDefault;
            };
            case "DEBUG": {
                [""] spawn MENU_fnc_debugMenu;
            };
            case "SPECTATE": {
                0 spawn SPEC_fnc_spectator;
            };
            case "MODERATE": {
                [true] spawn MENU_fnc_moderatorMenu;
            };
            default {};
        };
    };

    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    private _settingsMenu = [
        ["button", "SQUADS", "a3\3den\data\displays\display3den\panelright\modegroups_ca.paa"],
        ["button", "VEHICLES", "a3\soft_f_beta\mrap_03\data\ui\mrap_03_hmg_ca.paa"],
        ["button", "BADGES", "a3\ui_f\data\gui\rsc\rscdisplayarsenal\insignia_ca.paa"],
        ["button", "REPORT", "A3\ui_f\data\map\markers\handdrawn\warning_CA.paa"],
        ["button", "POLL", "A3\ui_f\data\map\markers\handdrawn\unknown_CA.paa"],
        ["button", "PERF", "a3\ui_f\data\gui\rsccommon\rscdebugconsole\performance_ca.paa"],
        ["button", "RESET ALL", "a3\modules_f_curator\data\portraitrespawntickets_ca.paa"]
    ];

    private _playerUid = getPlayerUID player;
    private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
    private _isSpectator = _playerUid in getArray (missionConfigFile >> "spectatorIDs");
    private _isModerator = _playerUid in getArray (missionConfigFile >> "moderatorIDs");
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
        ["slider", "Map icon refresh rate", [1, 100, 1, 4, "mapRefresh"]],
        ["slider", "Terrain details", [1, 4, 1, 3, "terrainDetails"]],
        ["category", "Volume settings"],
        ["slider", "Announcer", [0, 1, 0.1, 1, "announcerVolume"]],
        ["slider", "APS warning", [0, 1, 0.1, 1, "apsVolume"]],
        ["slider", "Earplugs", [0, 0.5, 0.05, 0.1, "earplugVolume"]],
        ["slider", "Hitmarker", [0, 1, 0.1, 0.5, "hitmarkerVolume"]],
        ["slider", "Level up music", [0, 1, 0.1, 0.8, "levelUpMusic"]],
        ["slider", "Vote countdown", [0, 1, 0.1, 1, "voteVolume"]],
        ["slider", "Drone jamming", [0, 5, 0.1, 1, "droneJammingVolume"]],
        ["slider", "Drone ping", [0, 1, 0.1, 1, "dronePingVolume"]],
        ["slider", "Cockpit: Pull up", [0, 1, 0.1, 0.3, "rwr1"]],
        ["slider", "Cockpit: Altitude", [0, 1, 0.1, 0.3, "rwr2"]],
        ["slider", "Cockpit: Fuel", [0, 1, 0.1, 0.3, "rwr3"]],
        ["slider", "Cockpit: Targeting", [0, 1, 0.1, 1, "rwr4"]],
        ["slider", "Cockpit: Threats", [0, 1, 0.1, 1, "rwr5"]],
        ["slider", "Killfeed: Notification", [0, 1, 0.1, 1, "killfeedNotification"]],
        ["slider", "Killfeed: Celebration", [0, 1, 0.1, 1, "killfeedCelebration"]],
        ["category", "Adjustable settings"],
        ["slider", "Parachute auto deploy height", [0, 500, 5, 100, "parachuteAutoDeployHeight"]],
        ["slider", "Announcer text size", [0.1, 1, 0.1, 0.5, "announcerTextSize"]],
        ["slider", "Map marker scale threshold", [0, 1, 0.05, 0.4, "sectorMarkerTextThreshold"]],
        ["slider", "Map icon scale", [0.5, 2, 0.05, 1.0, "mapIconScale"]],
        ["slider", "Loadout theme", [1, 5, 1, 1, "loadoutTheme"]],
        ["slider", "Killfeed scale", [0.5, 1.2, 0.05, 1.0, "killfeedScale"]],
        ["slider", "Killfeed badge scale", [0.2, 1.5, 0.05, 1.0, "killfeedBadgeScale"]],
        ["slider", "Killfeed timeout (s)", [3, 20, 0.5, 10, "killfeedTimeout"]],
        ["slider", "Killfeed min gap (ms)", [0, 1000, 50, 250, "killfeedMinGap"]],
        ["slider", "Killfeed badge show time (s)", [1, 10, 0.5, 5, "ribbonMinShowTime"]],
        ["slider", "Killfeed position (left %)", [0, 100, 1, 50, "killfeedLeft"]],
        ["slider", "Killfeed position (top %)", [0, 100, 1, 95, "killfeedTop"]],
        ["slider", "Targeting menu position (left %)", [0, 100, 1, 65, "targetingMenuLeft"]],
        ["slider", "Targeting menu position (top %)", [0, 100, 1, 30, "targetingMenuTop"]],
        ["slider", "Targeting menu font size", [10, 30, 1, 18, "targetingMenuFontSize"]],
        ["slider", "Incoming indicator position (left %)", [0, 100, 1, 5, "incomingIndicatorLeft"]],
        ["slider", "Incoming indicator position (top %)", [0, 100, 1, 20, "incomingIndicatorTop"]],
        ["category", "General settings"],
        ["checkbox", "Disable 3rd person view (2x reward)", ["3rdPersonDisabled", false]],
        ["checkbox", "Autonomous mode off by default", ["enableAuto", false]],
        ["checkbox", "Spawn vehicles with empty inventory", ["spawnEmpty", false]],
        ["checkbox", "Disable missile cameras", ["disableMissileCameras", false]],
        ["checkbox", "Show user-defined markers", ["showMarkers", true]],
        ["checkbox", "No voice speaker", ["noVoiceSpeaker", false]],
        ["checkbox", "Disable incoming missile indicator", ["disableIncomingMissileDisplay", false]],
        ["checkbox", "Delete quad bike/water scooter on exit", ["deleteSmallTransports", true]],
        ["checkbox", "Use new kill sound", ["useNewKillSound", true]],
        ["checkbox", "Use new killfeed", ["useNewKillfeed", true]],
        ["category", "Hide scroll menus (requires respawn)"],
        ["checkbox", "Hide: Squad menu", ["hideSquadMenu", false]],
        ["checkbox", "Hide: Buy menu", ["hideBuyMenu", false]],
        ["checkbox", "Hide: Vehicle manager", ["hideVehicleManager", false]],
        ["checkbox", "Hide: Help menu", ["hideHelpMenu", false]],
        ["category", "Control hints"],
        ["checkbox", "Show hint: Deployment", ["showHintDeploy", true]],
        ["checkbox", "Show hint: Recon Optics", ["showHintRecon", true]],
        ["checkbox", "Show hint: GPS Munitions", ["showHintGPS", true]],
        ["checkbox", "Show hint: SEAD Munitions", ["showHintSEAD", true]],
        ["checkbox", "Show hint: TV Munitions", ["showHintTV", true]],
        ["checkbox", "Show hint: Remote Munitions", ["showHintRemote", true]],
        ["checkbox", "Show hint: Advanced SAMs", ["showHintAdvancedSam", true]],
        ["checkbox", "Show hint: LOAL", ["showHintLoal", true]],
        ["checkbox", "Show hint: Blackfish", ["showHintBlackfish", true]]
    ];

    if (_isAdmin || _isModerator) then {
        _settingsMenu append [
            ["category", "Moderator Options"],
            ["checkbox", "Show player uids (requires respawn)", ["showPlayerUids", false]],
            ["checkbox", "Show mod status (requires respawn)", ["showModStatus", true]]
        ];
    };

    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
    {
        _x params ["_category", "_text", "_params"];
        if (_category == "category") then {
            continue;
        };
        if (_category == "slider") then {
            private _currentPosition = _settingsMap getOrDefault [_params # 4, _params # 3];
            _params set [3, _currentPosition];
        };
        if (_category == "checkbox") then {
            private _currentSetting = _settingsMap getOrDefault [_params # 0, _params # 1];
            _params set [1, _currentSetting];
        };
    } forEach _settingsMenu;

    private _settingsMenuText = toJSON _settingsMenu;
    _settingsMenuText = _texture ctrlWebBrowserAction ["ToBase64", _settingsMenuText];

    private _script = format [
        "createMenu(atob(""%1""));",
        _settingsMenuText
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
}];