#include "includes.inc"

if (isDedicated) exitWith {};

uiNamespace setVariable ["WL2_rewardHistory", createHashMap];
player createDiarySubject ["Warlords Redux", "Warlords Redux"];
private _statsRecord = player createDiaryRecord ["Warlords Redux", "", taskNull, "", false];
private _badgeRecord = player createDiaryRecord ["Warlords Redux", "", taskNull, "", false];

private _badgeConfigs = call RWD_fnc_getBadgeConfigs;

call GFE_fnc_credits;

while { !BIS_WL_missionEnd } do {
	private _rewardHistory = uiNamespace getVariable ["WL2_rewardHistory", createHashMap];

    private _displayText = "<font color='#CCCCCC' size='20'>Personal Kill History</font><br/>";

    {
        private _name = _x;
        private _data = _y;

        _displayText = format ["%1<br/>%2x %3: +%4", _displayText, _data # 0, _name, _data # 1];
    } forEach _rewardHistory;

    player setDiaryRecordText [["Warlords Redux", _statsRecord], ["Statistics", _displayText]];

    private _badgeText = "<font color='#CCCCCC' size='20'>Badges Earned</font><br/><br/>(Click to apply.)<br/>";
    private _badges = profileNamespace getVariable ["WL2_badges", createHashMap];
    {
        private _badgeName = _x;
        private _badgeCount = _y;
        private _badgeDisplay = format ["%1 (x%2)", _badgeName, _badgeCount];

        private _badgeData = _badgeConfigs getOrDefault [_badgeName, []];
        if (count _badgeData == 0) then { continue; };
        private _badgeIcon = _badgeData select 0;
        _badgeIcon = _badgeIcon regexReplace ["\\\\", "\\"];

        private _badgeColor = switch (_badgeData select 1) do {
            case 1: {"#779ECB"}; // Blue
            case 2: {"#cc7573"}; // Red
            case 3: {"#FFD700"}; // Gold
            default {"#FFFFFF"};
        };

        private _executableBadge = format [
            "<font size='32' color='%1'><img image='%2' height='40' /><executeClose expression=""['%3'] call RWD_fnc_applyBadge;"">%4</execute></font>", 
            _badgeColor, _badgeIcon, _badgeName, _badgeDisplay
        ];
        _badgeText = format ["%1<br/>%2", _badgeText, _executableBadge];
    } forEach _badges;

    player setDiaryRecordText [["Warlords Redux", _badgeRecord], ["Badges", _badgeText]];

    sleep 15;
};