#include "includes.inc"
params ["_texture"];

private _loadoutNames = [];
for "_i" from 0 to 9 do {
    private _loadoutVar = format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _i];
    private _loadoutData = profileNamespace getVariable [_loadoutVar, []];

    private _loadoutName = [];

    if (count _loadoutData < 10) then {
        _loadoutNames pushBack [];
        continue;
    };
    private _primaryWeapon = _loadoutData select 0;
    if (count _primaryWeapon > 0) then {
        _primaryWeapon = _primaryWeapon select 0;
        private _primaryWeaponName = getText (configFile >> "CfgWeapons" >> _primaryWeapon >> "displayName");
        _loadoutName pushBack _primaryWeaponName;
    };

    private _secondaryWeapon = _loadoutData select 1;
    if (count _secondaryWeapon > 0) then {
        _secondaryWeapon = _secondaryWeapon select 0;
        private _secondaryWeaponName = getText (configFile >> "CfgWeapons" >> _secondaryWeapon >> "displayName");
        _loadoutName pushBack _secondaryWeaponName;
    };

    private _handgun = _loadoutData select 2;
    if (count _handgun > 0) then {
        _handgun = _handgun select 0;
        private _handgunName = getText (configFile >> "CfgWeapons" >> _handgun >> "displayName");
        _loadoutName pushBack _handgunName;
    };
    _loadoutName = _loadoutName apply {
        private _loadoutNameArray = toArray _x;
        {
            if (_x == 160) then {
                _loadoutNameArray set [_forEachIndex, 32];
            };
        } forEach _loadoutNameArray;
        toString _loadoutNameArray;
    };
    _loadoutName = _loadoutName select { _x != "" };
    _loadoutName = _loadoutName apply {
        _texture ctrlWebBrowserAction ["ToBase64", _x];
    };
    _loadoutNames pushBack _loadoutName;
};

_loadoutNames