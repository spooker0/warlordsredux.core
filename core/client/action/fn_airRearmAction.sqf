#include "includes.inc"
params ["_asset"];

_asset addAction [
    "<t color = '#4bff58'>Inflight rearm/refuel</t>",
    {
        params ["_asset", "_caller"];
        private _rearmSource = cursorObject;
        private _rearmSourcePos = _rearmSource modelToWorld [0, 0, 0];
        if (_rearmSourcePos # 2 < 75) exitWith {
            playSoundUI ["AddItemFailed"];
            ["Rearm source is not flying above 75M!"] call WL2_fnc_smoothText;
        };

        _asset setVehicleAmmo 1;

        private _rearmTime = WL_UNIT(_asset, "rearm", 600);
        _asset setVariable ["BIS_WL_nextRearm", serverTime + _rearmTime, true];

        _asset setFuel 1;

        playSoundUI ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Rearm.wss"];
        [localize "STR_A3_WL_popup_asset_rearmed"] call WL2_fnc_smoothText;
    },
    [],
    200,
    false,
    false,
    "",
    "_target == _this && _target getVariable ['BIS_WL_nextRearm', 0] < serverTime && cursorObject distance _target < 300 && cursorObject getVariable ['WL2_hasInflightRearm', false]",
    50,
    true
];