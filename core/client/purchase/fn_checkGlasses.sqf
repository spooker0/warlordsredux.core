if (goggles player == "G_Tactical_Clear" && player getVariable ["WL_hasGoggles", false]) then {
    [false, "You've already bought this."];
} else {
    [true, ""];
};