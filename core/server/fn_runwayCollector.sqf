#include "includes.inc"

private _runwayAreas = [];
private _runwayConfig = missionConfigFile >> "CfgWarlordRunways";
private _runways = "true" configClasses _runwayConfig;
{
	private _areaData = getArray (_x >> "area");
	_areaData set [4, true];
	_runwayAreas pushBack _areaData;
} forEach _runways;

while { !BIS_WL_missionEnd } do {
	private _cleanupAssets = BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles;
	_cleanupAssets = _cleanupAssets select {
		alive _x
	} select {
		!(_x getEntityInfo 0)
	} select {
		count crew _x == 0
	} select {
        WL_UNIT(_x, "cost", 0) <= 10000
    };
	{
		private _assetsInArea = _cleanupAssets inAreaArray _x;
		{
            private _asset = _x;
            if (_asset getVariable ["WL2_accessControl", 0] == 0) then {
                continue;
            };
            _asset setVariable ["WL2_accessControl", 0, true];
            playSound3D ["a3\sounds_f\sfx\objects\upload_terminal\terminal_lock_close.wss", _asset, false, getPosASL _asset, 1, 1, 0, 0];
		} forEach _assetsInArea;
	} forEach _runwayAreas;

	uiSleep WL_COOLDOWN_GC;
};