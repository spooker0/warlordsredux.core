#include "includes.inc"
params ["_className"];

private _dlcName = getText (configFile >> "CfgVehicles" >> _className >> "DLC");
private _dlcConfig = configFile >> "CfgMods" >> _dlcName;
private _owned = true;
if (_dlcName != "") then {
    private _appId = getNumber (_dlcConfig >> "appId");
    _owned = _appId in (getDLCs 1);
};

private _tooltip = getText (_dlcConfig >> "vehPrevMsgText");
[_owned, _tooltip];
