#include "includes.inc"

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\spectate.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

uiNamespace setVariable ["SPEC_CameraMoveRight", 0];
uiNamespace setVariable ["SPEC_CameraMoveLeft", 0];
uiNamespace setVariable ["SPEC_CameraMoveForward", 0];
uiNamespace setVariable ["SPEC_CameraMoveBackward", 0];
uiNamespace setVariable ["SPEC_CameraMoveUp", 0];
uiNamespace setVariable ["SPEC_CameraMoveDown", 0];

_texture ctrlAddEventHandler ["PageLoaded", {
    _this spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            private _objectMap = createHashMap;
            private _players = (allUnits + allDeadMen) select { simulationEnabled _x };

            private _playerData = _players apply {
                private _vehicle = vehicle _x;
                private _vehicleName = if (_vehicle != _x) then {
                    [_vehicle] call WL2_fnc_getAssetTypeName;
                } else {
                    "";
                };
                [name _x, [side group _x, false] call WL2_fnc_sideToFaction, getObjectID _x, _vehicleName, _x]
            };

            private _munitions = (8 allObjects 2) select {
                private _munition = _x;
                private _foundValid = false;
                {
                    if (_munition isKindOf _x) then {
                        _foundValid = true;
                        break;
                    };
                } forEach [
                    "MissileCore",
                    "RocketCore",
                    "BombCore",
                    "ShellCore",
                    "SubmunitionCore"
                ];
                _foundValid
            };
            _munitions = _munitions apply {
                private _shotParents = getShotParents _x;
                private _vehicle = _shotParents # 0;
                private _instigator = _shotParents call WL2_fnc_handleInstigator;
                private _vehicleName = format ["%1 (%2)", [_vehicle] call WL2_fnc_getAssetTypeName, name _instigator];

                [typeof _x, "MUNITION", getObjectID _x, _vehicleName, _x]
            };

            private _sectors = BIS_WL_allSectors apply {
                private _sectorName = _x getVariable ["WL2_name", "Sector"];
                [_sectorName, "SECTOR", getObjectID _x, "", _x]
            };

            _playerData append _munitions;
            _playerData append _sectors;

            {
                _objectMap set [_x select 2, _x select 4];
            } forEach _playerData;
            uiNamespace setVariable ["SPEC_SpectateObjectMap", _objectMap];

            private _playerDataJson = toJSON _playerData;
            _playerDataJson = _texture ctrlWebBrowserAction ["ToBase64", _playerDataJson];

            private _script = format ["updatePlayerList(atobr(""%1""));", _playerDataJson];
            _texture ctrlWebBrowserAction ["ExecJS", _script];

            uiSleep 0.5;
        };
    };
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_control", "_isConfirmDialog", "_message"];
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    private _objectId = _message;
    private _objectMap = uiNamespace getVariable ["SPEC_SpectateObjectMap", createHashMap];
    private _newTarget = _objectMap getOrDefault [_objectId, objNull];
    if (!isNull _newTarget) then {
        [_newTarget] call SPEC_fnc_spectatorSelectTarget;
    };

    closeDialog 0;

    true;
}];