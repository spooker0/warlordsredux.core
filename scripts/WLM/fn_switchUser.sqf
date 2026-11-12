#include "includes.inc"
params ["_control"];

private _asset = uiNamespace getVariable "WLM_asset";

private _isSolo = count (allTurrets _asset) == 0;

if (_isSolo) exitWith {
    _control ctrlSetText "a3\ui_f\data\IGUI\Cfg\CommandBar\imageDriver_ca.paa";
    _control ctrlSetTooltip (localize "STR_WL_wlmControlPilot");
};

if (ctrlTooltip _control == (localize "STR_WL_wlmControlPilot")) then {
    _control ctrlSetText "a3\ui_f\data\IGUI\Cfg\CommandBar\imageGunner_ca.paa";
    _control ctrlSetTooltip (localize "STR_WL_wlmControlGunner");
} else {
    _control ctrlSetText "a3\ui_f\data\IGUI\Cfg\CommandBar\imageDriver_ca.paa";
    _control ctrlSetTooltip (localize "STR_WL_wlmControlPilot");
};