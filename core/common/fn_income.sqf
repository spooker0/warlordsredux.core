#include "includes.inc"
params ["_side"];

if (_side == independent) exitWith {
	200;
};

if (!isServer) exitWith { 0 };

if (isNil "BIS_WL_sectorsArrays") then {
	50;
} else {
	(BIS_WL_sectorsArrays # (BIS_WL_competingSides find _side)) # 4;
};