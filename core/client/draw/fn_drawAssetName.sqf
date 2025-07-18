#include "includes.inc"
params ["_vehicle"];

[_thisScript] spawn {
    params ["_script"];
    private _startTime = serverTime;
    waitUntil {
        sleep 1;
        serverTime - _startTime > 10 || scriptDone _script;
    };
    if (!scriptDone _script) then {
        terminate _script;
    };
};

private _unitInfo = uiNamespace getVariable ["RscUnitInfo", displayNull];
waitUntil {
    sleep 0.1;
    _unitInfo = uiNamespace getVariable ["RscUnitInfo", displayNull];
    !isNull _unitInfo;
};

private _existingControl = _unitInfo displayCtrl 120;

waitUntil {
    sleep 0.1;
    _existingControl = _unitInfo displayCtrl 120;
    !isNull _existingControl;
};

waitUntil {
    sleep 0.1;
    ctrlText _existingControl != "" && ctrlShown _existingControl;
};

private _vehicleType = typeof _vehicle;
private _vehicleActualType = _vehicle getVariable ["WL2_orderedClass", _vehicleType];
private _vehicleBaseType = getText (configFile >> "CfgVehicles" >> _vehicleType >> "displayName");
private _vehicleActualType = [_vehicle] call WL2_fnc_getAssetTypeName;

if (_vehicleBaseType != _vehicleActualType) then {
    private _controlGroup = ctrlParentControlsGroup _existingControl;
    private _newControl = _unitInfo ctrlCreate ["RscText", -1, _controlGroup];
    _newControl ctrlSetPosition (ctrlPosition _existingControl);
    _newControl ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
    _newControl ctrlSetTextColor (ctrlTextColor _existingControl);
    _newControl ctrlSetFontHeight (ctrlFontHeight _existingControl);
    _newControl ctrlSetShadow 0;
    _newControl ctrlSetText _vehicleActualType;
    _newControl ctrlCommit 0;
};