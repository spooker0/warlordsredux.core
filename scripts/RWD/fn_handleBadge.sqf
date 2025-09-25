#include "includes.inc"
private _rewardStack = missionNamespace getVariable ["WL2_rewardStack", createHashMap];
private _badges = missionNamespace getVariable ["WL2_badges", createHashMap];

private _badgeConfigs = [
    ["SAM KILLS", "Grounded", RWD_BADGE_KILLREQ],
    ["PLANE KILLS", "Air Warfare", RWD_BADGE_KILLREQ],
    ["HEAVY KILLS", "Tank Superiority", RWD_BADGE_KILLREQ],
    ["INFANTRY KILLS", "Combat Proficiency", RWD_BADGE_KILLREQ],
    ["LIGHT KILLS", "Vehicle Tactical", RWD_BADGE_KILLREQ],
	["NAVAL KILLS", "Naval Combat", RWD_BADGE_KILLREQ],
	["UAV KILLS", "Drone Operator", RWD_BADGE_KILLREQ],
    ["HELO KILLS", "Chopper Proficiency", RWD_BADGE_KILLREQ],
    ["STATIC KILLS", "Turret Excellence", RWD_BADGE_KILLREQ],

	["SAM DESTROYED", "Air Defense Suppression", RWD_BADGE_DESTROYREQ],
	["PLANE DESTROYED", "Air Superiority", RWD_BADGE_DESTROYREQ],
	["HEAVY DESTROYED", "Tank Destroyer", RWD_BADGE_DESTROYREQ],
	["LIGHT DESTROYED", "Vehicle Hunter", RWD_BADGE_DESTROYREQ],
	["NAVAL DESTROYED", "Coast Guard", RWD_BADGE_DESTROYREQ],
	["UAV DESTROYED", "Zap", RWD_BADGE_DESTROYREQ],
	["HELO DESTROYED", "Chopper Down", RWD_BADGE_DESTROYREQ],
	["STATIC DESTROYED", "Turret Sweeper", RWD_BADGE_DESTROYREQ],

	["ATTACKING SECTOR", "Frontline Hero", RWD_BADGE_SECTORREQ],
	["DEFENDING SECTOR", "Defender", RWD_BADGE_SECTORREQ],
	["PROJECTILE KILLED", "Just One More Rocket", RWD_BADGE_PROJREQ],
	["REVIVED", "Combat Medic", RWD_BADGE_MEDICREQ],
	["RECON", "Spotter", RWD_BADGE_RECONREQ],

	["PLANE KILL PLANE", "Ace Pilot", RWD_BADGE_KILLREQ],
	["HELO KILL PLANE", "Slow and Steady", RWD_BADGE_KILLREQ],
	["LIGHT KILL HEAVY", "Anti-tank Warfare", RWD_BADGE_KILLREQ],
	["HEAVY KILL HEAVY", "Heavy Metal", RWD_BADGE_KILLREQ],
	["NAVAL KILL HEAVY", "Littoral Operator", RWD_BADGE_KILLREQ]
];

{
    private _badgeKey = _x select 0;
    private _badgeName = _x select 1;
	private _badgeReq = _x select 2;
    private _current = _rewardStack getOrDefault [_badgeKey, 0];

    if (_current >= _badgeReq) then {
        _rewardStack set [_badgeKey, _current - _badgeReq];
		[_badgeName] call RWD_fnc_newBadge;
        
		private _currentBadges = _badges getOrDefault [_badgeName, 0];
		_badges set [_badgeName, _currentBadges + 1];
    };
} forEach _badgeConfigs;

missionNamespace setVariable ["WL2_badges", _badges];