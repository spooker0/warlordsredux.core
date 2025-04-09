#include "..\..\core\warlords_constants.inc"

#define SPEC_DISPLAY 60492

#define SPEC_MAP_CONTROL 62609
#define SPEC_ENTITIES_LIST 43109

#define SPEC_VAR_CAM "BIS_EGSpectatorCamera_camera"
#define SPEC_VAR_FOCUS "RscEGSpectator_focus"

#define SPEC_VAR_FUN_CAMERA (missionNamespace getVariable ["BIS_fnc_EGSpectatorCamera", {}])
#define SPEC_VAR_FUN_RESET_TARGET (missionNamespace getVariable ["BIS_fnc_EGSpectatorCameraResetTarget", {}])
#define SPEC_VAR_FUN_PREPARE_TARGET (missionNamespace getVariable ["BIS_fnc_EGSpectatorCameraPrepareTarget", {}])
#define SPEC_VAR_FUN_SPECTATOR (uiNamespace getVariable ["RscDisplayEGSpectator_script", {}])