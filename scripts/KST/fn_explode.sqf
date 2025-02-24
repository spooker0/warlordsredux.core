params ["_pos", "_unit"];
private _ammo = createVehicleLocal ["R_PG7_F", [_pos # 0, _pos # 1, 1000], [], 0, "FLY"];
_ammo setShotParents [_unit, _unit];
_ammo setPosASL _pos;
triggerAmmo _ammo;