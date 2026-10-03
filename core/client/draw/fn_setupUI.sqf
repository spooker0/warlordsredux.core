#include "includes.inc"
params ["_displayClass"];
if (_displayClass == "RequestMenu_open") exitWith { call WL2_fnc_initPurchaseMenu; };
if (_displayClass == "RequestMenu_close") then {
    (uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull]) closeDisplay 1;
};
