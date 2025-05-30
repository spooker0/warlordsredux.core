"RequestMenu_close" call WL2_fnc_setupUI;

private _findCurrentSector = (BIS_WL_sectorsArray # 0) select {
    player inArea (_x getVariable "objectAreaComplete")
};
private _currentSector = _findCurrentSector # 0;

private _oldStronghold = _currentSector getVariable ["WL_stronghold", objNull];
private _hasOldStronghold = !isNull _oldStronghold;

private _buildings = call WL2_fnc_findStrongholdBuilding;
if (count _buildings == 0) exitWith {
    playSoundUI ["AddItemFailed"];
};
private _stronghold = _buildings # 0;
private _strongholdPosMarkerAGL = getPosASL _stronghold;
_strongholdPosMarkerAGL set [2, (player modelToWorld [0, 0, 0]) # 2 + 2];
WL_strongholdIconPos = _strongholdPosMarkerAGL;
private _drawIconId = addMissionEventHandler ["draw3D", {
	drawIcon3D [
		"\A3\ui_f\data\map\mapcontrol\Ruin_CA.paa",
		[0, 0, 1, 1],
		WL_strongholdIconPos,
		1,
		1,
		0,
		"STRONGHOLD?",
		0,
		0.1,
		"PuristaMedium",
        "center",
        true
	];
}];

private _sectorName = _currentSector getVariable ["WL2_name", "sector"];
private _strongholdType = getText (configFile >> "CfgVehicles" >> typeOf _stronghold >> "displayName");
private _message = format ["Are you sure you want to create a Sector Stronghold in %1 from: %2?", _sectorName, _strongholdType];
if (_hasOldStronghold) then {
    _message = format ["%1<br/><br/><t color='#ff0000'>This will replace the current Sector Stronghold.</t>", _message];
};
private _result = [_message, "Create Sector Stronghold", "Create", "Cancel"] call BIS_fnc_guiMessage;
removeMissionEventHandler ["draw3D", _drawIconId];
if (!_result) exitWith {
    playSoundUI ["AddItemFailed"];
};

if (_hasOldStronghold) then {
    [_currentSector, true] call WL2_fnc_removeStronghold;
};

private _markerName = format ["WL_stronghold_%1", _sectorName];
private _markerTextName = format ["WL_strongholdText_%1", _sectorName];

_stronghold setVariable ["WL_strongholdOwner", player, true];

private _strongholdRadius = (boundingBoxReal _stronghold) # 2;

createMarkerLocal [_markerName, _stronghold];
_markerName setMarkerShapeLocal "ELLIPSE";
_markerName setMarkerSizeLocal [_strongholdRadius, _strongholdRadius];
_markerName setMarkerColorLocal "colorCivilian";
_markerName setMarkerAlpha 0.3;

createMarkerLocal [_markerTextName, _stronghold];
_markerTextName setMarkerShapeLocal "ICON";
_markerTextName setMarkerTypeLocal "loc_Ruin";
_markerTextName setMarkerColorLocal "colorCivilian";
_markerTextName setMarkerText "STRONGHOLD";

_currentSector setVariable ["WL_stronghold", _stronghold, true];
_currentSector setVariable ["WL_strongholdMarker", _markerName, true];
_currentSector setVariable ["WL_strongholdTextMarker", _markerTextName, true];

[player, "buyStronghold"] remoteExec ["WL2_fnc_handleClientRequest", 2];
[_stronghold, _currentSector] remoteExec ["WL2_fnc_prepareStronghold", 2];

private _allStrongholds = missionNamespace getVariable ["WL_strongholds", []];
_allStrongholds = _allStrongholds select {
    _x != _oldStronghold
 };
_allStrongholds pushBack _stronghold;
missionNamespace setVariable ["WL_strongholds", _allStrongholds, true];

for "_i" from 1 to 10 do {
    if (random 1 > 0.5) then {
        continue;
    };

    private _randomFile = round random [1, 6, 12];
    if (_randomFile < 10) then {
        _randomFile = format ["0%1", _randomFile];
    } else {
        _randomFile = str _randomFile;
    };

    playSound3D [format ["a3\sounds_f_orange\arsenal\explosives\debris_%1.wss", _randomFile], _stronghold];
    sleep 0.2;
};
