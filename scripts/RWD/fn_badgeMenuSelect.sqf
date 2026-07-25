#include "includes.inc"
params ["_control"];
if (isNull _control) exitWith {};

private _badgeName = _control getVariable ["RWD_badgeName", ""];
if (_badgeName == "") exitWith {};

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
[_badgeName] call RWD_fnc_applyBadge;

private _badgeRows = _display getVariable ["RWD_badgeRows", []];
{
    _x params ["_rowBadgeName", "_backgroundControl", "_selectedControl"];

    private _isSelected = _rowBadgeName == _badgeName;
    if (!isNull _selectedControl) then {
        _selectedControl ctrlShow _isSelected;
    };

    if (!isNull _backgroundControl) then {
        private _backgroundColor = if (_isSelected) then {
            [BADGE_RGBA_SELECTED_BG]
        } else {
            [BADGE_RGBA_CARD_BG]
        };
        _backgroundControl ctrlSetBackgroundColor _backgroundColor;
    };
} forEach _badgeRows;