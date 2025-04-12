[
    player,
    "<t color='#00ff00'>Revive<t>",
    "\a3\ui_f\data\igui\cfg\revive\overlayIcons\u100_ca.paa",
    "\a3\ui_f\data\igui\cfg\revive\overlayIcons\u100_ca.paa",
    "isPlayer cursorObject && lifeState cursorObject == 'INCAPACITATED' && side group cursorObject == side group player && cursorObject distance2D player < 3",
    "speed player < 5",
    {
        private _soundId = playSound3D ["a3\sounds_f\characters\ingame\ainvpknlmstpslaywrfldnon_medic.wss", player];
        player setVariable ["WL_reviveSound", _soundId];
        player setVariable ["WL_reviveTarget", cursorObject];
    },
    {},
    {
        private _unit = player getVariable ["WL_reviveTarget", objNull];
        if (!isNull _unit) then {
            [_unit] remoteExec ["WL2_fnc_revive", _unit];

            private _reviveRewardTimers = player getVariable ["WL_reviveRewardTimers", createHashMap];
            private _unitTimer = _reviveRewardTimers getOrDefault [hashValue _unit, 0];
            if (_unitTimer < serverTime) then {
                [player, "revived"] remoteExec ["WL2_fnc_handleClientRequest", 2];
                private _newTimer = serverTime + 300;
                _reviveRewardTimers set [hashValue _unit, _newTimer];
                player setVariable ["WL_reviveRewardTimers", _reviveRewardTimers];
            };
        };
    },
    {
        private _soundId = player getVariable ["WL_reviveSound", -1];
        if (_soundId != -1) then {
            stopSound _soundId;
        };
        player setVariable ["WL_reviveSound", -1];
        player setVariable ["WL_reviveTarget", objNull];
    },
    [],
    5,
    100,
    false,
    false
] call BIS_fnc_holdActionAdd;

[
    player,
    "<t color='#ff0000'>Respawn</t>",
    "\a3\ui_f\data\igui\cfg\revive\overlayIcons\d100_ca.paa",
    "\a3\ui_f\data\igui\cfg\revive\overlayIcons\d100_ca.paa",
    "lifeState player == 'INCAPACITATED'",
    "lifeState player == 'INCAPACITATED'",
    {},
    {},
    {
        private _waitedTime = player getVariable ["WL_unconsciousTime", 0];
        private _originalRespawnTime = getMissionConfigValue ["respawnDelay", 30];
        private _newRespawnTime = (_originalRespawnTime - _waitedTime) max 5;
        setPlayerRespawnTime _newRespawnTime;
        forceRespawn player;
    },
    {},
    [],
    1,
    100,
    false,
    true
] call BIS_fnc_holdActionAdd;

player addAction [
	"Customization",
	{
        0 spawn WLC_fnc_buildMenu;
	},
	nil,
	1.5,
	true,
	true,
	"",
	"lifeState player == 'INCAPACITATED'",
	5,
	true,
	"",
	""
];

player setCaptive false;
player setVariable ["WL2_alreadyHandled", false, 2];
player setVariable ["WL_unconsciousTime", 0];
setPlayerRespawnTime (getMissionConfigValue ["respawnDelay", 30]);