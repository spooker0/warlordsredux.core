#include "includes.inc"
params ["_sector"];

private _asset = cameraOn;
if (WL_ISDOWN(_asset)) exitWith {};
if !(_asset isKindOf "Air") exitWith {};

playSoundUI ["a3\dubbing_f_jets\showcase_jets\30_reinforcements\showcase_jets_30_reinforcements_tower_0.wss"];

private _warningTextDisplay = uiNamespace getVariable ["RscWLExtendedSamWarningDisplay", displayNull];
if (isNull _warningTextDisplay) then {
    "CapWarning" cutRsc ["RscWLExtendedSamWarningDisplay", "PLAIN", -1, true, true];
    _warningTextDisplay = uiNamespace getVariable ["RscWLExtendedSamWarningDisplay", displayNull];
};

private _sectorDisplay = _warningTextDisplay displayCtrl 35600;
private _targetName = _sector getVariable ["WL2_name", "Forward Airbase"];
private _distanceToTarget = ((_sector distance2D cameraOn) / 1000) toFixed 1;
_sectorDisplay ctrlSetText format ["%1 (%2 KM)", _targetName, _distanceToTarget];

uiSleep 7;

"CapWarning" cutText ["", "PLAIN"];