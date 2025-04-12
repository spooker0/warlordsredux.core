private _activePoll = missionNamespace getVariable ["POLL_ActivePoll", []];
if (count _activePoll == 0) exitWith {};
if (_activePoll # 2 != -1) exitWith {};

player addAction [
    "<t color='#00ffff'>ACTIVE POLL</t>",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        call POLL_fnc_pollMenu;
        player removeAction _actionId;
    },
    [],
    100,
    false,
    true,
    "",
    ""
];