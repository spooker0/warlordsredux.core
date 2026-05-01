#include "includes.inc"
params ["_mode", "_eligibilityCallback", "_setupCallback", "_successCallback", "_cancelCallback", "_arguments", "_isVote"];

private _mapQueue = uiNamespace getVariable "WL2_mapSelectQueue";
if (isNil "_mapQueue") exitWith {};

"Sector" call WL2_fnc_announcer;
[localize "STR_WL_selectSector"] call WL2_fnc_smoothText;

"RequestMenu_close" call WL2_fnc_setupUI;

if (!visibleMap && !_isVote) then {
	processDiaryLink createDiaryLink ["Map", player, ""];
	WL_CONTROL_MAP ctrlMapAnimAdd [0, 0.1, player];
	ctrlMapAnimCommit WL_CONTROL_MAP;
};

waitUntil {
    uiSleep 0.001;
    inputMouse 0 == 0;
};

call _setupCallback;

private _mapQueueEntry = [_mode, false, _eligibilityCallback, _arguments];
if (_isVote) then {
    _mapQueue insert [0, [_mapQueueEntry]];
} else {
    _mapQueue pushBack _mapQueueEntry;
};

while { !(_mapQueueEntry # 1) } do {
    private _queueEntryIndex = count _mapQueue - 1;
    if (_mapQueueEntry isEqualRef (_mapQueue # _queueEntryIndex)) then {
        {
            private _alpha = 0;
            if ([_x, _arguments] call _eligibilityCallback) then {
                _alpha = 1;
                _x setVariable ["WL2_sectorSelectionAvailable", true];
            } else {
                _alpha = 0.3;
                _x setVariable ["WL2_sectorSelectionAvailable", false];
            };
            private _markers = _x getVariable ["BIS_WL_markers", []];
            (_markers # 0) setMarkerAlphaLocal _alpha;
            (_markers # 1) setMarkerAlphaLocal (_alpha * 0.5);
        } forEach BIS_WL_allSectors;
    };

    if (!_isVote) then {
        if (!visibleMap) then {
            break;
        };

        if (WL_ISDOWN(player)) then {
            break;
        };
    };

    uiSleep WL_TIMEOUT_SHORT;
};

private _response = _mapQueueEntry # 4;

private _queueEntryIndex = count _mapQueue - 1;
_mapQueue deleteAt _queueEntryIndex;

if (count _mapQueue == 0) then {
    {
        _x setVariable ["WL2_sectorSelectionAvailable", false];
        private _markers = _x getVariable ["BIS_WL_markers", []];
        (_markers # 0) setMarkerAlphaLocal 1;
        (_markers # 1) setMarkerAlphaLocal 0.5;
    } forEach BIS_WL_allSectors;
};

if (isNil "_response") exitWith {
    "Canceled" call WL2_fnc_announcer;
    call _cancelCallback;
};

if ([_response, _arguments] call _eligibilityCallback) then {
    playSoundUI ["AddItemOK", 1];
    [_response, _arguments] call _successCallback;
} else {
    "Canceled" call WL2_fnc_announcer;
    call _cancelCallback;
};