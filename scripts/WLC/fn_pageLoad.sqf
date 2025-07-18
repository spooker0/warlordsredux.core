#include "includes.inc"
params ["_texture"];

private _wlcData = [] call WLC_fnc_loadData;
private _magazineDataText = _wlcData # 0;
private _weaponDataText = _wlcData # 1;

private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];

private _loadout = profileNamespace getVariable [format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _loadoutIndex], []];
if (count _loadout == 0) then {
    _loadout = getUnitLoadout player;
};

private _loadoutText = toJSON _loadout;
_loadoutText = _texture ctrlWebBrowserAction ["ToBase64", _loadoutText];

private _playerLevel = ["getLevel"] call WLC_fnc_getLevelInfo;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _themeIndex = _settingsMap getOrDefault ["loadoutTheme", 1];

private _script = format [
    "updateLoadout(atob(""%1""), %2, atob(""%3""), atob(""%4""), %5, %6);",
    _loadoutText,
    _loadoutIndex,
    _weaponDataText,
    _magazineDataText,
    _playerLevel,
    _themeIndex
];
_texture ctrlWebBrowserAction ["ExecJS", _script];