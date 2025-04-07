#include "constants.inc"

params ["_return"];
private _display = findDisplay DEBUG_DISPLAY;
private _execReturn = _display displayCtrl DEBUG_EXEC_RETURN;
_execReturn ctrlSetText format ["%1", _return];