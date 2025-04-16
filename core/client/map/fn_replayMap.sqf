WL_IsReplaying = true;

private _profileDrawIcons = profileNamespace getVariable ["WL2_drawIcons", ""];
private _profileDrawEllipses = profileNamespace getVariable ["WL2_drawEllipses", ""];
private _profileDrawSectorIcons = profileNamespace getVariable ["WL2_drawSectorIcons", ""];
_profileDrawIcons = fromJSON _profileDrawIcons;
_profileDrawEllipses = fromJSON _profileDrawEllipses;
_profileDrawSectorIcons = fromJSON _profileDrawSectorIcons;

if (isNil "_profileDrawIcons") exitWith {
    WL_IsReplaying = false;
};

private _countFrames = count _profileDrawIcons;

{
    if ("_USER_DEFINED #" in _x) then {
        _x setMarkerAlphaLocal 0;
    };
} forEach allMapMarkers;
setGroupIconsSelectable false;
setGroupIconsVisible [false, false];
{
    [_x, _x getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
} forEach BIS_WL_allSectors;

openMap [true, false];

for "_i" from 0 to _countFrames - 1 do {
    private _frameIcons = _profileDrawIcons # _i;
    private _frameEllipses = _profileDrawEllipses # _i;
    private _frameSectorIcons = _profileDrawSectorIcons # _i;

    uiNamespace setVariable ["WL2_drawIcons", _frameIcons];
    uiNamespace setVariable ["WL2_drawEllipses", _frameEllipses];
    uiNamespace setVariable ["WL2_drawSectorIcons", _frameSectorIcons];

    uiSleep 1;
};

uiNamespace setVariable ["WL2_drawIcons", []];
uiNamespace setVariable ["WL2_drawEllipses", []];
uiNamespace setVariable ["WL2_drawSectorIcons", []];

{
    if ("_USER_DEFINED #" in _x) then {
        _x setMarkerAlphaLocal 1;
    };
} forEach allMapMarkers;
setGroupIconsSelectable true;
setGroupIconsVisible [true, false];
openMap [false, false];
WL_IsReplaying = false;
{
    [_x, _x getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
} forEach BIS_WL_allSectors;