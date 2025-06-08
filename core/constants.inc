// Live: update to latest version
#define WL_VERSION "2.6.11"

// Live: set all to 0
#define WL_HARD_AI_MODE 0
#define WL_FACTION_THREE_ENABLED 0
#define WLC_DEBUG 0
#define WLT_DEBUG_MODE 0
#define WL_AIRPORT_BASES 0
#define WL_OVERRIDE_BASES 0
#define WL_BASE_SELECTION_DEBUG 0
#define WL_STRONGHOLD_DEBUG 0
#define WL_NO_GROUND_AVOID 0
#define WL_AA_TEST 0
#define WL_QUICK_CAPTURE 0
#define WL_ZEUS_ENABLED 0
#define WL_EASTER_EGG 0
#define WL_REPLAYS 0
#define WL_PERF_TEST 0

// Live: set all to 1
#define WL_STOP_TEAM_SWITCH 1
#define WL_FOB_SQUAD_REQUIREMENT 1
#define WL_AIR_POP_LIMIT 1

// Configuration
#define WL_RESPAWN_MARKERS_CNT 20
#define WL_TIMEOUT_MIN 0.055 //25, 55 = 20 FPS + 3 MS + 2ms(for slop) to safely run scripts at 20 fps.
#define WL_TIMEOUT_SHORT 0.25
#define WL_TIMEOUT_MEDIUM 0.5
#define WL_TIMEOUT_STANDARD 1
#define WL_TIMEOUT_LONG 5
#define WL_CONNECTING_LINE_AXIS 40
#define WL_CONNECTING_LINE_ALPHA_MIN 0.2
#define WL_CONNECTING_LINE_ALPHA_MAX 0.5
#define WL_MAP_PULSE_FREQ 1
#define WL_MAP_PULSE_ICON_SIZE 1.5
#define WL_BASE_ICON_SIZE 1.5
#define WL_BASE_DANGER_SPAWN_RANGE 200
#define WL_ID_SELECTION_NONE 0
#define WL_ID_SELECTION_FAST_TRAVEL 3
#define WL_ID_SELECTION_ORDERING_NAVAL 4
#define WL_ID_SELECTION_ORDERING_AIRCRAFT 5
#define WL_ID_SELECTION_SCAN 7
#define WL_ID_SELECTION_FAST_TRAVEL_CONTESTED 8
#define WL_ID_SELECTION_FAST_TRAVEL_VEHICLE 9
#define WL_ID_SELECTION_FAST_TRAVEL_STRONGHOLD 10
#define WL_FAST_TRAVEL_OFFSET 110
#define WL_FAST_TRAVEL_RANGE_AXIS 100
#define WL_FAST_TRAVEL_SQUAD_TIMER 60
#define WL_MAINTENANCE_RADIUS 30
#define WL_MAINTENANCE_COOLDOWN_REPAIR 600
#define WL_MAINTENANCE_COOLDOWN_REARM 600
#define WL_TARGET_RESET_VOTING_TIME 60
#define WL_JAMMER_RANGE_OUTER 3000
#define WL_JAMMER_RANGE_INNER 500
#define WL_JAMMER_SPECTRUM_RANGE 2000
#define WL_JAMMER_SPECTRUM_DETECT_RANGE 7000
#define WL_JAMMER_SPECTRUM_DIFFICULTY 0.03
#define WL_JAMMER_SENSOR_THRESHOLD 0.2
#define WL_JAMMER_HARDLINE_RANGE 20
#define WL_MANPOWER_REFRESH_COOLDOWN 300
#define WL_DEMOLISH_TIME 45
#define WL_DEMOLISH_FOB_TIME 60
#define WL_FOB_SETUP_TIME 30
#define WL_FOB_MIN_DISTANCE 3000
#define WL_FOB_RANGE 100
#define WL_FOB_CAPTURE_RANGE 1500
#define WL_FORTIFICATION_TIME 2700
#define WL_MAP_RESTRICTION_BUFFER 5000
#define WL_AFK_TIMER 300

// Code shortcuts

#define WL_TARGET_FRIENDLY (missionNamespace getVariable [format ["BIS_WL_currentTarget_%1", BIS_WL_playerSide], objNull])
#define WL_TARGET_ENEMY (missionNamespace getVariable format ["BIS_WL_currentTarget_%1", BIS_WL_enemySide])
#define WL_CONTROL_MAP (uiNamespace getVariable ["BIS_WL_mapControl", controlNull])
#define WL_PLAYER_REQUISITION_LIST (missionNamespace getVariable format ["WL2_purchasable_%1", BIS_WL_playerSide])
#define WL_REQUISITION_CATEGORIES ["Infantry", "Light Vehicles", "Heavy Vehicles", "Rotary Wing", "Fixed Wing", "Remote Control", "Air Defense", "Sector Defense", "Naval", "Gear", "Fast Travel", "Strategy"]
#define WL_BASES [WL2_base1, WL2_base2]
#define WL_ASSET_DATA (missionNamespace getVariable ["WL2_assetData", createHashMap])
#define WL_ASSET_FIELD(data,class,field,default) ((data getOrDefault [class, createHashMap]) getOrDefault [field, default])
#define WL_ASSET(class,field,default) WL_ASSET_FIELD(WL_ASSET_DATA,class,field,default)