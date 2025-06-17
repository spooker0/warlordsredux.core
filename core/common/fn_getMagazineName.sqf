#include "includes.inc"
params ["_magazine"];

private _menuTextOverrides = call WLM_fnc_menuTextOverrides;

if (_magazine == "EMPTY") exitWith {
    "EMPTY";
};

private _magazineName = getText (configFile >> "CfgMagazines" >> _magazine >> "displayName");
if (_magazineName == "") then {
    private _weaponName = getText (configFile >> "CfgWeapons" >> _magazine >> "displayName");
    if (_weaponName == "") then {
        _magazineName = _magazine;
    } else {
        _magazineName = _weaponName;
    };
};

private _overrideMagazineName = (_menuTextOverrides # 0) getOrDefault [_magazine, "No Override"];
if (_overrideMagazineName != "No Override") then {
    _magazineName = _overrideMagazineName;
};

private _magSize = getNumber (configFile >> "CfgMagazines" >> _magazine >> "count");
if (_magSize > 1) then {
    _magazineName = format ["%1 (%2)", _magazineName, _magSize];
};

_magazineName;