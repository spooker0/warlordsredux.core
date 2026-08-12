#include "includes.inc"
params ["_canTalk"];

{
	_x enableChannel [true, _canTalk];
} forEach [1, 3, 4, 5];
{
	_x enableChannel [_canTalk, false, false, false];
} forEach [0, 2];