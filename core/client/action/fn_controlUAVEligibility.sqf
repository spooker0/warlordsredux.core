#include "includes.inc"

private _cursorObject = cursorObject;
private _isDrone = [_cursorObject] call WL2_fnc_isDrone;

if (alive _cursorObject && _isDrone) exitWith {
    private _access = [_cursorObject, player, "driver"] call WL2_fnc_accessControl;
    _access # 0
};

private _remoteTarget = uiNamespace getVariable ["WL2_remoteControlTarget", objNull];
if (!alive _remoteTarget || !([_remoteTarget] call WL2_fnc_isDrone)) exitWith { false };
private _remoteAccess = [_remoteTarget, player, "driver"] call WL2_fnc_accessControl;
_remoteAccess # 0