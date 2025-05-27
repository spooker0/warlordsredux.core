private _settingsText = "<t color='#FF0000'>Settings</t>";
private _settingActionID = player addAction [
    _settingsText,
    MENU_fnc_settingsMenuInit,
    [],
    -99,
    false,
    false,
    "",
    ""
];
player setUserActionText [_settingActionID, _settingsText, "<img size='3' image='\a3\3den\Data\Displays\Display3DEN\PanelRight\submode_logic_module_ca'/>"];

private _previousVehicle = vehicle player;
private _previousDroneState = UAVControl (getConnectedUAV player) # 1;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
while { alive player } do {
    private _currentVehicle = vehicle player;
    private _connectedUAV = getConnectedUAV player;
    private _uavControl = UAVControl _connectedUAV;

    if (_currentVehicle != _previousVehicle || _uavControl # 1 != _previousDroneState) then {
        [] call MENU_fnc_updateViewDistance;
        _previousVehicle = _currentVehicle;
        _previousDroneState = _uavControl # 1;
    };

    private _isConnectable = _connectedUAV getVariable ["WL_canConnectUav", false];
    if (!_isConnectable) then {
        player connectTerminalToUAV objNull;
    };

    private _thirdPersonDisabled = _settingsMap getOrDefault ["3rdPersonDisabled", false];
    if (_thirdPersonDisabled) then {
        if (cameraView == "EXTERNAL") then {
            _currentVehicle switchCamera "Internal";
        };
    };
    private _playerThirdPersonDisabled = player getVariable ["WL2_3rdPersonDisabled", false];
    if (_playerThirdPersonDisabled != _thirdPersonDisabled) then {
        player setVariable ["WL2_3rdPersonDisabled", _thirdPersonDisabled, true];
    };

    if (cameraView == "GROUP") then {
        _currentVehicle switchCamera "Internal";
    };

    sleep 0.1;
};