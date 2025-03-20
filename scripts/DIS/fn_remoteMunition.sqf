params ["_asset"];

private _camera = "camera" camCreate (position _asset);

"controlStation" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
private _display = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];
private _instructionsDisplay = _display ctrlCreate ["RscStructuredText", -1];
private _mapDisplay = _display ctrlCreate ["RscMapControl", -1];

private _prepareInterface = {
    _camera setVectorDirAndUp [vectorDir _asset, vectorUp _asset];
    _camera attachTo [_asset, [0, -5, 3]];

    _instructionsDisplay ctrlSetPosition [0.25, 1 - safeZoneY - 0.3, 0.5, 0.3];
    _instructionsDisplay ctrlSetTextColor [1, 1, 1, 1];

    private _instructionStages = [
        ["ActionContext", "Exit"],
        ["zoomIn", "Map Zoom In"],
        ["zoomOut", "Map Zoom Out"]
    ];

    _instructionStages = _instructionStages apply {
        private _action = _x # 0;
        private _text = _x # 1;
        format ["<t align='left'>%1</t><t align='right'>[%2]</t>", _text, (actionKeysNames [_action, 1, "Combo"]) regexReplace ["""", ""]];
    };
    private _instructionText = _instructionStages joinString "<br/>";

    _instructionsDisplay ctrlSetStructuredText parseText format [
        "<t size='1.2'>%1</t>",
        _instructionText
    ];
    _instructionsDisplay ctrlCommit 0;

    _mapDisplay ctrlCommit 0;
    _mapDisplay ctrlMapSetPosition [safeZoneX + 0.1, 0.5, 0.6, 0.8];
    _mapDisplay ctrlMapAnimAdd [0, 0.2, getPosASL _asset];
    ctrlMapAnimCommit _mapDisplay;
    _mapDisplay mapCenterOnCamera true;
    _mapDisplay ctrlAddEventHandler ["Draw", WL2_fnc_iconDrawMap];
};

call _prepareInterface;

_camera switchCamera "INTERNAL";
cameraEffectEnableHUD true;
showHUD [true, true, true, true, true, true, true, true, true, true, true];
player setVariable ["WL_hmdOverride", 1];

waitUntil {
    sleep 0.001;
    inputAction "ActionContext" == 0
};

while { alive _asset && (_asset getVariable ["WL2_linkedPlayer", objNull]) == player } do {
    if (inputAction "ActionContext" > 0) then {
        break;
    };

    private _zoomInMap = inputAction "zoomIn";
    if (_zoomInMap > 0) then {
        waitUntil {
            inputAction "zoomIn" == 0
        };
        private _currentZoom = ctrlMapScale _mapDisplay;
        _mapDisplay ctrlMapAnimAdd [0, _currentZoom / 2, getPosASL _asset];
        ctrlMapAnimCommit _mapDisplay;
    };
    private _zoomOutMap = inputAction "zoomOut";
    if (_zoomOutMap > 0) then {
        waitUntil {
            inputAction "zoomOut" == 0
        };
        private _currentZoom = ctrlMapScale _mapDisplay;
        _mapDisplay ctrlMapAnimAdd [0, _currentZoom * 2, getPosASL _asset];
        ctrlMapAnimCommit _mapDisplay;
    };

    private _controlledProjectile = _asset getVariable ["APS_remoteControlled", objNull];
    if !(isNull _controlledProjectile) then {
        _asset setVariable ["APS_remoteControlled", objNull, true];
        sleep 1;

        "controlStation" cutText ["", "PLAIN"];
        private _projectileASL = getPosASL _controlledProjectile;
        private _projectileVectorDirAndUp = [vectorDir _controlledProjectile, vectorUp _controlledProjectile];
        private _projectileVelocity = (velocityModelSpace _controlledProjectile) vectorMultiply 3;
        deleteVehicle _controlledProjectile;

        private _projectile = createVehicle ["ammo_Bomb_SDB", [0, 0, 0], [], 0, "FLY"];
        _projectile setPosASL _projectileASL;
        _projectile setVectorDirAndUp _projectileVectorDirAndUp;
        _projectile setVelocityModelSpace _projectileVelocity;

        _projectile setVariable ["APS_speedOverride", 400];

        _camera setVectorDirAndUp [vectorDir _projectile, vectorUp _projectile];
        _camera attachTo [_projectile, [0, -3, 0.4]];

        [_projectile, 3] call DIS_fnc_controlMunition;

        call _prepareInterface;
    };

    sleep 0.001;
};

player setVariable ["WL_hmdOverride", -1];
switchCamera player;
camDestroy _camera;

"controlStation" cutText ["", "PLAIN"];