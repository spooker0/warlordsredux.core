#include "includes.inc"
private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\settings.html"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_control", "_isConfirmDialog", "_message"];
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
            case "REPORT": {
                [false] spawn MENU_fnc_moderatorMenu;
            };
            case "POLL": {
                0 spawn POLL_fnc_pollMenu;
            };
            case "PERFORMANCE": {
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

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    private _settingsMenu = [
        ["button", "SQUADS"],
        ["button", "VEHICLES"],
        ["button", "REPORT"],
        ["button", "POLL"],
        ["button", "PERFORMANCE"],
        ["button", "RESET ALL"]
    ];

    private _playerUid = getPlayerUID player;
    private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
    private _isSpectator = _playerUid in getArray (missionConfigFile >> "spectatorIDs");
    private _isModerator = _playerUid in getArray (missionConfigFile >> "moderatorIDs");
    if (_isAdmin) then {
        _settingsMenu pushBack ["button", "DEBUG"];
    };
    if (_isAdmin || _isSpectator) then {
        _settingsMenu pushBack ["button", "SPECTATE"];
    };
    if (_isAdmin || _isModerator) then {
        _settingsMenu pushBack ["button", "MODERATE"];
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
        ["slider", "Cockpit: Pull up", [0, 1, 0.1, 0.3, "rwr1"]],
        ["slider", "Cockpit: Altitude", [0, 1, 0.1, 0.3, "rwr2"]],
        ["slider", "Cockpit: Fuel", [0, 1, 0.1, 0.3, "rwr3"]],
        ["slider", "Cockpit: Targeting", [0, 1, 0.1, 1, "rwr4"]],
        ["slider", "Cockpit: Threats", [0, 1, 0.1, 1, "rwr5"]],
        ["category", "Adjustable settings"],
        ["slider", "Parachute auto deploy height", [0, 500, 5, 100, "parachuteAutoDeployHeight"]],
        ["slider", "Announcer text size", [0.1, 1, 0.1, 0.5, "announcerTextSize"]],
        ["slider", "Map marker scale threshold", [0, 1, 0.05, 0.4, "sectorMarkerTextThreshold"]],
        ["slider", "Map icon scale", [0.5, 2, 0.05, 1.0, "mapIconScale"]],
        ["slider", "Respawn: smoke grenades", [0, 2, 1, 1, "respawnSmokeGrenades"]],
        ["slider", "Respawn: frag grenades", [0, 3, 1, 2, "respawnFragGrenades"]],
        ["slider", "Respawn: first aid kits ", [0, 3, 1, 3, "respawnFirstAidKits"]],
        ["category", "General settings"],
        ["checkbox", "Disable 3rd person view (2x reward)", ["3rdPersonDisabled", false]],
        ["checkbox", "Autonomous mode off by default", ["enableAuto", false]],
        ["checkbox", "Spawn vehicles with empty inventory", ["spawnEmpty", false]],
        ["checkbox", "Disable missile cameras", ["disableMissileCameras", false]],
        ["checkbox", "Show user-defined markers", ["showMarkers", true]],
        ["checkbox", "No voice speaker", ["noVoiceSpeaker", false]],
        ["checkbox", "Mute task notifications", ["muteTaskNotifications", false]],
        ["checkbox", "Disable incoming missile indicator", ["disableIncomingMissileDisplay", false]],
        ["checkbox", "Hide squad menu in scroll menu", ["hideSquadMenu", false]],
        ["checkbox", "Hide buy menu in scroll menu", ["hideBuyMenu", false]],
        ["checkbox", "Hide vehicle manager in scroll menu", ["hideVehicleManager", false]],
        ["checkbox", "Delete quad bike/water scooter on exit", ["deleteSmallTransports", true]],
        ["checkbox", "Respawn: spawn with UAV Terminal", ["respawnUavTerminal", true]]
    ];

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
        "const gameDataEl = document.getElementById('game-data'); gameDataEl.innerHTML = atob(""%1""); createMenu();",
        _settingsMenuText
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
}];