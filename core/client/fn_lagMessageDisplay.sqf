params ["_message"];

private _display = uiNamespace getVariable ["RscLagMessageDisplay", objNull];
if (isNull _display) then {
    "Lag" cutRsc ["RscLagMessageDisplay", "PLAIN", -1, true, true];
    _display = uiNamespace getVariable "RscLagMessageDisplay";
};

private _background = _display displayCtrl 10000;

_background ctrlSetBackgroundColor [0, 0, 0, 1];

private _indicator1 = _display displayCtrl 10001;
private _indicator2 = _display displayCtrl 10002;
private _indicator3 = _display displayCtrl 10003;
private _indicator4 = _display displayCtrl 10004;

private _messagesPerColumn = floor ((safeZoneH * 0.8) / (ctrlFontHeight _indicator1)) - 1;

private _message1 = [_message, 0, _messagesPerColumn] call BIS_fnc_subSelect;
private _message2 = [_message, _messagesPerColumn, _messagesPerColumn * 2] call BIS_fnc_subSelect;
private _message3 = [_message, _messagesPerColumn * 2, _messagesPerColumn * 3] call BIS_fnc_subSelect;
private _message4 = [_message, _messagesPerColumn * 3] call BIS_fnc_subSelect;

_indicator1 ctrlSetText (_message1 joinString "\n");
_indicator2 ctrlSetText (_message2 joinString "\n");
_indicator3 ctrlSetText (_message3 joinString "\n");
_indicator4 ctrlSetText (_message4 joinString "\n");

diag_log "======================================================================================";
diag_log "=========================== LAG HANDLE MESSAGE: COPY BELOW ===========================";
diag_log "======================================================================================";

{
    diag_log _x;
} forEach _message;

sleep 10;

{
    _x ctrlSetText "";
} forEach [_indicator1, _indicator2, _indicator3, _indicator4];

_background ctrlSetBackgroundColor [0, 0, 0, 0];