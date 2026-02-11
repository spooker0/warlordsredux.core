#include "includes.inc"
params ["_asset"];

private _assetConfig = configFile >> "CfgVehicles" >> typeOf _asset;
private _pylonConfig = _assetConfig >> "Components" >> "TransportPylonsComponent";
private _pylonsInfo = configProperties [_pylonConfig >> "pylons"];
private _currentAssetPylonInfo = _asset getVariable ["WLM_pylonInfo", getAllPylonsInfo _asset];

{
    private _uiPosition = getArray (_x >> "uiPosition");
    private _selectBox = _display ctrlCreate ["WLM_PylonSelect", WLM_PYLON_START + _forEachIndex];
    private _xPos = _uiPosition # 0;
    private _yPos = _uiPosition # 1;

    // transformation from pylon system (magic)
    _xPos = _xPos + 0.167;
    _yPos = _yPos + 0.225;

    // transformation to grid system
    _xPos = _xPos * 0.745; //+ 0.125;

    private _textWidth = "- EMPTY -" getTextWidth ["PuristaMedium", 0.035];

    // adjust for size
    _xPos = _xPos - _textWidth / 2;

    private _pylonConfigName = configName _x;
    private _currentPylonInfo = _currentAssetPylonInfo select { _pylonConfigName == (_x # 1) } select 0;

    private _emptyId = _selectBox lbAdd (localize "STR_WL_emptyLabel");
    _selectBox lbSetTooltip [_emptyId, _pylonConfigName];
    _selectBox lbSetCurSel 0;

    private _allowedMagazines = _asset getCompatiblePylonMagazines _pylonConfigName;

    private _assetActualType = WL_ASSET_TYPE(_asset);
    private _disallowListForAsset = WL_ASSET(_assetActualType, "disallowMagazines", []);

    private _bannedWords = ["leaflet", "bombcluster"];
    _allowedMagazines = _allowedMagazines select {
        private _mag = _x;
        private _isBannedByWord = false;
        {
            _isBannedByWord = _isBannedByWord || [_x, _mag] call BIS_fnc_inString;
        } forEach _bannedWords;
        private _isDisallowed = _mag in _disallowListForAsset;
        !_isBannedByWord && !_isDisallowed;
    };

    if (count _allowedMagazines == 0) then {
        _selectBox ctrlShow false;
        continue;
    };

    private _allowListForPylon = WL_ASSET(_assetActualType, "allowPylonMagazines", []);
    {
        if (typeName _x == "STRING") then {
            if !(_x in _allowedMagazines) then {
                _allowedMagazines pushBack _x;
            };
        } else {
            private _mag = _x # 0;
            if (_mag in _allowedMagazines) then {
                continue;
            };
            private _allowedPylons = _x # 1;

            if (_pylonConfigName in _allowedPylons) then {
                _allowedMagazines pushBack _mag;
            };
        };
    } forEach _allowListForPylon;

    private _assetAmmoOverrides = WL_ASSET(_assetActualType, "ammoOverrides", []);
    {
        private _magazine = configfile >> "CfgMagazines" >> _x;
        private _ammoType = getText (_magazine >> "ammo");
        private _actualAmmoType = _assetAmmoOverrides select {
            _x # 0 == _ammoType
        };
        if (count _actualAmmoType > 0) then {
            _actualAmmoType = _actualAmmoType # 0;
        };

        private _displayName = if (count _actualAmmoType == 0) then {
            [_x] call WL2_fnc_getMagazineName;
        } else {
            [_x, _actualAmmoType # 1 # 1] call WL2_fnc_getMagazineName;
        };

        private _selectBoxItem = _selectBox lbAdd _displayName;

        _selectBox lbSetTooltip [_selectBoxItem, [_x] call WLM_fnc_getMagazineTooltip];
        _selectBox lbSetData [_selectBoxItem, _x];
    } forEach _allowedMagazines;

    _selectBox ctrlSetPosition [_xPos, _yPos, _textWidth + 0.04, 0.035];
    _selectBox ctrlCommit 0;

    _selectBox lbSortBy ["TEXT"];
    for "_index" from 0 to (lbSize _selectBox - 1) do {
        private _itemData = _selectBox lbData _index;
        if (_itemData == (_currentPylonInfo # 3)) then {
            _selectBox lbSetCurSel _index;
        };
    };

    private _selectUserBox = _display ctrlCreate ["WLM_PylonSelectUser", WLM_PYLON_USER_START + _forEachIndex];
    _selectUserBox ctrlSetPosition [_xPos - 0.035, _yPos];

    if (_currentPylonInfo # 2 isEqualTo [0]) then {
        _selectUserBox ctrlSetText "a3\ui_f\data\IGUI\Cfg\CommandBar\imageGunner_ca.paa";
        _selectUserBox ctrlSetTooltip "Control: Gunner";
    } else {
        _selectUserBox ctrlSetText "a3\ui_f\data\IGUI\Cfg\CommandBar\imageDriver_ca.paa";
        _selectUserBox ctrlSetTooltip "Control: Pilot";
    };

    _selectUserBox ctrlAddEventHandler ["ButtonClick", "_this call WLM_fnc_switchUser"];
    _selectUserBox ctrlCommit 0;
} forEach _pylonsInfo;
