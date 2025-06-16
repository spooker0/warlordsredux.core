#include "includes.inc"
params [["_unit", player]];

private _magazinesToRemove = [
	"1Rnd_SmokeRed_Grenade_shell",
	"1Rnd_SmokeGreen_Grenade_shell",
	"1Rnd_SmokeBlue_Grenade_shell",
	"1Rnd_SmokeOrange_Grenade_shell",
	"1Rnd_SmokeYellow_Grenade_shell",
	"1Rnd_Smoke_Grenade_shell",
	"SmokeShellOrange",
	"SmokeShellBlue",
	"SmokeShellYellow",
	"SmokeShellGreen",
	"SmokeShell",
	"SmokeShellRed",
	"Chemlight_green",
	"Chemlight_red",
	"HandGrenade",
	"MiniGrenade"
];

{
	_unit removeMagazines _x;
} forEach _magazinesToRemove;

private _itemsToRemove = [
	"FirstAidKit"
];

{
	_unit removeItems _x;
} forEach _itemsToRemove;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _respawnUavTerminal = _settingsMap getOrDefault ["respawnUavTerminal", true];

switch (side group player) do {
	case west: {
		if (_respawnUavTerminal) then {
			_unit linkItem "B_UavTerminal";
		};
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator";
	};
	case east: {
		if (_respawnUavTerminal) then {
			_unit linkItem "O_UavTerminal";
		};
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator_02";
	};
	case independent: {
		if (_respawnUavTerminal) then {
			_unit linkItem "I_UavTerminal";
		};
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator_03";
	};
};

_unit linkItem "Integrated_NVG_TI_0_F";

private _respawnSmokeGrenades = _settingsMap getOrDefault ["respawnSmokeGrenades", 1];
_unit addMagazines ["SmokeShell", _respawnSmokeGrenades];

private _respawnFragGrenades = _settingsMap getOrDefault ["respawnFragGrenades", 2];
_unit addMagazines ["HandGrenade", _respawnFragGrenades];

_unit addPrimaryWeaponItem "muzzle_snds_H";
_unit addPrimaryWeaponItem "muzzle_snds_M";

private _respawnFirstAidKits = _settingsMap getOrDefault ["respawnFirstAidKits", 3];
switch (_respawnFirstAidKits) do {
	case 0: {
		_unit removeItems "FirstAidKit";
	};
	case 1: {
	};
	case 2: {
		_unit addItem "FirstAidKit";
	};
	case 3: {
		_unit addItem "FirstAidKit";
		_unit addItem "FirstAidKit";
	};
};

_unit setUnitTrait ["loadCoef", 0.8];