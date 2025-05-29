#include "constants.inc"

private _display = findDisplay MENU_DISPLAY;
if (isNull _display) then {
    _display = createDialog ["MENU_Settings", true];
};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

["TaskThirdPerson"] call WLT_fnc_taskComplete;
disableSerialization;

private _closeButton = _display displayCtrl MENU_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
}];

private _controlGroup = _display displayCtrl MENU_CONTROLS_GROUP;
_controlGroup ctrlShow false;

private _buttons = [
    ["SQUADS", {
        [true] call SQD_fnc_menu;
    }],
    ["REPORT", {
        [false] call MENU_fnc_moderatorMenu;
    }],
    ["POLL", {
        call POLL_fnc_pollMenu;
    }],
    ["PERFORMANCE", {
        closeDialog 0;
        0 spawn PERF_fnc_perfMenuInit;
    }],
    ["RESET ALL", {
        0 spawn MENU_fnc_resetDefault;
    }]
];

private _playerUid = getPlayerUID player;
private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
private _isSpectator = _playerUid in getArray (missionConfigFile >> "spectatorIDs");
private _isModerator = _playerUid in getArray (missionConfigFile >> "moderatorIDs");
if (_isAdmin) then {
    _buttons pushBack ["DEBUG", {
        [""] call MENU_fnc_debugMenu;
    }];
};
if (_isAdmin || _isSpectator) then {
    _buttons pushBack ["SPECTATE", {
        closeDialog 0;
        0 spawn SPEC_fnc_spectator;
    }];
};
if (_isAdmin || _isModerator) then {
    _buttons pushBack ["MODERATE", {
        [true] call MENU_fnc_moderatorMenu;
    }];
};

#if WL_REPLAYS
private _profileDrawIcons = profileNamespace getVariable ["WL2_drawIcons", ""];
if (_profileDrawIcons != "") then {
    _buttons pushBack ["REPLAY", {
        closeDialog 0;
        0 spawn WL2_fnc_replayMap;
    }];
    _buttons pushBack ["CLEAR REPLAY", {
        closeDialog 0;
        0 spawn WL2_fnc_replayMapClear;
    }];
};
#endif

