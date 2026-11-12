#include "includes.inc"
params ["_display"];
if (isNull _display) exitWith {};

private _oldControls = _display getVariable ["SPEC_targetControls", []];

{
    if (!isNull _x) then {
        ctrlDelete _x;
    };
} forEach _oldControls;

private _targetData = _display getVariable ["SPEC_targetData", []];

private _contentGroup = _display displayCtrl SPEC_TARGET_CONTENT_GROUP_ID;
if (isNull _contentGroup) exitWith {};

private _createdControls = [];
private _searchRows = [];

private _currentY = 0;
private _previousCategory = "";
private _categoryColumn = 0;

{
    _x params ["_category", "_primaryText", "_secondaryText", "_target", "_objectId"];

    if (_category != _previousCategory) then {
        if (_categoryColumn > 0) then {
            _currentY = _currentY + SPEC_TARGET_CARD_H + SPEC_TARGET_ROW_GAP;
            _categoryColumn = 0;
        };

        private _categoryControl = _display ctrlCreate ["SPEC_TargetMenu_Category", -1, _contentGroup];
        _categoryControl ctrlSetPosition [0, _currentY, SPEC_TARGET_CATEGORY_W, SPEC_TARGET_CATEGORY_H];
        _categoryControl ctrlCommit 0;

        private _categoryBackground = _categoryControl controlsGroupCtrl SPEC_TARGET_CATEGORY_BACKGROUND_ID;
        private _categoryTextControl = _categoryControl controlsGroupCtrl SPEC_TARGET_CATEGORY_TEXT_ID;

        private _categoryDisplayName = switch (_category) do {
            case "BLUFOR": { "BLUFOR" };
            case "OPFOR": { "OPFOR" };
            case "INDFOR": { "INDFOR" };
            case "MUNITION": { localize "STR_WL_spectatorMunitions" };
            default { _category };
        };

        private _categoryColor = switch (_category) do {
            case "BLUFOR": { [SPEC_TARGET_RGBA_BLUFOR] };
            case "OPFOR": { [SPEC_TARGET_RGBA_OPFOR] };
            case "INDFOR": { [SPEC_TARGET_RGBA_INDFOR] };
            case "MUNITION": { [SPEC_TARGET_RGBA_MUNITION] };
            default { [SPEC_TARGET_RGBA_HEADER] };
        };

        _categoryTextControl ctrlSetText _categoryDisplayName;
        _categoryBackground ctrlSetBackgroundColor _categoryColor;

        _createdControls pushBack _categoryControl;
        _searchRows pushBack [_categoryControl, "category", "", _category];

        _currentY = _currentY + SPEC_TARGET_CATEGORY_H + SPEC_TARGET_ROW_GAP;
        _previousCategory = _category;
    };

    private _column = _categoryColumn mod SPEC_TARGET_COLUMNS;

    private _cardControl = _display ctrlCreate ["SPEC_TargetMenu_Card", -1, _contentGroup];
    _cardControl ctrlSetPosition [_column * (SPEC_TARGET_CARD_W + SPEC_TARGET_COLUMN_GAP), _currentY, SPEC_TARGET_CARD_W, SPEC_TARGET_CARD_H];
    _cardControl ctrlCommit 0;

    private _primaryControl = _cardControl controlsGroupCtrl SPEC_TARGET_CARD_PRIMARY_TEXT_ID;
    private _secondaryControl = _cardControl controlsGroupCtrl SPEC_TARGET_CARD_SECONDARY_TEXT_ID;
    private _buttonControl = _cardControl controlsGroupCtrl SPEC_TARGET_CARD_BUTTON_ID;

    _primaryControl ctrlSetText _primaryText;

    private _secondaryFormat = if (_category == "MUNITION") then {
        localize "STR_WL_spectatorTargetLauncher"
    } else {
        localize "STR_WL_spectatorTargetOwner"
    };

    _secondaryControl ctrlSetText format [_secondaryFormat, _secondaryText];

    _buttonControl setVariable ["SPEC_target", _target];
    _buttonControl setVariable ["SPEC_targetObjectId", _objectId];

    _buttonControl ctrlSetTooltip format [localize "STR_WL_spectatorSpectateTarget", _primaryText];
    _buttonControl ctrlAddEventHandler ["ButtonClick", SPEC_fnc_spectatorTargetMenuSelect];

    private _searchText = toLower format ["%1 %2", _primaryText, _secondaryText];
    _createdControls pushBack _cardControl;
    _searchRows pushBack [_cardControl, "target", _searchText, _category];

    _categoryColumn = _categoryColumn + 1;

    if (_categoryColumn mod SPEC_TARGET_COLUMNS == 0) then {
        _currentY = _currentY + SPEC_TARGET_CARD_H + SPEC_TARGET_ROW_GAP;
        _categoryColumn = 0;
    };
} forEach _targetData;

_display setVariable ["SPEC_targetControls", _createdControls];
_display setVariable ["SPEC_targetSearchRows", _searchRows];

private _searchControl = _display displayCtrl SPEC_TARGET_SEARCH_ID;
[_searchControl] call SPEC_fnc_spectatorTargetMenuSearch;