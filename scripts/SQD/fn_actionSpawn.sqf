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

        private _isSelected = (_tile isEqualTo _spawnTile);

        private _spawnLocationName = _tile controlsGroupCtrl SQD_LOCATION_NAME_IDC;
        private _nameColor = if (_isSelected) then {
            [0.5, 0.5, 0.5, 1]
        } else {
            [SQD_RGBA_TEXT]
        };
        _spawnLocationName ctrlSetTextColor _nameColor;

        private _spawnLocationBg = _tile controlsGroupCtrl SQD_LOCATION_BG_IDC;
        private _spawnLocationBgColor = if (_isSelected) then {
            [SQD_RGBA_BG]
        } else {
            [SQD_RGBA_DARKER]
        };
        _spawnLocationBg ctrlSetBackgroundColor _spawnLocationBgColor;

        private _spawnLocationHeader = _tile controlsGroupCtrl SQD_LOCATION_HEADER_IDC;
        private _headerColor = if (_isSelected) then {
            [0.5, 1, 1, 1]
        } else {
            [SQD_RGBA_DARK]
        };
        _spawnLocationHeader ctrlSetBackgroundColor _headerColor;
    } forEach _spawnTiles;
} forEach _spawnControls;

[_spawnTarget, _specialSpawnTarget] call SQD_fnc_setSpawnCam;