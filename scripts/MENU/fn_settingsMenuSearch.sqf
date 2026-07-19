#include "includes.inc"
params ["_searchControl"];
if (isNull _searchControl) exitWith {};

private _display = ctrlParent _searchControl;
if (isNull _display) exitWith {};

private _query = toLower ctrlText _searchControl;
private _isNotSearching = _query == "";
private _gotoSetting = if (_query select [0, 1] == "#") then {
    parseNumber (_query select [1]);
} else {
    0;
};

private _searchRows = _display getVariable ["WL2_settingsSearchRows", []];

private _currentY = 0;
{
    _x params ["_rowControl", "_rowType", "_searchText", "_rowHeight", "_optionNumber"];

    if (isNull _rowControl) then {
        continue;
    };

    private _isGotoSetting = _gotoSetting != 0 && _optionNumber == _gotoSetting;

    private _show = _isNotSearching || _isGotoSetting || _query in _searchText || _rowType == "category";
    _rowControl ctrlShow _show;

    if (_show) then {
        private _position = ctrlPosition _rowControl;
        _position set [1, _currentY];
        _rowControl ctrlSetPosition _position;
        _rowControl ctrlCommit 0;

        _currentY = _currentY + _rowHeight + SETTINGS_ROW_GAP;
    };
} forEach _searchRows;

private _contentGroup = _display displayCtrl SETTINGS_CONTENT_GROUP_ID;
_contentGroup ctrlSetScrollValues [0, 0];