#include "includes.inc"
params ["_texture"];

private _gpsSelectionIndex = cameraOn getVariable ["DIS_selectionIndex", 0];
private _gpsCord = cameraOn getVariable ["DIS_gpsCord", ""];

private _inRangeCalculation = [cameraOn] call DIS_fnc_calculateInRange;

private _gpsBombs = cameraOn getVariable ["DIS_gpsBombs", []];
_gpsBombs = _gpsBombs select { alive _x };
private _bombsText = toJSON (
    _gpsBombs apply {
        private _projectile = _x;
        private _terminalTarget = _projectile getVariable ["DIS_terminalTarget", ""];
        if (_terminalTarget == "") then {
            private _target = _projectile getVariable ["DIS_targetCoordinates", [0, 0, 0]];
            private _distance = _projectile distance _target;
            format ["FLY [%1 KM]", (_distance / 1000) toFixed 1]
        } else {
            format ["TARGET %1", toUpper _terminalTarget]
        };
    }
);
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