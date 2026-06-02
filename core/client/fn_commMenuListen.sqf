#include "includes.inc"
params ["_commPlayer"];
private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _volume = _settingsMap getOrDefault ["nearbyNotificationVolume", 5];
playSound3D ["a3\missions_f_oldman\data\sound\phone_sms\chime\phone_sms_chime_04.wss", _commPlayer, false, getPosASL _commPlayer, _volume, 1, 0, 0, true];