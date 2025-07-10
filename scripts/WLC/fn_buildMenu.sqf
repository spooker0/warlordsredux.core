#include "includes.inc"
private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\loadout.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];

    private _firstLetter = _message select [0, 1];

    if (_firstLetter == "l") exitWith {
        private _newLoadoutIndex = _message select [1, 1];
        _newLoadoutIndex = parseNumber _newLoadoutIndex;

        private _loadoutIndexVar = format ["WLC_loadoutIndex_%1", BIS_WL_playerSide];
        profileNamespace setVariable [_loadoutIndexVar, _newLoadoutIndex];

        [_texture] call WLC_fnc_pageLoad;
    };

    if (_firstLetter == "r") exitWith {
        private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];
        for "_i" from 0 to 9 do {
            private _loadoutVar = format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _i];
            profileNamespace setVariable [_loadoutVar, []];
        };
        systemChat "All loadouts reset.";
        closeDialog 0;
    };

    if (_firstLetter == "c") exitWith {
        private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];
        private _loadoutVar = format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _loadoutIndex];
        private _loadout = getUnitLoadout player;
        profileNamespace setVariable [_loadoutVar, _loadout];
        systemChat "Loadout copied.";
        [_texture] call WLC_fnc_pageLoad;
    };

    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

    private _loadoutIndex = profileNamespace getVariable [format ["WLC_loadoutIndex_%1", BIS_WL_playerSide], 0];
    private _responseArray = fromJSON _message;
    profileNamespace setVariable [format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _loadoutIndex], _responseArray];
}];

_texture ctrlAddEventHandler ["PageLoaded", WLC_fnc_pageLoad];

[_texture] spawn {
    params ["_texture"];
    while { !isNull _texture } do {
        sleep 0.2;
    };

    ["LOADOUT SAVED FOR NEXT RESPAWN"] spawn WL2_fnc_smoothText;
    systemChat "Loadout saved for next respawn.";
};