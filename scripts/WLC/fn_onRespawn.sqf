#include "includes.inc"
params [["_unit", player], ["_paidFor", false]];

private _countRockets = {
    params ["_loadout"];

    private _rocketCount = 0;

    if (count (_loadout # 1) > 0) then {
        // in tube
        if (count (_loadout # 1 # 4) > 0) then {
            _rocketCount = _rocketCount + 1;
        };
    };

    if (count (_loadout # 2) > 0) then {
        // in vest
        private _vestMagazines = _loadout # 4 # 1;
        {
            private _magazine = _x;
            private _magazineType = _magazine # 0;
            private _magazineCount = _magazine # 1;

            private _magazineMass = getNumber (configFile >> "CfgMagazines" >> _magazineType >> "mass");
            if (_magazineMass < 40) then {
                continue;
            };

            _rocketCount = _rocketCount + _magazineCount;
        } forEach _vestMagazines;
    };

    // in backpack
    if (count (_loadout # 5) > 0) then {
        private _backpackMagazines = _loadout # 5 # 1;
        {
            private _magazine = _x;
            private _magazineType = _magazine # 0;
            private _magazineCount = _magazine # 1;

            private _magazineMass = getNumber (configFile >> "CfgMagazines" >> _magazineType >> "mass");
            if (_magazineMass < 40) then {
                continue;
            };

            _rocketCount = _rocketCount + _magazineCount;
        } forEach _backpackMagazines;
    };

    _rocketCount
};

private _customizationLoadout = profileNamespace getVariable [format ["WLC_savedLoadout_%1", BIS_WL_playerSide], []];
if (count _customizationLoadout > 0) then {
    private _lastLoadout = BIS_WL_lastLoadout;
    private _rocketCountBefore = if (count _lastLoadout > 0) then {
        [_lastLoadout] call _countRockets
    } else {
        0
    };

    private _rocketCountAfter = [_customizationLoadout] call _countRockets;
    private _rocketDifference = (_rocketCountAfter - _rocketCountBefore) max 0;

    if (!_paidFor) then {
        private _totalCost = _rocketDifference * 50;
        [player, "equip", _totalCost] remoteExec ["WL2_fnc_handleClientRequest", 2];

        private _message = if (_totalCost > 0) then {
            private _moneySign = [BIS_WL_playerSide] call WL2_fnc_getMoneySign;
            format ["Equipment and customizations applied for %1%2.", _moneySign, _totalCost];
        } else {
            "Equipment and customizations applied for free.";
        };
        systemChat _message;
    };

	_unit setUnitLoadout _customizationLoadout;

    _unit enableStamina false;
    [_unit] spawn {
        params ["_unit"];
        sleep 3;
        _unit enableStamina true;
    };
} else {
    0 spawn WLC_fnc_buildMenu;
};