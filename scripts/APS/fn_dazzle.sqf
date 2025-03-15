params ["_dazzler", "_projectileAPSConsumption"];

private _dazzlerFuel = fuel _dazzler;
_dazzler setFuel (_dazzlerFuel - 0.03 * _projectileAPSConsumption);