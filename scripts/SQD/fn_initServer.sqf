#include "includes.inc"
if (isNil "SQUAD_MANAGER") then {
    SQUAD_MANAGER = [];
};
missionNamespace setVariable ["SQUAD_MANAGER", SQUAD_MANAGER, true];
missionNamespace setVariable ["WL2_totalPointsEarned", createHashMap];

addMissionEventHandler ["HandleDisconnect", {
	params ["_unit", "_id", "_uid", "_name"];
    ["cleanUp"] call SQD_fnc_server;
}];

// Clean up the squad manager
0 spawn {
    while { !BIS_WL_missionEnd } do {
        ["cleanUp"] call SQD_fnc_server;
        uiSleep 30;
    };
};