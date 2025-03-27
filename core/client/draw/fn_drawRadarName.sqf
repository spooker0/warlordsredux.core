private _radarDisplay = uiNamespace getVariable ["RscCustomInfoSensors", displayNull];
private _existingControl = _radarDisplay displayCtrl 107;
private _existingPosition = ctrlPosition _existingControl;

private _newControl = _radarDisplay ctrlCreate ["RscText", -1];
_newControl ctrlSetPosition [0, -0.06, 1, 0.1];
_newControl ctrlSetTextColor [0.2, 1, 0.2, 1];
_newControl ctrlSetFontHeight (ctrlFontHeight _existingControl);
_newControl ctrlSetShadow 0;
_newControl ctrlCommit 0;

sleep 3;

while { alive player } do {
    sleep 0.05;
    private _target = cursorTarget;
    if (isNull _target) then {
        _newControl ctrlShow false;
        continue;
    };
    private _targetTypeName = [_target] call WL2_fnc_getAssetTypeName;
    private _assetPrimitiveName = getText (configFile >> "CfgVehicles" >> typeof _target >> "displayName");
    private _existingText = ctrlText _existingControl;
    if (_existingText == _targetTypeName || _existingText == "--" || _targetTypeName == "" || _existingText != _assetPrimitiveName) then {
        _newControl ctrlShow false;
    } else {
        _newControl ctrlShow true;
        _newControl ctrlSetText format ["Variant: %1", _targetTypeName];
        _newControl ctrlCommit 0;
    };
};

ctrlDelete _newControl;