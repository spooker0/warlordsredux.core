params ["_dazzler", "_projectileAPSConsumption"];

private _dazzlerFuel = fuel _dazzler;
_dazzler setFuel (_dazzlerFuel - 0.04 * _projectileAPSConsumption);
_dazzler setVariable ["WL2_refuelBlocked", serverTime + 30, true];