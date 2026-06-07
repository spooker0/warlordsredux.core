#include "includes.inc"
params ["_button"];

private _spawnTarget = _button getVariable ["SQD_spawnTarget", objNull];
missionNamespace setVariable ["SQD_selectedSpawnTarget", _spawnTarget];

private _specialSpawnTarget = _button getVariable ["SQD_specialSpawnTarget", [objNull, ""]];
missionNamespace setVariable ["SQD_selectedSpecialSpawnTarget", _specialSpawnTarget];

private _spawnTile = ctrlParentControlsGroup _button;
private _display = ctrlParent _spawnTile;

private _spawnControls = _display getVariable ["SQD_spawnControls", createHashMap];

{
    private _spawnEntry = _y;
    private _spawnTiles = _spawnEntry getOrDefault ["tiles", createHashMap];

    {
        private _tile = _y;

        private _color = if (_tile isEqualTo _spawnTile) then {
            [0.2, 1, 0.2, 1]
        } else {
            [1, 1, 1, 1]
        };

        private _name = _tile controlsGroupCtrl SQD_LOCATION_NAME_IDC;
        _name ctrlSetTextColor _color;

        private _icon = _tile controlsGroupCtrl SQD_LOCATION_ICON_IDC;
        _icon ctrlSetTextColor _color;
    } forEach _spawnTiles;
} forEach _spawnControls;

[_spawnTarget, _specialSpawnTarget] call SQD_fnc_setSpawnCam;