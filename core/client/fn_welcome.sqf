#include "includes.inc"
"RequestMenu_close" call WL2_fnc_setupUI;

private _display = findDisplay 5000;
if (isNull _display) then {
    _display = (findDisplay 46) createDisplay "RscWLSquadMenu";
};
private _texture = _display displayCtrl 5001;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\welcome.html"];