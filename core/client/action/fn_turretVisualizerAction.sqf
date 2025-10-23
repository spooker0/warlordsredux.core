#include "includes.inc"
params ["_asset"];

_asset addAction [
    "<t color='#00FF00'>Toggle Turret View</t>",
    {
        params ["_target", "_caller", "_id", "_args"];
        private _display = uiNamespace getVariable ["RscWLTurretMenu", displayNull];
        if (isNull _display) then {
            0 spawn WL2_fnc_toggleTurretVisualizer;
        } else {
            "turretLimits" cutText ["", "PLAIN"];
        };
    },
    nil,
    100,
    false,
    true,
    "",
    "alive _target && cameraOn == _target"
];