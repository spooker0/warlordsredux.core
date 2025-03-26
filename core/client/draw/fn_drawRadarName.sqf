private _radarDisplay = uiNamespace getVariable ["RscCustomInfoSensors", displayNull];
private _existingControl = _radarDisplay displayCtrl 107;
private _existingPosition = ctrlPosition _existingControl;

private _newControl = _radarDisplay ctrlCreate ["RscText", -1];
_existingPosition set [2, _existingPosition # 2 / 2];

_newControl ctrlSetPosition _existingPosition;
_newControl ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
_newControl ctrlSetTextColor (ctrlTextColor _existingControl);
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
    if (_existingText == _targetTypeName || _existingText == "--" || _existingText != _assetPrimitiveName || _targetTypeName == "") then {
        _newControl ctrlShow false;
    } else {
        _newControl ctrlShow true;
        private _oldTextWidth = ctrlTextWidth _existingControl;
        _newControl ctrlSetText _targetTypeName;
        private _newTextWidth = ctrlTextWidth _newControl;
        _existingPosition set [2, _oldTextWidth max _newTextWidth];
        _newControl ctrlSetPosition _existingPosition;
        _newControl ctrlCommit 0;
    };
};

ctrlDelete _newControl;