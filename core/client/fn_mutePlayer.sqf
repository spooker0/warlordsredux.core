#include "includes.inc"
params ["_canTalk"];

{
	_x enableChannel [_canTalk, _canTalk]
} forEach [1, 3, 4, 5];
{
	_x enableChannel [_canTalk, false]
} forEach [0, 2];