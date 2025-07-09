#include "includes.inc"
params [["_unit", player]];

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

_unit linkItem "Integrated_NVG_TI_0_F";

_unit addPrimaryWeaponItem "muzzle_snds_H";
_unit addPrimaryWeaponItem "muzzle_snds_M";
_unit setUnitTrait ["loadCoef", 0.6];
_unit setStamina 100;