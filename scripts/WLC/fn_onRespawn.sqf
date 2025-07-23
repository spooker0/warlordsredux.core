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

private _sanityChecks = {
    params ["_unit"];

    if (loadBackpack _unit > 1) exitWith {
        format ["Backpack items exceed weight capacity: %1", loadBackpack _unit];
    };
    if (loadVest _unit > 1) exitWith {
        format ["Vest items exceed weight capacity: %1", loadVest _unit];
    };
    if (loadUniform _unit > 1) exitWith {
        format ["Uniform items exceed weight capacity: %1", loadUniform _unit];
    };

    private _primaryCompatibleMagazines = compatibleMagazines (primaryWeapon _unit);
    private _primaryMagazines = primaryWeaponMagazine _unit;
    private _invalidMagazines = false;
    {
        private _magazine = _x;
        if !(_magazine in _primaryCompatibleMagazines) then {
            _invalidMagazines = true;
            break;
        };
    } forEach _primaryMagazines;

    private _secondaryCompatibleMagazines = compatibleMagazines (secondaryWeapon _unit);
    private _secondaryMagazines = secondaryWeaponMagazine _unit;
    {
        private _magazine = _x;
        if !(_magazine in _secondaryCompatibleMagazines) then {
            _invalidMagazines = true;
            break;
        };
    } forEach _secondaryMagazines;

    private _handgunCompatibleMagazines = compatibleMagazines (handgunWeapon _unit);
    private _handgunMagazines = handgunMagazine _unit;
    {
        private _magazine = _x;
        if !(_magazine in _handgunCompatibleMagazines) then {
            _invalidMagazines = true;
            break;
        };
    } forEach _handgunMagazines;

    if (_invalidMagazines) exitWith {
        "Invalid magazines detected.";
    };

    private _playerSide = str BIS_WL_playerSide;

    private _validUniforms = getArray (missionConfigFile >> "arsenalConfig" >> _playerSide >> "Uniforms");
    if !(uniform _unit in _validUniforms) exitWith {
        format ["Invalid uniform: %1", uniform _unit];
    };

    private _validVests = getArray (missionConfigFile >> "arsenalConfig" >> _playerSide >> "Vests");
    if !(vest _unit in _validVests) exitWith {
        format ["Invalid vest: %1", vest _unit];
    };

    private _validBackpacks = getArray (missionConfigFile >> "arsenalConfig" >> _playerSide >> "Backpacks");
    if !(backpack _unit in _validBackpacks) exitWith {
        format ["Invalid backpack: %1", backpack _unit];
    };

    "";
};

private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];
private _customizationLoadout = profileNamespace getVariable [format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _loadoutIndex], []];
if (count _customizationLoadout > 0) then {
    private _lastLoadout = WL2_lastLoadout;
    private _rocketCountBefore = if (count _lastLoadout > 0) then {
        [_lastLoadout] call _countRockets
    } else {
        0
    };

    private _rocketCountAfter = [_customizationLoadout] call _countRockets;
    private _rocketDifference = (_rocketCountAfter - _rocketCountBefore) max 0;

    private _totalCost = if (_paidFor) then {
        0;
    } else {
        _rocketDifference * 50;
    };

    private _playerFunds = (missionNamespace getVariable ["fundsDatabaseClients", createHashMap]) getOrDefault [getPlayerUID player, 0];
    if (_totalCost <= _playerFunds) then {
        _unit setUnitLoadout _customizationLoadout;

        // sanity checks
        private _sanityCheckResult = [_unit] call _sanityChecks;
        if (_sanityCheckResult != "") then {
            _unit setUnitLoadout _lastLoadout;
            systemChat _sanityCheckResult;
        } else {
            [player, "equip", _totalCost] remoteExec ["WL2_fnc_handleClientRequest", 2];

            private _message = if (_totalCost > 0) then {
                private _moneySign = [BIS_WL_playerSide] call WL2_fnc_getMoneySign;
                format ["Equipment and customizations applied for %1%2.", _moneySign, _totalCost];
            } else {
                "Equipment and customizations applied for free.";
            };
            systemChat _message;
        };
    };
} else {
    0 spawn WLC_fnc_buildMenu;
};

_unit enableStamina false;
[_unit] spawn {
    params ["_unit"];
    sleep 3;
    _unit enableStamina true;
};