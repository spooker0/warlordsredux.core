#include "constants.inc"

private _lastListType = "ENTITIES";
while { WL_IsSpectator } do {
    private _oldEntitiesListMap = uiNamespace getVariable ["SPEC_entitiesList", createHashMap];
    private _newEntitiesListMap = createHashMap;

    private _spectatorDisplay = findDisplay SPEC_DISPLAY;
    private _entitiesList = _spectatorDisplay displayCtrl SPEC_ENTITIES_LIST;
    for "_sideId" from 0 to ((_entitiesList tvCount []) - 1) do {   // Sides
        for "_groupId" from 0 to ((_entitiesList tvCount [_sideId]) - 1) do {   // Groups
            for "_unitId" from 0 to ((_entitiesList tvCount [_sideId, _groupId]) - 1) do {  // Units
                private _path = [_sideId, _groupId, _unitId];
                private _tvData = _entitiesList tvData _path;
                _newEntitiesListMap set [_tvData, _path];
            };
        };
    };

    private _listType = uiNamespace getVariable ["RscEGSpectator_listType", "ENTITIES"];

    private _fullRefresh = (round serverTime) % 5 == 0 || _listType != _lastListType;
    private _entityListPosition = ctrlPosition _entitiesList;
    private _height = safeZoneH + safeZoneY - _entityListPosition # 1;
    if (_height != _entityListPosition # 3 && _fullRefresh) then {
        _entitiesList ctrlSetPositionH _height;
        _entitiesList ctrlCommit 0;
    };

    if (_listType == "LOCATIONS") then {
        private _locations = missionNamespace getVariable ["BIS_EGSpectator_locations", []];
        for "_i" from 0 to ((_entitiesList tvCount []) - 1) do {
            private _location = _locations # _i;
            if (isNil "_location") then {
                continue;
            };
            private _sectorOwner = _location # 2;
            private _sectorColor = switch (_sectorOwner) do {
                case "BLUFOR": {
                    [0, 0.3, 0.6, 1]
                };
                case "OPFOR": {
                    [0.5, 0, 0, 1]
                };
                case "INDEPENDENT": {
                    [0, 0.5, 0, 1]
                };
                default {
                    [1, 1, 1, 0.8]
                };
            };
            _entitiesList tvSetPictureColor [[_i], _sectorColor];
            _entitiesList tvSetPictureColorSelected [[_i], _sectorColor];
        };
        continue;
    };

    if (!(_oldEntitiesListMap isEqualTo _newEntitiesListMap) || _fullRefresh) then {
        {
            private _tvData = _x;
            private _path = _y;

            private _entity = missionNamespace getVariable [_tvData, objNull];
            private _entityVehicle = vehicle _entity;

            if (_entityVehicle != _entity && alive _entityVehicle) then {
                private _entityName = format [
                    "%1: %2",
                    [_entityVehicle] call WL2_fnc_getAssetTypeName,
                    [_entity, true] call BIS_fnc_getName
                ];
                private _oldEntityName = _entitiesList tvText _path;
                if (_oldEntityName != _entityName) then {
                    _entitiesList tvSetText [_path, _entityName];
                    private _targetIcon = [_entityVehicle] call SPEC_fnc_spectatorGetIcon;
                    _entitiesList tvSetPicture [_path, _targetIcon];
                };
            };
        } forEach _newEntitiesListMap;
    };

    _lastListType = _listType;
    uiNamespace setVariable ["SPEC_entitiesList", _newEntitiesListMap];
    sleep 0.5;
};