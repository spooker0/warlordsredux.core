#include "includes.inc"
if (isDedicated) exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

private _display = uiNamespace getVariable ["RscWLKillfeedMenu", displayNull];
if (isNull _display) then {
    "killfeed" cutRsc ["RscWLKillfeedMenu", "PLAIN", -1, true, true];
    _display = uiNamespace getVariable ["RscWLKillfeedMenu", displayNull];
};
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
	if (_message == "A") then {
		private _killfeedNotificationVolume = _settingsMap getOrDefault ["killfeedNotification", 1.0];
		private _pitch = 1 + (random 0.2);
		playSoundUI ["AddItemOk", _killfeedNotificationVolume * 3, _pitch];
	} else {
		if (_message == "B") then {
			private _killfeedNotificationVolume = _settingsMap getOrDefault ["killfeedNotification", 1.0];
			private _pitch = 0.5 + (random 0.5);
			private _sound = [
				"a3\sounds_f_orange\missionsfx\orange_destroy_01.wss",
				"a3\sounds_f_orange\missionsfx\orange_destroy_02.wss",
				"a3\sounds_f_orange\missionsfx\orange_destroy_03.wss"
			];
			playSoundUI [selectRandom _sound, _killfeedNotificationVolume, _pitch];
		} else {
			private _killfeedCelebrationVolume = _settingsMap getOrDefault ["killfeedCelebration", 1.0];
			playSoundUI ["a3\missions_f_exp\data\sounds\exp_m05_dramatic.wss", _killfeedCelebrationVolume * 5];
		};
	};
	true;
}];

while { !BIS_WL_missionEnd } do {
    private _killfeedScale = _settingsMap getOrDefault ["killfeedScale", 1.0];
    private _killfeedBadgeScale = _settingsMap getOrDefault ["killfeedBadgeScale", 1.0];
    private _killfeedTimeout = (_settingsMap getOrDefault ["killfeedTimeout", 10]) * 1000;
    private _killfeedMinGap = _settingsMap getOrDefault ["killfeedMinGap", 250];
    private _ribbonMinShowTime = (_settingsMap getOrDefault ["ribbonMinShowTime", 5]) * 1000;

    private _killfeedLeft = _settingsMap getOrDefault ["killfeedLeft", 50];
    private _killfeedBottom = 100 - (_settingsMap getOrDefault ["killfeedTop", 95]);

    private _showHitIndicator = _settingsMap getOrDefault ["showHitIndicator", false];
    private _minimalistic = _settingsMap getOrDefault ["killfeedMinimalistic", false];

    private _script = format [
        "setSettings(%1, %2, %3, %4, %5, %6, %7, %8, %9);",
        _killfeedScale,
        _killfeedBadgeScale,
        _killfeedTimeout,
        _killfeedMinGap,
        _ribbonMinShowTime,
        _killfeedLeft,
        _killfeedBottom,
        _showHitIndicator,
        _minimalistic
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _script];

    uiSleep 1;
};