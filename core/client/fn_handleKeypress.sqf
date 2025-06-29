#include "includes.inc"
params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];

private _zeusKey = actionKeys "curatorInterface";
private _adminKeyPressed = _key in _zeusKey;
private _isAdmin = (getPlayerUID player) in (getArray (missionConfigFile >> "adminIDs"));
if (_adminKeyPressed && !_isAdmin) exitWith {
    true;
};

if (inputAction "cycleThrownItems" > 0.01 && !(isNull objectParent player)) exitWith {
    [vehicle player, 0, false] spawn APS_fnc_report;
    true;
};

private _canBuy = uiNamespace getVariable ["WL2_canBuy", true];
if (!_canBuy) exitWith {
    false;
};

private _intercept = false;
if (_key in actionKeys "Gear") then {
    private _keyAlreadyPressed = missionNamespace getVariable ["WL_gearKeyPressed", false];
    if (_keyAlreadyPressed || !(alive player) && lifeState player == "INCAPACITATED") exitWith {};
    if !(isNull (uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull])) exitWith {
        "RequestMenu_close" call WL2_fnc_setupUI;
    };

    _intercept = true;
    0 spawn {
        private _startTime = serverTime;
        WL_gearKeyPressed = true;
        waitUntil {
            !WL_gearKeyPressed || serverTime - _startTime > 0.5
        };

        if (WL_gearKeyPressed) exitWith {
            "RequestMenu_open" call WL2_fnc_setupUI;
        };

        if !(isNull findDisplay 602) exitWith {
            closeDialog 602;
        };

        if (cameraOn != player) exitWith {
            cameraOn action ["Gear", cameraOn];
        };

        private _cursorTarget = cursorTarget;
        if (_cursorTarget distance player > 8) exitWith {
            player action ["Gear", objNull];
        };
        if (_cursorTarget isKindOf "House") exitWith {
            player action ["Gear", objNull];
        };
        if (alive _cursorTarget || _cursorTarget isKindOf "Man") exitWith {
            player action ["Gear", _cursorTarget];
        };
        player action ["Gear", objNull];
    };
};

_intercept;
