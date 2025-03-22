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
    sleep 0.1;
    private _target = cursorTarget;
    if (isNull _target) then {
        _newControl ctrlShow false;
        continue;
    };
    private _targetTypeName = [_target] call WL2_fnc_getAssetTypeName;
    private _existingText = ctrlText _existingControl;
    if (_existingText == _targetTypeName || _existingText == "--") then {
        _newControl ctrlShow false;
    } else {
        _newControl ctrlShow true;
        _newControl ctrlSetText _targetTypeName;
    };
};

ctrlDelete _newControl;