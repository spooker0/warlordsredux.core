#include "includes.inc"

disableSerialization;

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (isNull _display) exitWith {};

private _categories = _display displayCtrl BUY_CATEGORY_IDC;
private _storedQuery = _display getVariable ["BUY_query", ""];
if (_storedQuery != "") exitWith {
    private _tooltip = format ["%1 (%2)", localize "STR_WL_buySearchResults", count (_display getVariable ["BUY_rows", []])];
    private _storedSearchTooltip = _display getVariable ["BUY_searchTooltip", ""];
    if (_tooltip != _storedSearchTooltip) then {
        _categories lbSetTooltip [0, _tooltip];
        _display setVariable ["BUY_searchTooltip", _tooltip];
    };
};

private _infantryRow = -1;
for "_row" from 0 to (lbSize _categories - 1) do {
    if (_categories lbValue _row == 0) exitWith {
        _infantryRow = _row;
    };
};

if (_infantryRow < 0) exitWith {};

private _maxSubordinates = missionNamespace getVariable [format ["BIS_WL_maxSubordinates_%1", BIS_WL_playerSide], 1];
private _timerKey = format ["WL2_manpowerRefreshTimers_%1", getPlayerUID player];
private _timers = missionNamespace getVariable [_timerKey, []];
private _slots = [];
{
    _x params ["_readyTime", "_unit"];

    if (alive _unit) then {
        private _remaining = _readyTime - serverTime;
        private _timerText = if (_remaining < 0) then { "Ready" } else { [_remaining, "MM:SS"] call BIS_fnc_secondsToString };

        _slots pushBack format ["%1 (%2)", name _unit, _timerText];
    };

} forEach _timers;

{
    _x params ["_readyTime", "_unit"];

    if (!alive _unit && _readyTime > serverTime) then {
        _slots pushBack format ["Waiting (%1)", [_readyTime - serverTime, "MM:SS"] call BIS_fnc_secondsToString];
    };

} forEach _timers;

for "_slot" from 1 to (_maxSubordinates - count _slots) do {
    _slots pushBack "Ready";
};

private _tooltip = format ["Subordinates (Max: %1)\n%2", _maxSubordinates, _slots joinString ", "];
private _storedInfantryTooltip = _display getVariable ["BUY_infantryTooltip", ""];
if (_tooltip != _storedInfantryTooltip) then {
    _categories lbSetTooltip [_infantryRow, _tooltip];
    _display setVariable ["BUY_infantryTooltip", _tooltip];
};
