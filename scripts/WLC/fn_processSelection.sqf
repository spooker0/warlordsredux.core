#include "constants.inc"

params ["_data", "_side", "_lastLoadout", "_unit", "_paidFor"];

private _playerFunds = (missionNamespace getVariable "fundsDatabaseClients") get (getPlayerUID player);

private _totalCost = 0;
private _equipment = createHashMap;
{
    private _type = _x;
    if !(_x in ["Uniform", "Vest", "Helmet", "Primary", "Secondary", "Launcher"]) then {
        continue;
    };

    private _customizationData = _y;

    private _customizationMap = missionNamespace getVariable [format ["WLC_%1_%2", _type, _side], createHashMap];
    private _customization = _customizationMap getOrDefault [_customizationData, createHashMap];

    private _item = _customization getOrDefault ["item", ""];

    private _loadoutMains = [];
    if (count _lastLoadout > 0) then {
        {
            _loadoutMains pushBack (_lastLoadout # _x # 0);
        } forEach [0, 1, 2, 3, 4];
        _loadoutMains pushBack (_lastLoadout # 6);
    };

    private _cost = if (_item in _loadoutMains) then {
        0;
    } else {
        _customization getOrDefault ["cost", 0];
    };
    private _level = _customization getOrDefault ["level", 0];
    private _playerLevel = ["getLevel"] call WLC_fnc_getLevelInfo;

    private _custom = +_customization;
    if (_type in ["Primary", "Secondary", "Launcher"]) then {
        private _attachment = _data getOrDefault [_type + "Attachment", ""];
        private _variants = _custom getOrDefault ["variants", createHashMap];
        private _variant = _variants getOrDefault [_attachment, createHashMap];
        private _attachments = _custom getOrDefault ["attachments", []];
        _attachments append (_variant getOrDefault ["attachments", []]);
        _custom set ["attachments", _attachments];
        _cost = _cost + (_variant getOrDefault ["cost", 0]);

        private _ammo = _data getOrDefault [_type + "Ammo", ""];
        private _loadouts = _custom getOrDefault ["loadouts", createHashMap];
        private _loadout = _loadouts getOrDefault [_ammo, createHashMap];
        private _magazines = _custom getOrDefault ["magazines", []];
        _magazines append (_loadout getOrDefault ["magazines", []]);
        _custom set ["magazines", _magazines];

        private _loadoutCost = _loadout getOrDefault ["cost", 0];
        if (_loadoutCost > 0 && count _magazines > 0) then {
            private _lastMagazines = [];
            if (count _lastLoadout > 0) then {
                if (count (_lastLoadout # 1) >= 5) then {
                    private _launcherAmmo = _lastLoadout # 1 # 4;
                    if (count _launcherAmmo > 0) then {
                        _lastMagazines pushBack (_launcherAmmo # 0)
                    };
                };
                {
                    private _storage = _lastLoadout # _x;
                    if (count _storage < 2) then {
                        continue;
                    };
                    {
                        private _item = _x # 0;
                        private _amount = _x # 1;
                        for "_i" from 1 to _amount do {
                            _lastMagazines pushBack _item;
                        };
                    } forEach (_storage # 1);
                } forEach [3, 4, 5];
            };

            private _addMagazines = [];
            private _magazinesToAdd = +_magazines;
            {
                private _magazine = _x;
                private _findIndex = _lastMagazines findIf {
                    _x == _magazine
                };
                if (_findIndex == -1) then {
                    _addMagazines pushBack _magazine;
                } else {
                    _lastMagazines deleteAt _findIndex;
                };
            } forEach _magazinesToAdd;
            private _addedMagazines = count _addMagazines / count _magazines;
            _loadoutCost = round (_loadoutCost * _addedMagazines);
        };

        _cost = _cost + _loadoutCost;
        _level = _level max (_loadout getOrDefault ["level", 0]);
    };

    if (_paidFor) then {
        _cost = 0;
    };

    if (_level <= _playerLevel && _cost >= 0 && _playerFunds >= _cost && _item != "") then {
        [player, "equip", _cost] remoteExec ["WL2_fnc_handleClientRequest", 2];
        _totalCost = _totalCost + _cost;
        _equipment set [_type, _custom];
    };
} forEach _data;

// Backpacks to use
private _backpacks = if (BIS_WL_playerSide == west) then {
    [
        "B_AssaultPack_mcamo",
        "B_FieldPack_cbr",
        "B_TacticalPack_mcamo",
        "B_Kitbag_mcamo",
        "B_Carryall_mcamo",
        "B_Bergen_mcamo_F"
    ];
} else {
    [
        "B_AssaultPack_ocamo",
        "B_FieldPack_ocamo",
        "B_TacticalPack_ocamo",
        "B_Kitbag_tan",
        "B_Carryall_ocamo",
        "B_Bergen_hex_F"
    ];
};

private _largestBackpack = _backpacks # (count _backpacks - 1);
_unit addBackpack _largestBackpack;

private _itemsToAdd = [];

_itemsToAdd append (items _unit);

// Primary
private _primary = _equipment getOrDefault ["Primary", createHashMap];
private _primaryWeapon = _primary getOrDefault ["item", ""];
private _primaryMagazines = _primary getOrDefault ["magazines", []];
private _primaryAttachments = _primary getOrDefault ["attachments", []];

if (_primaryWeapon != "") then {
    {
        _unit removeMagazines _x;
    } forEach (compatibleMagazines (primaryWeapon _unit));
    _unit removeWeapon (primaryWeapon _unit);

    if (count _primaryMagazines > 0) then {
        private _firstMag = _primaryMagazines # 0;
        _unit addMagazine _firstMag;

        _unit addWeapon _primaryWeapon;
        _primaryMagazines deleteAt 0;

        {
            _itemsToAdd pushBack _x;
        } forEach _primaryMagazines;
    } else {
        _unit addWeapon _primaryWeapon;
    };

    {
        _unit addPrimaryWeaponItem _x;
    } forEach _primaryAttachments;
} else {
    private _compatibleMagazines = compatibleMagazines (primaryWeapon _unit);
    {
        if (_x in _compatibleMagazines) then {
            _itemsToAdd pushBack _x;
        };
    } forEach (itemsWithMagazines _unit);
};

// Secondary
private _secondary = _equipment getOrDefault ["Secondary", createHashMap];
private _secondaryWeapon = _secondary getOrDefault ["item", ""];
private _secondaryMagazines = _secondary getOrDefault ["magazines", []];
private _secondaryAttachments = _secondary getOrDefault ["attachments", []];

if (_secondaryWeapon != "") then {
    {
        _unit removeMagazines _x;
    } forEach (compatibleMagazines (handgunWeapon _unit));
    _unit removeWeapon (handgunWeapon _unit);

    if (_secondaryWeapon != "none") then {
        if (count _secondaryMagazines > 0) then {
            private _firstMag = _secondaryMagazines # 0;
            _unit addMagazine _firstMag;

            _unit addWeapon _secondaryWeapon;
            _secondaryMagazines deleteAt 0;
            {
                _itemsToAdd pushBack _x;
            } forEach _secondaryMagazines;
        } else {
            _unit addWeapon _secondaryWeapon;
        };

        {
            _unit addHandgunItem _x;
        } forEach _secondaryAttachments;
    };
} else {
    private _compatibleMagazines = compatibleMagazines (handgunWeapon _unit);
    {
        if (_x in _compatibleMagazines) then {
            _itemsToAdd pushBack _x;
        };
    } forEach (itemsWithMagazines _unit);
};

// Launcher
private _launcher = _equipment getOrDefault ["Launcher", createHashMap];
private _launcherWeapon = _launcher getOrDefault ["item", ""];
private _launcherMagazines = _launcher getOrDefault ["magazines", []];

if (_launcherWeapon != "") then {
    {
        _unit removeMagazines _x;
    } forEach (compatibleMagazines (secondaryWeapon _unit));
    _unit removeWeapon (secondaryWeapon _unit);

    if (count _launcherMagazines > 0) then {
        private _firstMag = _launcherMagazines # 0;
        _unit addMagazine _firstMag;
        _unit addWeapon _launcherWeapon;

        _launcherMagazines deleteAt 0;
        {
            _itemsToAdd pushBack _x;
        } forEach _launcherMagazines;
    } else {
        _unit addWeapon _launcherWeapon;
    };
} else {
    private _compatibleMagazines = compatibleMagazines (secondaryWeapon _unit);
    {
        if (_x in _compatibleMagazines) then {
            _itemsToAdd pushBack _x;
        };
    } forEach (itemsWithMagazines _unit);
};

// Uniform
private _uniform = _equipment getOrDefault ["Uniform", createHashMap];
private _uniformItem = _uniform getOrDefault ["item", uniform _unit];
removeUniform _unit;
_unit forceAddUniform _uniformItem;

// Vest
private _vest = _equipment getOrDefault ["Vest", createHashMap];
private _vestItem = _vest getOrDefault ["item", vest _unit];
removeVest _unit;
_unit addVest _vestItem;

// Helmet
private _helmet = _equipment getOrDefault ["Helmet", createHashMap];
private _helmetItem = _helmet getOrDefault ["item", headgear _unit];
removeHeadgear _unit;
_unit addHeadgear _helmetItem;

// Finish loading
private _addItemInOrder = {
    params ["_item"];
    private _canAddToUniform = _unit canAddItemToUniform [_item, 1, true];
    if (_canAddToUniform) exitWith {
        _unit addItemToUniform _item;
        true;
    };

    private _canAddToVest = _unit canAddItemToVest [_item, 1, true];
    if (_canAddToVest) exitWith {
        _unit addItemToVest _item;
        true;
    };

    private _canAddToBackpack = _unit canAddItemToBackpack [_item, 1, true];
    if (_canAddToBackpack) exitWith {
        _unit addItemToBackpack _item;
        true;
    };

    false;
};

private _clearItems = {
    private _vestItems = vestItems _unit;
    private _uniformItems = uniformItems _unit;
    {
        _unit removeItemFromVest _x;
    } forEach _vestItems;
    {
        _unit removeItemFromUniform _x;
    } forEach _uniformItems;
};

private _addItems = {
    params ["_toAdd"];
    private _backpackToUse = _backpacks # 0;
    private _success = false;
    {
        call _clearItems;
        removeBackpack _unit;
        _unit addBackpack _x;
        private _allSuccess = true;
        {
            private _success = [_x] call _addItemInOrder;
            if (!_success) then {
                _allSuccess = false;
            };
        } forEach _toAdd;
        _backpackToUse = _x;
        if (_allSuccess) then {
            _success = true;
            break;
        };
    } forEach _backpacks;

    if (!_success) then {
        systemChat "Some items were not added due to player inventory full.";
    };
};

[_itemsToAdd] call _addItems;
_unit selectWeapon _primaryWeapon;
reload _unit;

if (count (backpackItems _unit) == 0) then {
    removeBackpack _unit;
};

private _message = if (_totalCost > 0) then {
    private _moneySign = [_side] call WL2_fnc_getMoneySign;
    format ["Equipment and customizations applied for %1%2.", _moneySign, _totalCost];
} else {
     "Equipment and customizations applied for free.";
};
systemChat _message;