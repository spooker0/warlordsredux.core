#include "includes.inc"
params ["_sectorName"];

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
_sectorDisplay ctrlSetText _sectorName;

uiSleep 7;

"CapWarning" cutText ["", "PLAIN"];