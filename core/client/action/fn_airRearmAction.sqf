#include "includes.inc"
params ["_asset"];

_asset addAction [
    "<t color = '#4bff58'>Inflight rearm/refuel</t>",
    {
        params ["_asset", "_caller"];
        private _rearmSource = cursorObject;
        private _rearmSourcePos = _rearmSource modelToWorld [0, 0, 0];
        if (_rearmSourcePos # 2 < 300) exitWith {
            playSoundUI ["AddItemFailed"];
            systemChat "Rearm source is not flying above 300M!";
        };

        _asset setVehicleAmmo 1;
        private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
        private _rearmTime = WL_ASSET(_assetActualType, "rearm", 600);
        _asset setVariable ["BIS_WL_nextRearm", serverTime + _rearmTime, true];

        _asset setFuel 1;

        playSoundUI ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Rearm.wss"];
        [toUpper localize "STR_A3_WL_popup_asset_rearmed"] spawn WL2_fnc_smoothText;
    },
    [],
    200,
    false,
    false,
    "",
    "_target getVariable ['BIS_WL_nextRearm', 0] < serverTime && cursorObject distance _target < 300 && cursorObject getVariable ['WL2_hasInflightRearm', false]",
    50,
    true
];