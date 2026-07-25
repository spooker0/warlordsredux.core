#include "includes.inc"
params ["_searchControl"];
if (isNull _searchControl) exitWith {};

private _display = ctrlParent _searchControl;
if (isNull _display) exitWith {};

private _query = toLower ctrlText _searchControl;
private _searchRows = _display getVariable ["SPEC_targetSearchRows", []];

private _categoryMatches = createHashMap;

{
    _x params ["", "_rowType", "_searchText", "_category"];
    if (_rowType == "target" && (_query == "" || _query in _searchText)) then {
        _categoryMatches set [_category, true];
    };
} forEach _searchRows;

private _currentY = 0;
private _currentCategory = "";
private _currentColumn = 0;
private _visibleTargetCount = 0;

{
    _x params ["_control", "_rowType", "_searchText", "_category"];

    if (isNull _control) then {
        continue;
    };

    private _show = if (_rowType == "category") then {
        _categoryMatches getOrDefault [_category, false]
    } else {
        _query == "" || _query in _searchText
    };
    _control ctrlShow _show;

    if (!_show) then {
        continue;
    };

    if (_rowType == "category") then {
        if (_currentColumn > 0) then {
            _currentY = _currentY + SPEC_TARGET_CARD_H + SPEC_TARGET_ROW_GAP;
        };

        _currentColumn = 0;
        _currentCategory = _category;

        _control ctrlSetPosition [0, _currentY, SPEC_TARGET_CATEGORY_W, SPEC_TARGET_CATEGORY_H];
        _control ctrlCommit 0;

        _currentY = _currentY + SPEC_TARGET_CATEGORY_H + SPEC_TARGET_ROW_GAP;
    } else {
        if (_category != _currentCategory) then {
            if (_currentColumn > 0) then {
                _currentY = _currentY + SPEC_TARGET_CARD_H + SPEC_TARGET_ROW_GAP;
            };

            _currentCategory = _category;
            _currentColumn = 0;
        };

        private _column = _currentColumn mod SPEC_TARGET_COLUMNS;
        _control ctrlSetPosition [_column * (SPEC_TARGET_CARD_W + SPEC_TARGET_COLUMN_GAP), _currentY, SPEC_TARGET_CARD_W, SPEC_TARGET_CARD_H];
        _control ctrlCommit 0;

        _currentColumn = _currentColumn + 1;
        _visibleTargetCount = _visibleTargetCount + 1;

        if (_currentColumn mod SPEC_TARGET_COLUMNS == 0) then {
            _currentY = _currentY + SPEC_TARGET_CARD_H + SPEC_TARGET_ROW_GAP;
            _currentColumn = 0;
        };
    };
} forEach _searchRows;

private _emptyControl = _display displayCtrl SPEC_TARGET_EMPTY_TEXT_ID;
_emptyControl ctrlShow (_visibleTargetCount == 0);

private _contentGroup = _display displayCtrl SPEC_TARGET_CONTENT_GROUP_ID;
if (!isNull _contentGroup) then {
    _contentGroup ctrlSetScrollValues [0, 0];
};