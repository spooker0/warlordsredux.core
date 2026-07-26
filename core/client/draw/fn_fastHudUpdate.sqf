#include "includes.inc"

private _display = uiNamespace getVariable ["RscWarlordsHUD", displayNull];

while { isNull _display } do {
    _display = uiNamespace getVariable ["RscWarlordsHUD", displayNull];
    uiSleep 0.1;
};
private _mapModeControl = _display displayCtrl 2113;
_mapModeControl ctrlSetTextColor [0.1, 0.1, 0.1, 1];

while { !BIS_WL_missionEnd } do {
    if (visibleMap) then {
        private _mapMode = uiNamespace getVariable ["WL2_mapMode", 0];
        private _mapModeDisplays = [
            [localize "STR_WL_regular", "\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa"],
            [localize "STR_WL_airAirDefense", "\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa"],
            [localize "STR_WL_myAssets", "\a3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa"]
        ];
        private _mapModeDisplay = _mapModeDisplays select _mapMode;
        _mapModeControl ctrlSetStructuredText parseText format [
            "<t shadow='0' size='1.1' align='center'><img image='%2' /><br/>%1</t>",
            toUpper (_mapModeDisplay select 0),
            _mapModeDisplay select 1
        ];
        _mapModeControl ctrlShow true;
    } else {
        _mapModeControl ctrlShow false;
    };

    uiSleep 0.1;
};