"RequestMenu_close" call WL2_fnc_setupUI;

private _findCurrentSector = (BIS_WL_sectorsArray # 0) select {
    player inArea (_x getVariable "objectAreaComplete")
};
private _currentSector = _findCurrentSector # 0;

private _oldSectorBuilding = _currentSector getVariable ["WL_stronghold", objNull];
private _hasOldSectorBuilding = !isNull _oldSectorBuilding;

private _buildings = nearestObjects [player, ["Building"], 20, true];
_buildings = _buildings select {
    private _buildingBounds = boundingBoxReal _x;
    private _minBound = _buildingBounds # 0;
    private _maxBound = _buildingBounds # 1;
    private _buildingArea = (_maxBound # 0 - _minBound # 0) * (_maxBound # 1 - _minBound # 1);

    _buildingArea > 100 && (_x getVariable ["BIS_WL_ownerAsset", "123"]) == "123"
};
_buildings = [_buildings, [], {
    getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "cost");
}, "DESCEND"] call BIS_fnc_sortBy;

if (count _buildings == 0) exitWith {
    playSoundUI ["AddItemFailed"];
};

private _sectorBuilding = _buildings # 0;

private _sectorName = _currentSector getVariable ["BIS_WL_name", "sector"];
private _sectorBuildingType = getText (configFile >> "CfgVehicles" >> typeOf _sectorBuilding >> "displayName");
private _message = format ["Are you sure you want to create a Sector Stronghold in %1 from: %2?", _sectorName, _sectorBuildingType];
if (_hasOldSectorBuilding) then {
    _message = format ["%1<br/><br/><t color='#ff0000'>This will replace the current Sector Stronghold.</t>", _message];
};
private _result = [_message, "Create Sector Stronghold", "Create", "Cancel"] call BIS_fnc_guiMessage;

if (!_result) exitWith {
    playSoundUI ["AddItemFailed"];
};

if (_hasOldSectorBuilding) then {
    [_oldSectorBuilding, false] remoteExec ["WL2_fnc_protectStronghold", 0, true];
    deleteMarker (_currentSector getVariable ["WL_strongholdMarker", ""]);
    deleteMarker (_currentSector getVariable ["WL_strongholdTextMarker", ""]);
};

private _markerName = format ["WL_stronghold_%1", _sectorName];
private _markerTextName = format ["WL_strongholdText_%1", _sectorName];

private _strongholdRadius = (boundingBoxReal _sectorBuilding) # 2;

private _strongholdMarker = createMarkerLocal [_markerName, _sectorBuilding];
_strongholdMarker setMarkerShapeLocal "ELLIPSE";
_strongholdMarker setMarkerSizeLocal [_strongholdRadius, _strongholdRadius];
_strongholdMarker setMarkerColorLocal "colorCivilian";
_strongholdMarker setMarkerAlpha 0.3;

private _strongholdTextMarker = createMarkerLocal [_markerTextName, _sectorBuilding];
_strongholdTextMarker setMarkerShapeLocal "ICON";
_strongholdTextMarker setMarkerTypeLocal "loc_Ruin";
_strongholdTextMarker setMarkerColorLocal "colorCivilian";
_strongholdTextMarker setMarkerText "STRONGHOLD";

_currentSector setVariable ["WL_stronghold", _sectorBuilding, true];
_currentSector setVariable ["WL_strongholdMarker", _strongholdMarker, true];
_currentSector setVariable ["WL_strongholdTextMarker", _strongholdTextMarker, true];

[player, "buyStronghold"] remoteExec ["WL2_fnc_handleClientRequest", 2];
[_sectorBuilding] remoteExec ["WL2_fnc_prepareStronghold", 2];

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

    playSound3D [format ["a3\sounds_f_orange\arsenal\explosives\debris_%1.wss", _randomFile], _sectorBuilding];
    sleep 0.2;
};
