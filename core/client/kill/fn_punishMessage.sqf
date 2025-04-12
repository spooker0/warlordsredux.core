params ["_offenderName", "_timeout", "_reason"];

if (isDedicated) exitWith {};

private _message = format ["%1 has been temporarily kicked/blocked from the game for %2. Reason: %3.", _offenderName, _timeout, _reason];
systemChat _message;