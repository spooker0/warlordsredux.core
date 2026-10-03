#include "includes.inc"

#ifdef WL_BUY_TRANSFER_TEST
[true, ""]
#else

if (count (allPlayers select { isPlayer _x && side group _x == BIS_WL_playerSide && _x != player }) == 0) then {
    [false, localize "STR_WL_noAlliedPlayers"]
} else {
    [true, ""]
};

#endif
