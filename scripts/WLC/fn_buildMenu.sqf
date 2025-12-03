#include "includes.inc"
private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};

private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\loadout.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];

    private _firstLetter = _message select [0, 1];

    if (_firstLetter == "l") exitWith {
        private _newLoadoutIndex = _message select [1];
        _newLoadoutIndex = parseNumber _newLoadoutIndex;

        private _loadoutIndexVar = format ["WLC_loadoutIndex_%1", BIS_WL_playerSide];
        profileNamespace setVariable [_loadoutIndexVar, _newLoadoutIndex];

        [_texture] call WLC_fnc_pageLoad;
    };

    if (_firstLetter == "r") exitWith {
        private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];
        for "_i" from 0 to 30 do {
            private _loadoutVar = format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _i];
            profileNamespace setVariable [_loadoutVar, []];
        };
        ["All loadouts reset."] call WL2_fnc_smoothText;
        closeDialog 0;
    };

    if (_firstLetter == "c") exitWith {
        private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];
        private _loadoutVar = format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _loadoutIndex];
        profileNamespace setVariable [_loadoutVar, []];

        private _script = format ["updateLoadoutNames(%1)", [_texture] call WLC_fnc_getLoadoutNames];
        _texture ctrlWebBrowserAction ["ExecJS", _script];

        true;
    };

    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

    private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];
    private _responseArray = fromJSON _message;
    profileNamespace setVariable [format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _loadoutIndex], _responseArray];

    private _dummy = createVehicleLocal [typeof player, [0, 0, 0], [], 0, "NONE"];
    _dummy setUnitLoadout _responseArray;
    private _weight = loadAbs _dummy;
    private _maxLoad = maxLoad _dummy;
    deleteVehicle _dummy;

    private _script = format [
        "updateLoadoutNames(%1);updateWeight(%2, %3);",
        [_texture] call WLC_fnc_getLoadoutNames,
        _weight,
        _maxLoad
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", WLC_fnc_pageLoad];

[_texture] spawn {
    params ["_texture"];
    while { !isNull _texture } do {
        uiSleep 0.2;
    };

    ["Loadout saved for next respawn"] call WL2_fnc_smoothText;
};