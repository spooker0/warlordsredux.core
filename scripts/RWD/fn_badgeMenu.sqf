#include "includes.inc"
"RequestMenu_close" call WL2_fnc_setupUI;

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\badge.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
    if (_message == "exit") exitWith {
        playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
        closeDialog 0;
    };

    [_message] call RWD_fnc_applyBadge;
    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];

    private _badgeConfigs = call RWD_fnc_getBadgeConfigs;
    private _badges = profileNamespace getVariable ["WL2_badges", createHashMap];

    private _badgeArray = [];
    {
        if (_y == 0) then { continue; };
        _badgeArray pushBack [_x, _y];
    } forEach _badges;

    _badgeArray = [_badgeArray, [], { _x # 0 }, "ASCEND"] call BIS_fnc_sortBy;

    private _badgeDisplayData = [];
    {
        private _badgeName = _x # 0;
        private _badgeCount = _x # 1;

        private _badgeData = _badgeConfigs getOrDefault [_badgeName, []];
        if (count _badgeData == 0) then { continue; };
        private _badgeIcon = _badgeData select 0;
        _badgeIcon = _badgeIcon regexReplace ["\\\\", "\\"];

        private _badgeColor = switch (_badgeData select 1) do {
            case 1: {"#779ECB"};
            case 2: {"#cc7573"};
            case 3: {"#FFD700"};
            default {"#FFFFFF"};
        };
        private _badgeDescription = _badgeData select 2;
        _badgeDisplayData pushBack [_badgeColor, _badgeIcon, _badgeName, _badgeCount, _badgeDescription];
    } forEach _badgeArray;

    private _currentBadge = player getVariable ["WL2_currentBadge", "Player"];

    private _badgeDisplayDataText = toJSON _badgeDisplayData;
    _texture ctrlWebBrowserAction ["ExecJS", format ["setBadges(%1, ""%2"");", _badgeDisplayDataText, _currentBadge]];
}];