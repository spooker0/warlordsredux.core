#include "includes.inc"
if (isDedicated) exitWith {};

while { !BIS_WL_missionEnd } do {
    uiSleep 1;

    if (!isActionMenuVisible) then {
        continue;
    };

    if (!alive player) then {
        continue;
    };

    {
        private _focusedObject = _x;

        if (isNull _focusedObject) then {
            continue;
        };

        private _eligibility = [_focusedObject, player] call WL2_fnc_lockActionEligibility;
        if (!_eligibility) then {
            continue;
        };
        private _focusedObjectActionID = _focusedObject getVariable ["WL2_lockActionID", -1];
        if (_focusedObjectActionID < 0) then {
            continue;
        };

        [_focusedObject, _focusedObjectActionID] call WL2_fnc_vehicleLockUpdate;

        if (locked _focusedObject != 0) then {
            _focusedObject lock false;
        };
    } forEach [cursorObject, vehicle player];
};