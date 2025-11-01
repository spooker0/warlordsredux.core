#include "includes.inc"

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
        private _primaryWeaponNameArray = toArray _primaryWeaponName;
        {
            if (_x == 160) then {
                _primaryWeaponNameArray set [_forEachIndex, 32];
            };
        } forEach _primaryWeaponNameArray;
        _loadoutName pushBack (toString _primaryWeaponNameArray);
    };

    private _secondaryWeapon = _loadoutData select 1;
    if (count _secondaryWeapon > 0) then {
        _secondaryWeapon = _secondaryWeapon select 0;
        private _secondaryWeaponName = getText (configFile >> "CfgWeapons" >> _secondaryWeapon >> "displayName");
        private _secondaryWeaponNameArray = toArray _secondaryWeaponName;
        {
            if (_x == 160) then {
                _secondaryWeaponNameArray set [_forEachIndex, 32];
            };
        } forEach _secondaryWeaponNameArray;
        _loadoutName pushBack (toString _secondaryWeaponNameArray);
    };

    private _handgun = _loadoutData select 2;
    if (count _handgun > 0) then {
        _handgun = _handgun select 0;
        private _handgunName = getText (configFile >> "CfgWeapons" >> _handgun >> "displayName");
        private _handgunNameArray = toArray _handgunName;
        {
            if (_x == 160) then {
                _handgunNameArray set [_forEachIndex, 32];
            };
        } forEach _handgunNameArray;
        _loadoutName pushBack (toString _handgunNameArray);
    };

    _loadoutName = _loadoutName select { _x != "" };
    _loadoutNames pushBack _loadoutName;
};

_loadoutNames