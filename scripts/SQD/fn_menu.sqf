#include "includes.inc"

private _display = findDisplay 5000;
if (isNull _display) then {
    _display = (findDisplay 46) createDisplay "RscWLSquadMenu";
};
private _texture = _display displayCtrl 5001;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_control", "_isConfirmDialog", "_message"];
    private _params = fromJSON _message;
    _params spawn SQD_fnc_client;
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    [_texture] spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            [_texture] call SQD_fnc_sendData;
            sleep 5;
        };
    };
}];