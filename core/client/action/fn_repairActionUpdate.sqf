#include "includes.inc"
if (isDedicated) exitWith {};

while { !BIS_WL_missionEnd } do {
    uiSleep 0.5;

    if (!isActionMenuVisible) then {
        continue;
    };

    if (!alive player) then {
        continue;
    };

    private _cursorObject = cursorObject;
    if (isNull _cursorObject) then {
        continue;
    };

    private _eligibility = [_cursorObject, player] call WL2_fnc_repairActionEligibility;
    if (!_eligibility) then {
        continue;
    };
    private _cursorObjectActionID = _cursorObject getVariable ["WL2_repairActionID", -1];
    if (_cursorObjectActionID < 0) then {
        continue;
    };

    private _repairCooldown = ((_cursorObject getVariable ["WL2_nextRepair", 0]) - serverTime) max 0;
    private _cursorObjectTypeName = [_cursorObject] call WL2_fnc_getAssetTypeName;
    private _actionText = if (_repairCooldown == 0) then {
        format ["<t color = '#4bff58'>%1 %2</t>", localize "STR_repair", _cursorObjectTypeName];
    } else {
        private _cooldownText = [_repairCooldown, "MM:SS"] call BIS_fnc_secondsToString;
        format ["<t color = '#7e7e7e'><t align = 'left'>%1 %2</t><t align = 'right'>%3     </t></t>", localize "STR_repair", _cursorObjectTypeName, _cooldownText];
    };
    private _actionImage = format ["<img size='2' color = '%1' image='\A3\ui_f\data\IGUI\Cfg\Actions\repair_ca.paa'/>", if (_repairCooldown == 0) then {"#ffffff"} else {"#7e7e7e"}];

    _cursorObject setUserActionText [_cursorObjectActionID, _actionText, _actionImage];
};