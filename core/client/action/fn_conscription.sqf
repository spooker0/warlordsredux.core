#include "includes.inc"
params ["_conscripter"];

if (side group _conscripter != side group player) exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _disableConscription = _settingsMap getOrDefault ["disableConscription", false];
if (_disableConscription) exitWith {};

uiSleep 1;

if (WL_ISUP(player) && vehicle player != player) exitWith {};

private _callText = format ["Squad leader %1 has called the team to the frontline. Do you want to fast travel there now?", name _conscripter];
private _result = [
	"Called to Frontline",
	_callText,
	"Go", "Refuse"
] call WL2_fnc_prompt;

if (_result) then {
    if (WL_ISDOWN(player)) then {
        setPlayerRespawnTime 0.5;
        forceRespawn player;
    };
    waitUntil {
        uiSleep 0.2;
        WL_ISUP(player);
    };
    private _travelResult = [true] call WL2_fnc_travelTeamPriority;
    if (_travelResult) then {
        playSoundUI ["AddItemOk"];
    } else {
        playSoundUI ["AddItemFailed"];
        ["No team priority designated."] call WL2_fnc_smoothText;
    };
};