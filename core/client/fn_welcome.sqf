#include "includes.inc"
"RequestMenu_close" call WL2_fnc_setupUI;

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\welcome.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];