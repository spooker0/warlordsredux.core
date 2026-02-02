#include "includes.inc"
params [["_unit", player]];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _spawnWithUAVTerminal = _settingsMap getOrDefault ["spawnWithUAVTerminal", true];

switch (side group _unit) do {
	case west: {
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator";
		if (_spawnWithUAVTerminal) then {
			_unit linkItem "B_UAVTerminal";
		} else {
			_unit unlinkItem "B_UAVTerminal";
			_unit linkItem "ItemGPS";
		};
	};
	case east: {
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator_02";
		if (_spawnWithUAVTerminal) then {
			_unit linkItem "O_UAVTerminal";
		} else {
			_unit unlinkItem "O_UAVTerminal";
			_unit linkItem "ItemGPS";
		};
	};
	case independent: {
		_unit addMagazineGlobal "Laserbatteries";
		_unit addWeaponGlobal "Laserdesignator_03";
	};
};

_unit linkItem "Integrated_NVG_TI_0_F";
_unit setUnitTrait ["loadCoef", 0.6];
_unit setUnitTrait ["explosiveSpecialist", true];
_unit setStamina 100;