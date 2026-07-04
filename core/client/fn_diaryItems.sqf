#include "includes.inc"

if (isDedicated) exitWith {};

uiNamespace setVariable ["WL2_rewardHistory", createHashMap];
player createDiarySubject ["Warlords Redux", "Warlords Redux"];

call GFE_fnc_credits;

private _changeNotes = player createDiaryRecord ["Warlords Redux","", taskNull, "", false];
private _changeNotesText = format ["<font color='#CCCCCC' size='18'>Changes Notes</font><br/><br/>%1", (loadfile "update.txt") regexReplace ["\n", "<br />"]];
player setDiaryRecordText [["Warlords Redux", _changeNotes], ["Change Notes", _changeNotesText]];

private _helpAA = player createDiaryRecord ["Warlords Redux","", taskNull, "", false];
player setDiaryRecordText [["Warlords Redux", _helpAA], ["Help: Air defense", (loadfile localize "STR_WL_fileHelpAA") regexReplace ["\n", "<br />"]]];

private _statsRecord = player createDiaryRecord ["Warlords Redux", "", taskNull, "", false];

while { !BIS_WL_missionEnd } do {
	private _rewardHistory = uiNamespace getVariable ["WL2_rewardHistory", createHashMap];

    private _displayText = "<font color='#CCCCCC' size='18'>Personal Kill History</font><br/>";

    {
        private _name = _x;
        private _data = _y;

        _displayText = format ["%1<br/>%2x %3: +%4", _displayText, _data # 0, _name, _data # 1];
    } forEach _rewardHistory;

    player setDiaryRecordText [["Warlords Redux", _statsRecord], ["Statistics", _displayText]];
    uiSleep 15;
};