#include "includes.inc"
params ["_side"];

private _return = [];
private _sideID = ["west", "east", "guerrila"] select (BIS_WL_sidesArray find _side);

private _i = 1;
for "_i" from 1 to 20 do {
	_return pushBack format ["respawn_%1_%2", _sideID, _i];
};

_return;