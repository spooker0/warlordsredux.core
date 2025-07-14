#include "includes.inc"
params ["_texture"];

private _gpsSelectionIndex = cameraOn getVariable ["DIS_selectionIndex", 0];
private _gpsCord = cameraOn getVariable ["DIS_gpsCord", ""];

private _inRangeCalculation = [cameraOn] call DIS_fnc_calculateInRange;
if (cameraOn getVariable ["WL2_ignoreRange", false]) then {
	_inRangeCalculation set [0, true];
    _inRangeCalculation set [1, 36000];
};

private _gpsBombs = cameraOn getVariable ["DIS_gpsBombs", []];
private _bombsTextArray = [];
{
    private _projectile = _x;
    if (!alive _projectile) then {
        continue;
    };

    private _posAGL = _projectile modelToWorld [0, 0, 0];
    if (_posAGL select 2 < 50) then {
        continue;
    };

    private _terminalTarget = _projectile getVariable ["DIS_terminalTarget", ""];
    if (_terminalTarget == "") then {
        private _target = _projectile getVariable ["DIS_targetCoordinates", [0, 0, 0]];
        private _distance = _projectile distance _target;
        _bombsTextArray pushBack format ["FLY [%1 KM]", (_distance / 1000) toFixed 1];
    } else {
        _bombsTextArray pushBack format ["TARGET %1", toUpper _terminalTarget];
    };
} forEach _gpsBombs;
private _bombsText = toJSON _bombsTextArray;

_bombsText = _texture ctrlWebBrowserAction ["ToBase64", _bombsText];

private _script = format [
    "const selectionIndexEl = document.getElementById('selection-index'); selectionIndexEl.textContent = '%1'; const gridCordEl = document.getElementById('grid-coord'); gridCordEl.textContent = '%2'; const targetRangeEl = document.getElementById('target-range'); targetRangeEl.textContent = '%3'; const assetRangeEl = document.getElementById('asset-range'); assetRangeEl.textContent = '%4'; const inRangeEl = document.getElementById('in-range'); inRangeEl.textContent = '%5'; const bombsEl = document.getElementById('bombs'); bombsEl.innerHTML = atob(""%6""); updateData();",
    _gpsSelectionIndex,
    _gpsCord,
    (_inRangeCalculation # 2 / 1000) toFixed 1,
    (_inRangeCalculation # 1 / 1000) toFixed 1,
    str (_inRangeCalculation # 0),
    _bombsText
];
_texture ctrlWebBrowserAction ["ExecJS", _script];