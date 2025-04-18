WL2_announcerQueue = [];
"Initialized" call WL2_fnc_announcer;
private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

while { !BIS_WL_missionEnd } do {
    if (count WL2_announcerQueue == 0) then {
        sleep 2;
        continue;
    };

    private _message = WL2_announcerQueue # 0;
    private _length = getNumber (configFile >> "CfgSounds" >> _message >> "duration");
    if (_length == 0) then {
        _length = 2;
    };

    private _announcerVolume = _settingsMap getOrDefault ["announcerVolume", 1];
    playSoundUI [_message, _announcerVolume];
    WL2_announcerQueue deleteAt 0;

    sleep (_length + 0.5);
};