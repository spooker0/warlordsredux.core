#include "includes.inc"

private _existingDisplay = findDisplay BADGE_IDD;
if (!isNull _existingDisplay) exitWith {};

private _display = createDialog ["WL2_BadgeMenu", true];
if (isNull _display) exitWith {};

uiNamespace setVariable ["WL2_BadgeMenu", _display];

private _closeControl = _display displayCtrl BADGE_CLOSE_ID;
_closeControl ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    private _display = ctrlParent _control;
    _display closeDisplay 2;
}];

private _badgeConfigs = call RWD_fnc_getBadgeConfigs;
private _badges = missionProfileNamespace getVariable ["WL2_badges", createHashMap];
private _badgeArray = [];
{
    if (_y > 0) then {
        _badgeArray pushBack [_x, _y];
    };
} forEach _badges;

_badgeArray = [_badgeArray, [], { _x # 0 }, "ASCEND"] call BIS_fnc_sortBy;

private _badgeDisplayData = [];
{
    _x params ["_badgeName", "_badgeCount"];

    private _badgeData = _badgeConfigs getOrDefault [_badgeName, []];
    if (_badgeData isEqualTo []) then {
        continue;
    };

    _badgeData params ["_badgeIcon", "_badgeTier", "_badgeDescription"];
    _badgeDisplayData pushBack [_badgeName, _badgeCount, _badgeIcon, _badgeTier, _badgeDescription];
} forEach _badgeArray;

private _emptyControl = _display displayCtrl BADGE_EMPTY_TEXT_ID;
_emptyControl ctrlShow (_badgeDisplayData isEqualTo []);

private _contentGroup = _display displayCtrl BADGE_CONTENT_GROUP_ID;
private _currentBadge = player getVariable ["WL2_currentBadge", "Player"];

private _badgeRows = [];
{
    _x params ["_badgeName", "_badgeCount", "_badgeIcon", "_badgeTier", "_badgeDescription"];

    private _column = _forEachIndex mod BADGE_COLUMNS;
    private _row = floor (_forEachIndex / BADGE_COLUMNS);

    private _cardControl = _display ctrlCreate ["WL2_BadgeMenu_Badge", -1, _contentGroup];
    _cardControl ctrlSetPosition [
        _column * (BADGE_CARD_W + BADGE_COLUMN_GAP),
        _row * (BADGE_CARD_H + BADGE_ROW_GAP),
        BADGE_CARD_W,
        BADGE_CARD_H
    ];
    _cardControl ctrlCommit 0;

    private _backgroundControl = _cardControl controlsGroupCtrl BADGE_CARD_BACKGROUND_ID;
    private _buttonControl = _cardControl controlsGroupCtrl BADGE_CARD_BUTTON_ID;
    private _iconControl = _cardControl controlsGroupCtrl BADGE_CARD_ICON_ID;
    private _nameControl = _cardControl controlsGroupCtrl BADGE_CARD_NAME_ID;
    private _descriptionControl = _cardControl controlsGroupCtrl BADGE_CARD_DESCRIPTION_ID;
    private _countControl = _cardControl controlsGroupCtrl BADGE_CARD_COUNT_ID;
    private _selectedControl = _cardControl controlsGroupCtrl BADGE_CARD_SELECTED_ID;

    _iconControl ctrlSetText _badgeIcon;
    _nameControl ctrlSetText _badgeName;
    _descriptionControl ctrlSetStructuredText parseText format ["<t size='1'>%1</t>", _badgeDescription];
    _descriptionControl ctrlEnable false;
    _countControl ctrlSetText format ["Earned: %1", _badgeCount];

    private _badgeColor = switch (_badgeTier) do {
        case 1: { [BADGE_RGBA_TIER_1] };
        case 2: { [BADGE_RGBA_TIER_2] };
        case 3: { [BADGE_RGBA_TIER_3] };
        default { [BADGE_RGBA_DEFAULT] };
    };
    _nameControl ctrlSetTextColor _badgeColor;

    private _isSelected = _badgeName == _currentBadge;
    _selectedControl ctrlShow _isSelected;

    private _backgroundColor = if (_isSelected) then {
        [BADGE_RGBA_SELECTED_BG]
    } else {
        [BADGE_RGBA_CARD_BG]
    };
    _backgroundControl ctrlSetBackgroundColor _backgroundColor;

    _buttonControl setVariable ["RWD_badgeName", _badgeName];
    _buttonControl ctrlAddEventHandler ["MouseButtonDown", RWD_fnc_badgeMenuSelect];
    _buttonControl ctrlSetTooltip format ["Select %1", _badgeName];

    _badgeRows pushBack [_badgeName, _backgroundControl, _selectedControl];
} forEach _badgeDisplayData;

_display setVariable ["RWD_badgeRows", _badgeRows];