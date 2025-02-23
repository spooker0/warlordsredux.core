params [["_unit", player]];

private _magazineTypes = [
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
	"Chemlight_red"
];

{
	_unit removeMagazines _x;
} forEach _magazineTypes;

switch (side group player) do {
	case west: {
		_unit linkItem "B_UavTerminal";
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator";
	};
	case east: {
		_unit linkItem "O_UavTerminal";
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator_02";
	};
	case independent: {
		_unit linkItem "I_UavTerminal";
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator_03";
	};
};

{
	_unit removeMagazines _x;
} forEach _magazineTypes;

_unit linkItem "Integrated_NVG_TI_0_F";
_unit addPrimaryWeaponItem "muzzle_snds_H";
_unit addPrimaryWeaponItem "muzzle_snds_M";
_unit addMagazines ["SmokeShell", 1];
_unit addItem "FirstAidKit";
_unit addItem "FirstAidKit";