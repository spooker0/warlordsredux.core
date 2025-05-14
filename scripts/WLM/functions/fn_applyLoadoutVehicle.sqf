#include "..\WLM_constants.inc"

params ["_showWarning"];

private _asset = uiNamespace getVariable "WLM_asset";
private _display = findDisplay WLM_DISPLAY;

private _access = [_asset, player, "full"] call WL2_fnc_accessControl;
if !(_access # 0) exitWith {
    systemChat format ["Can't apply loadout: %1", _access # 1];
    playSound "AddItemFailed";
    _display closeDisplay 1;
};

private _eligibleFreeRearm = [_asset, false] call WLM_fnc_calculateFreeRearmEligibility;

if (_showWarning && !_eligibleFreeRearm) exitWith {
    private _confirmDialog = _display createDisplay "WLM_Modal_Dialog";

    private _titleControl = _confirmDialog displayCtrl WLM_MODAL_TITLE;
    _titleControl ctrlSetText (localize "STR_WLM_PYLON_APPLY_WARNING");

    private _textControl = _confirmDialog displayCtrl WLM_MODAL_TEXT;
    _textControl ctrlSetText (localize "STR_WLM_APPLY_PYLONS_AMMO_WARNING");

    private _confirmButtonControl = _confirmDialog displayCtrl WLM_MODAL_CONFIRM_BUTTON;
    private _cancelButtonContrl = _confirmDialog displayCtrl WLM_MODAL_EXIT_BUTTON;

    _confirmButtonControl ctrlSetText (localize "STR_WLM_APPLY");
    _confirmButtonControl ctrlSetTooltip (localize "STR_WLM_APPLY_SELECTED_PYLONS");

    _cancelButtonContrl ctrlSetTooltip (localize "STR_WLM_RETURN_PREVIOUS_SCREEN");

    _cancelButtonContrl ctrlAddEventHandler ["ButtonClick", {
        (findDisplay WLM_MODAL) closeDisplay 1;
    }];
    _confirmButtonControl ctrlAddEventHandler ["ButtonClick", {
        (findDisplay WLM_MODAL) closeDisplay 1;
        [false] call WLM_fnc_applyLoadoutVehicle;
    }];
};

["TaskModifyVehicle"] call WLT_fnc_taskComplete;

private _magTurretsToRemove = [];
private _turrets = [[-1]] + allTurrets _asset;
{
    private _turretPath = _x;
    private _magazinesTurret = _asset magazinesTurret _turretPath;
    {
        _magTurretsToRemove pushBack [_x, _turretPath];
    } forEach _magazinesTurret;
} forEach _turrets;

private _magTurretsToAdd = [];
private _magazineSelectBoxes = uiNamespace getVariable "WLM_magazineSelectBoxes";
{
    private _selectBox = _x # 0;
    private _turretPath = _x # 1;

    private _currentSelection = lbCurSel _selectBox;
    private _magazineClass = _selectBox lbData _currentSelection;

    if (_magazineClass != "EMPTY") then {
        private _ammoCount = getNumber (configFile >> "CfgMagazines" >> _magazineClass >> "count");
        _magTurretsToAdd pushBack [_magazineClass, _turretPath, _ammoCount];
    };
} forEach _magazineSelectBoxes;

[_asset, _magTurretsToRemove, _magTurretsToAdd, _eligibleFreeRearm] remoteExec ["WLM_fnc_applyVehicle", 0];

[_magazineSelectBoxes, _asset] spawn {
    params ["_magazineSelectBoxes", "_asset"];
    {
        private _successSound = selectRandom ['FD_Target_PopDown_Large_F','FD_Target_PopDown_Small_F','FD_Target_PopUp_Small_F'];
        private _soundPath = getArray (configfile >> "CfgSounds" >> _successSound >> "sound");
        playSound3D [_soundPath # 0, _asset, false, getPosASL _asset, random [1.8, 2.0, 2.2], random [1.8, 2.0, 2.2], 50];
        sleep 0.1;
    } forEach _magazineSelectBoxes;
};

if (_eligibleFreeRearm) then {
    private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];

    private _rearmTime = (missionNamespace getVariable "WL2_rearmTimers") getOrDefault [_assetActualType, 600];
    _asset setVariable ["BIS_WL_nextRearm", serverTime + _rearmTime, true];

    private _loadoutDefaults = profileNamespace getVariable ["WLM_loadoutDefaults", createHashmap];
    _loadoutDefaults set [_assetActualType, _magTurretsToAdd];
    if (count _magTurretsToRemove > 0) then {
        profileNamespace setVariable ["WLM_loadoutDefaults", _loadoutDefaults];
    };

    playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Rearm.wss", _asset, false, getPosASL _asset, 2, 1, 75];
    [toUpper localize "STR_A3_WL_popup_asset_rearmed"] spawn WL2_fnc_smoothText;
} else {
    private _regularRearmTimer = _asset getVariable ["BIS_WL_nextRearm", 0];
    _asset setVariable ["WLM_ineligibleForRearmTimer", _regularRearmTimer, true];
};