private _buttonPositionX = 0.05;
private _positionY = 0.03;
{
    private _text = _x # 0;
    private _item = _display ctrlCreate ["MENU_MenuItemButton", -1, _controlGroup];
    _item ctrlSetPosition [_buttonPositionX, _positionY, 0.17, 0.07];
    _item ctrlSetText _text;
    _item ctrlAddEventHandler ["ButtonClick", _x # 1];

    _buttonPositionX = _buttonPositionX + 0.18;
    if (_buttonPositionX > (1 - 0.17) && _forEachIndex != (count _buttons - 1)) then {
        _buttonPositionX = 0.05;
        _positionY = _positionY + 0.08;
    };
} forEach _buttons;

_positionY = _positionY + 0.08;
{
    private _category = _x # 0;
    private _text = _x # 1;
    private _params = _x # 2;

    private _control = switch (_category) do {
        case "category": {
            private _itemHeight = 0.09;
            private _item = _display ctrlCreate ["MENU_MenuItemLabel", -1, _controlGroup];
            _item ctrlSetPosition [0.05, _positionY + 0.02, 0.9, _itemHeight - 0.02];
            _positionY = _positionY + _itemHeight;
            _item ctrlSetStructuredText parseText format ["<t size='1.2' color='#00cccc' align='center'>%1</t>", _text];
        };
        case "slider": {
            private _itemHeight = 0.06;
            private _textItem = _display ctrlCreate ["MENU_MenuItemLabel", -1, _controlGroup];
            _textItem ctrlSetPosition [0.05, _positionY + 0.01, 0.3, _itemHeight - 0.02];
            _textItem ctrlSetStructuredText parseText format ["<t size='1'>%1</t>", _text];

            private _currentPosition = _settingsMap getOrDefault [_params # 4, _params # 3];

            private _sliderItem = _display ctrlCreate ["MENU_MenuItemSliderControl", -1, _controlGroup];
            _sliderItem ctrlSetPosition [0.35, _positionY + 0.01, 0.45, _itemHeight - 0.02];
            _sliderItem sliderSetRange [_params # 0, _params # 1];
            _sliderItem sliderSetSpeed [_params # 2, _params # 2, _params # 2];
            _sliderItem sliderSetPosition _currentPosition;

            private _entryItem = _display ctrlCreate ["MENU_MenuItemSliderEntry", -1, _controlGroup];
            _entryItem ctrlSetPosition [0.85, _positionY + 0.01, 0.1, _itemHeight - 0.02];
            _entryItem ctrlSetText str _currentPosition;

            _sliderItem setVariable ["WL2_sliderEntry", _entryItem];
            _sliderItem setVariable ["WL2_sliderParams", _params];

            _entryItem setVariable ["WL2_slider", _sliderItem];

            _sliderItem ctrlAddEventHandler ["SliderPosChanged", {
                params ["_control", "_value"];
                private _params = _control getVariable ["WL2_sliderParams", []];

                private _min = _params # 0;
                private _max = _params # 1;
                if (_value < _min) then {
                    _value = _min;
                };
                if (_value > _max) then {
                    _value = _max;
                };

                private _entryItem = _control getVariable ["WL2_sliderEntry", objNull];
                _entryItem ctrlSetText str _value;

                private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
                _settingsMap set [_params # 4, _value];

                [] call MENU_fnc_updateViewDistance;
            }];

            _entryItem ctrlAddEventHandler ["EditChanged", {
                params ["_control", "_key"];
                private _sliderItem = _control getVariable ["WL2_slider", objNull];
                private _params = _sliderItem getVariable ["WL2_sliderParams", []];

                private _min = _params # 0;
                private _max = _params # 1;
                private _value = parseNumber (ctrlText _control);
                if (_value < _min) then {
                    _value = _min;
                };
                if (_value > _max) then {
                    _value = _max;
                };

                _sliderItem sliderSetPosition _value;

                private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
                _settingsMap set [_params # 4, _value];

                [] call MENU_fnc_updateViewDistance;
            }];

            _positionY = _positionY + _itemHeight;
        };
        case "checkbox": {
            private _itemHeight = 0.07;

            private _checkboxItem = _display ctrlCreate ["MENU_MenuItemCheckbox", -1, _controlGroup];
            _checkboxItem ctrlSetPosition [0.05, _positionY, (_itemHeight - 0.02) * 3 / 4, _itemHeight - 0.02];

            private _textItem = _display ctrlCreate ["MENU_MenuItemLabel", -1, _controlGroup];
            _textItem ctrlSetPosition [0.1, _positionY + 0.003, 0.7, _itemHeight - 0.01];
            _textItem ctrlSetStructuredText parseText format ["<t size='1'>%1</t>", _text];

            private _currentSetting = _settingsMap getOrDefault [_params # 0, _params # 1];
            _checkboxItem cbSetChecked _currentSetting;

            _checkboxItem setVariable ["WL2_checkboxParams", _params];

            _checkboxItem ctrlAddEventHandler ["CheckedChanged", {
                params ["_control", "_checked"];
                private _params = _control getVariable ["WL2_checkboxParams", []];
                private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

                private _setting = _params # 0;
                if (count _params >= 3) then {
                    private _rateLimit = _params # 2;

                    private _rateLimitVar = format ["%1_NextChangeAllowed", _setting];
                    private _rateLimitValue = missionNamespace getVariable [_rateLimitVar, 0];

                    if (_rateLimitValue > serverTime) then {
                        systemChat format [
                            "You cannot change this setting so often! You must wait %1 seconds before changing this setting again.",
                            round (_rateLimitValue - serverTime)
                        ];
                        playSound "AddItemFailed";
                        _control cbSetChecked (_checked != 1);
                    } else {
                        _settingsMap set [_setting, _checked == 1];
                        missionNamespace setVariable [_rateLimitVar, serverTime + _rateLimit];
                    };
                } else {
                    _settingsMap set [_setting, _checked == 1];
                };
            }];

            _positionY = _positionY + _itemHeight;
        };
    };
} forEach [
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
    ["slider", "Respawn: smoke grenades", [0, 2, 1, 1, "respawnSmokeGrenades"]],
    ["slider", "Respawn: frag grenades", [0, 3, 1, 2, "respawnFragGrenades"]],
    ["slider", "Respawn: first air kits ", [0, 3, 1, 3, "respawnFirstAidKits"]],
    ["category", "General settings"],
    ["checkbox", "Disable 3rd person view (2x reward)", ["3rdPersonDisabled", false, 360]],
    ["checkbox", "Autonomous mode off by default", ["enableAuto", false]],
    ["checkbox", "Spawn vehicles with empty inventory", ["spawnEmpty", false]],
    ["checkbox", "Disable missile cameras", ["disableMissileCameras", false]],
    ["checkbox", "Show user-defined markers", ["showMarkers", true]],
    ["checkbox", "No voice speaker", ["noVoiceSpeaker", false]],
    ["checkbox", "Mute task notifications", ["muteTaskNotifications", false]],
    ["checkbox", "Disable incoming missile indicator", ["disableIncomingMissileDisplay", false]],
    ["checkbox", "Hide squad menu in scroll menu", ["hideSquadMenu", false]],
    ["checkbox", "Delete quad bike/water scooter on exit", ["deleteSmallTransports", true]]
];

{
    _x ctrlCommit 0;
} forEach (allControls _controlGroup);

_controlGroup ctrlShow true;