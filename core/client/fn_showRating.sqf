#include "includes.inc"
params ["_player", "_rating"];
if (isDedicated) exitWith {};
private _message = format ["%1 requested their ELO: %2", name _player, _rating];
systemChat _message;