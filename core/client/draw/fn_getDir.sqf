params ["_unit"];

if (lifeState _unit == "INCAPACITATED") then {
    0;
} else {
    getDirVisual _unit;
};