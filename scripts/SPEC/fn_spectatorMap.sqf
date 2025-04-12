#include "constants.inc"

private _hudRangeDistances = [0, 250, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000];
private _hudRangeIndex = 7;

removeMissionEventHandler ["Draw3D", BIS_EGSpectator_draw3D];

private _setNewRange = {
    params ["_range"];
    private _gogglesDisplay = uiNamespace getVariable ["RscWLGogglesDisplay", displayNull];
    if (isNull _gogglesDisplay) then {
        "WLGoggles" cutRsc ["RscWLGogglesDisplay", "PLAIN"];
        _gogglesDisplay = uiNamespace getVariable ["RscWLGogglesDisplay", displayNull];
    };
    private _rangeControl = _gogglesDisplay displayCtrl 8000;
    _rangeControl ctrlSetText str _range;

    if (_range == 0) then {
        _gogglesDisplay closeDisplay 0;
        uiNamespace setVariable ["RscWLGogglesDisplay", displayNull];
    };

    uiNamespace setVariable ["WL_SpectatorHudMaxDistance", _range];
    playSoundUI ["a3\sounds_f_mark\arsenal\sfx\bipods\bipod_generic_deploy.wss"];
};
[_hudRangeDistances # _hudRangeIndex] call _setNewRange;

private _spectatorDisplay = displayNull;
private _spectatorDisplayMap = controlNull;
private _mapGroup = controlNull;

while { isNull _mapGroup } do {
    _spectatorDisplay = findDisplay SPEC_DISPLAY;
    _spectatorDisplayMap = _spectatorDisplay displayCtrl SPEC_MAP_CONTROL;
    _mapGroup = ctrlParentControlsGroup _spectatorDisplayMap;
    sleep 0.1;
};

_mapGroup ctrlShow false;
_mapGroup ctrlSetPosition [0, 0, 0, 0];
_mapGroup ctrlCommit 0;

_spectatorDisplayMap ctrlShow false;
_spectatorDisplayMap ctrlSetPosition [0, 0, 0, 0];
_spectatorDisplayMap ctrlCommit 0;

private _camera = missionNamespace getVariable [SPEC_VAR_CAM, objNull];
_camera camCommand "speedMax 6";

private _mapDisplay = _spectatorDisplay ctrlCreate ["RscMapControl", -1];
_mapDisplay ctrlCommit 0;
_mapDisplay ctrlMapSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
_mapDisplay ctrlMapAnimAdd [0, 0.2, getPosASL _camera];
ctrlMapAnimCommit _mapDisplay;
_mapDisplay ctrlAddEventHandler ["Draw", WL2_fnc_iconDrawMap];
_mapDisplay ctrlShow false;

_mapDisplay ctrlAddEventHandler ["Draw", {
    params ["_map"];
    private _start = uiNamespace getVariable ["SPEC_mouseClickStart", []];
    if (count _start == 0) exitWith {};

    private _posStart = _map ctrlMapScreenToWorld _start;
    private _posEnd = _map ctrlMapScreenToWorld getMousePosition;

    if (_posStart distance2D _posEnd > 10) then {
        _map drawArrow [
            _posStart,
            _posEnd,
            [1, 0, 0, 1]
        ];
    };
}];

_mapDisplay ctrlAddEventHandler ["MouseButtonDown", {
    params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    if (_button != 0) exitWith {};
    // Start map drag
    uiNamespace setVariable ["SPEC_mouseClickStart", [_xPos, _yPos]];
}];

_mapDisplay ctrlAddEventHandler ["MouseButtonUp", {
    params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    if (_button != 0) exitWith {};

    private _start = uiNamespace getVariable ["SPEC_mouseClickStart", []];
    if (count _start == 0) exitWith {};
    uiNamespace setVariable ["SPEC_mouseClickStart", []];

    // Reset to free cam in scripts
    ["SetCameraMode", ["free"]] call SPEC_VAR_FUN_CAMERA;
    [] call SPEC_VAR_FUN_RESET_TARGET;
    ["TreeUnselect"] call SPEC_VAR_FUN_SPECTATOR;
    ["ShowFocusInfoWidget", [false]] call SPEC_VAR_FUN_SPECTATOR;

    // Remove focus
    uiNamespace setVariable [SPEC_VAR_FOCUS, objNull];

    private _camera = missionNamespace getVariable [SPEC_VAR_CAM, objNull];
    private _posStart = _map ctrlMapScreenToWorld _start;
    _posStart set [2, (getPosATL _camera) # 2];

    private _posEnd = _map ctrlMapScreenToWorld [_xPos, _yPos];
    _posEnd set [2, 0];

    if (_posStart distance2D _posEnd > 10) then {
        private _targetVectorDirAndUp = [_posStart, _posEnd] call BIS_fnc_findLookAt;
        _camera setVectorDirAndUp _targetVectorDirAndUp;
    };

    _camera setPosATL _posStart;
}];

private _instructionsDisplay = _spectatorDisplay ctrlCreate ["RscStructuredText", -1];
_instructionsDisplay ctrlSetPosition [
    1 - safeZoneX - 0.4 - 0.05,
    1 - safeZoneY - 0.55 - 0.05,
    0.4,
    0.6
];
_instructionsDisplay ctrlSetTextColor [1, 1, 1, 1];

private _instructionStages = [
    ["W/S", "Forward/Back"],
    ["A/D", "Left/Right"],
    ["Q/Z", "Up/Down"],
    ["RMB", "Camera rotate"],
    ["M", "Toggle map"],
    ["SHIFT", "Faster"],
    ["ALT", "Slower"],
    ["SPACE", "Camera mode"],
    ["=/-", "HUD range"],
    ["B", "Follow next projectile"],
    ["V", "Toggle mute VON"],
    ["BACK", "Toggle interface"],
    ["F1", "Toggle help"],
    ["K", "Settings menu"]
];

_instructionStages = _instructionStages apply {
    private _action = _x # 0;
    private _text = _x # 1;
    format ["<t align='left'>%1</t><t align='right'>[%2]</t>", _text, _action];
};
private _instructionText = _instructionStages joinString "<br/>";

_instructionsDisplay ctrlSetStructuredText parseText format [
    "<t size='1'>%1</t>",
    _instructionText
];
_instructionsDisplay ctrlCommit 0;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

while { WL_IsSpectator } do {
    if (inputAction "timeDec" > 0) then {
        waitUntil { inputAction "timeDec" == 0 };
        _hudRangeIndex = (_hudRangeIndex - 1) max 0;
        private _newMaxDistance = _hudRangeDistances # _hudRangeIndex;
        [_newMaxDistance] call _setNewRange;
    };
    if (inputAction "timeInc" > 0) then {
        waitUntil { inputAction "timeInc" == 0 };
        _hudRangeIndex = (_hudRangeIndex + 1) min (count _hudRangeDistances - 1);
        private _newMaxDistance = _hudRangeDistances # _hudRangeIndex;
        [_newMaxDistance] call _setNewRange;
    };

    private _infantryViewDistance = _settingsMap getOrDefault ["infantryViewDistance", 2000];
    private _spectatorViewDistance = _infantryViewDistance * 2;
    if (viewDistance != _spectatorViewDistance) then {
        setViewDistance _spectatorViewDistance;
        setObjectViewDistance [_spectatorViewDistance, 5];
    };

    private _mapButtonClick = uiNamespace getVariable ["RscEGSpectator_mapMouseButtonClick", -1];
    if (_mapButtonClick != -1) then {
        _mapGroup ctrlShow false;
        uiNamespace setVariable ["RscEGSpectator_mapMouseButtonClick", -1];
    };

    private _mapVisible = uiNamespace getVariable ["RscEGSpectator_mapVisible", false];
    _mapDisplay ctrlShow _mapVisible;

    if (inputAction "lookAround" > 0) then {
        _camera camCommand "speedDefault 0.5";
    } else {
        _camera camCommand "speedDefault 10";
    };

    private _interfaceVisible = uiNamespace getVariable ["RscEGSpectator_interfaceVisible", false];
    private _helpVisible = uinamespace getVariable ["RscEGSpectator_controlsHelpVisible", false];   // opposite due to init
    if (!_helpVisible && _interfaceVisible) then {
        _instructionsDisplay ctrlShow true;
    } else {
        _instructionsDisplay ctrlShow false;
    };

    sleep 0.001;
};