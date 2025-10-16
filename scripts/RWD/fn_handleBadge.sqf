#include "includes.inc"
private _rewardStack = missionNamespace getVariable ["WL2_rewardStack", createHashMap];
private _badgeConfigs = [
    ["SAM KILLS", "Grounded", RWD_BADGE_KILLREQ],
    ["PLANE KILLS", "Air Warfare", RWD_BADGE_KILLREQ],
    ["HEAVY KILLS", "Armor Superiority", RWD_BADGE_KILLREQ],
    ["INFANTRY KILLS", "Combat Proficiency", RWD_BADGE_KILLREQ],
    ["LIGHT KILLS", "Vehicle Tactical", RWD_BADGE_KILLREQ],
	["NAVAL KILLS", "Naval Combat", RWD_BADGE_KILLREQ],
	["UAV KILLS", "Drone Operator", RWD_BADGE_KILLREQ],
    ["HELO KILLS", "Chopper Proficiency", RWD_BADGE_KILLREQ],
    ["STATIC KILLS", "Turret Excellence", RWD_BADGE_KILLREQ],

	["SAM DESTROYED", "Safe Skies", RWD_BADGE_DESTROYREQ],
	["PLANE DESTROYED", "Air Superiority", RWD_BADGE_DESTROYREQ],
	["HEAVY DESTROYED", "Tank Destroyer", RWD_BADGE_DESTROYREQ],
	["LIGHT DESTROYED", "Vehicle Hunter", RWD_BADGE_DESTROYREQ],
	["NAVAL DESTROYED", "Coast Guard", RWD_BADGE_DESTROYREQ],
	["UAV DESTROYED", "Zap", RWD_BADGE_DESTROYREQ],
	["HELO DESTROYED", "Chopper Down", RWD_BADGE_DESTROYREQ],
	["STATIC DESTROYED", "Turret Sweeper", RWD_BADGE_DESTROYREQ],

	["STRONGHOLDS DESTROYED", "Bulldozer", RWD_BADGE_DESTROYREQ],

	["ATTACKING SECTOR", "Frontline Hero", RWD_BADGE_SECTORREQ],
	["DEFENDING SECTOR", "Defender", RWD_BADGE_SECTORREQ],
	["PROJECTILE KILLED", "Just One More Rocket", RWD_BADGE_PROJREQ],
	["REVIVED", "Combat Medic", RWD_BADGE_MEDICREQ],
	["RECON", "Spotter", RWD_BADGE_RECONREQ],

	["PLANE KILL PLANE", "Ace Pilot", RWD_BADGE_SPECKILLREQ],
	["HELO KILL PLANE", "Slow and Steady", RWD_BADGE_SPECKILLREQ],
	["LIGHT KILL HEAVY", "Size Matters Not", RWD_BADGE_SPECKILLREQ],
	["HEAVY KILL HEAVY", "Heavy Metal", RWD_BADGE_SPECKILLREQ],
	["NAVAL KILL GROUND", "Littoral Operator", RWD_BADGE_SPECKILLREQ],
	["INFANTRY KILL HEAVY", "Junkyard", RWD_BADGE_SPECKILLREQ],

	["DEMOLITIONS", "Demolition Specialist", RWD_BADGE_SPECKILLREQMORE],
	["SAM KILL PLANE", "No Fly Zone", RWD_BADGE_SPECKILLREQMORE],
	["STATIC KILL HEAVY", "Stationary", RWD_BADGE_SPECKILLREQMORE]
];

{
    private _badgeKey = _x select 0;
    private _badgeName = _x select 1;
	private _badgeReq = _x select 2;
    private _current = _rewardStack getOrDefault [_badgeKey, 0];

    if (_current >= _badgeReq) then {
        _rewardStack set [_badgeKey, _current - _badgeReq];
		[_badgeName] call RWD_fnc_addBadge;
    };
} forEach _badgeConfigs;