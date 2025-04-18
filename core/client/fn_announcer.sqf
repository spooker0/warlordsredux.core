if (isNil "WL2_announcerQueue") exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _announcerVolume = _settingsMap getOrDefault ["announcerVolume", 1];
if (_announcerVolume > 0) then {
	WL2_announcerQueue pushBack format ["BIS_WL_%1_%2", _this, BIS_WL_sidesArray # ((BIS_WL_sidesArray find BIS_WL_playerSide) min 1)];
};