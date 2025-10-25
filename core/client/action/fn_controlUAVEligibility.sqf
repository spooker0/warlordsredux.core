#include "includes.inc"

private _cursorObject = cursorObject;
if (alive _cursorObject && unitIsUAV _cursorObject) exitWith {
    private _access = [_cursorObject, player, "driver"] call WL2_fnc_accessControl;
    _access # 0
};

private _remoteTarget = uiNamespace getVariable ["WL2_remoteControlTarget", objNull];
if (!alive _remoteTarget || !unitIsUAV _remoteTarget) exitWith { false };
private _remoteAccess = [_remoteTarget, player, "driver"] call WL2_fnc_accessControl;
_remoteAccess # 0