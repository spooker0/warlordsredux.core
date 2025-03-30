params ["_teamkillerName"];

if (isDedicated) exitWith {};

private _message = format ["%1 has been temporarily kicked/blocked from the game for teamkilling.", _teamkillerName];
systemChat _message;