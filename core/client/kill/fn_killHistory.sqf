#include "includes.inc"

uiNamespace setVariable ["WL2_rewardHistory", createHashMap];
player createDiarySubject ["Warlords Statistics", "Warlords Statistics"];
private _record = player createDiaryRecord ["Warlords Statistics", "", taskNull, "", false];

while { !BIS_WL_missionEnd } do {
	private _rewardHistory = uiNamespace getVariable ["WL2_rewardHistory", createHashMap];

    private _displayText = "<font color='#CCCCCC' size='20'>Personal Kill History</font><br/>";

    {
        private _name = _x;
        private _data = _y;

        _displayText = format ["%1<br/>%2x %3: +%4", _displayText, _data # 0, _name, _data # 1];
    } forEach _rewardHistory;

    player setDiaryRecordText [["Warlords Statistics", _record], ["Personal Kill History", _displayText]];

    sleep 15;
};