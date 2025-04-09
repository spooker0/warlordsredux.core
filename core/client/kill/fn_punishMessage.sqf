params ["_offenderName", "_reason"];

if (isDedicated) exitWith {};

private _message = format ["%1 has been temporarily kicked/blocked from the game for %2.", _offenderName, _reason];
systemChat _message;