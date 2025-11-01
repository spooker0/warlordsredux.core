#include "includes.inc"
params [["_unit", player]];

switch (side group player) do {
	case west: {
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator";
		_unit removeItem "B_UAVTerminal";
	};
	case east: {
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator_02";
		_unit removeItem "O_UAVTerminal";
	};
	case independent: {
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator_03";
	};
};

_unit linkItem "Integrated_NVG_TI_0_F";
_unit setUnitTrait ["loadCoef", 0.6];
_unit setStamina 100;