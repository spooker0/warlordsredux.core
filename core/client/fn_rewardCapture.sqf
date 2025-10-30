#include "includes.inc"
private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _disallowManList = ["B_UAV_AI", "O_UAV_AI", "I_UAV_AI"];
private _assetData = WL_ASSET_DATA;

while { !BIS_WL_missionEnd } do {
    uiSleep 20;

    private _vehicles = missionNamespace getVariable [_ownedVehicleVar, []];

    private _attackingValue = 0;
    private _defendingValue = 0;
    {
        private _vehicle = _x;
        if (!alive _vehicle) then {
            continue;
        };
        private _aliveCrew = (crew _vehicle) select { alive _x && !(typeOf _x in _disallowManList) };
        if (count _aliveCrew == 0) then {
            continue;
        };

        private _inSector = BIS_WL_allSectors findIf { _vehicle inArea (_x getVariable "objectAreaComplete") };
        if (_inSector == -1) then {
            continue;
        };

        private _sector = BIS_WL_allSectors # _inSector;
        private _captureProgress = _sector getVariable ["BIS_WL_captureProgress", 0];
        if (_captureProgress == 0) then {
            continue;
        };

        private _sectorOwner = _sector getVariable ["BIS_WL_owner", independent];
        if (_vehicle isKindOf "Man") then {
            private _sectorStronghold = _sector getVariable ["WL_stronghold", objNull];
            private _strongholdRadius = _sectorStronghold getVariable ["WL_strongholdRadius", 0];

            private _score = if (_vehicle distance2D _sectorStronghold < _strongholdRadius) then {
                5;
            } else {
                1;
            };

            if (_sectorOwner == BIS_WL_playerSide) then {
                _defendingValue = _defendingValue + _score;
            } else {
                _attackingValue = _attackingValue + _score;
            };
            continue;
        };

        private _assetActualType = _vehicle getVariable ["WL2_orderedClass", typeOf _vehicle];
        private _capValue = WL_ASSET_FIELD(_assetData, _assetActualType, "capValue", 0);

        if (_sectorOwner == BIS_WL_playerSide) then {
            _defendingValue = _defendingValue + _capValue;
        } else {
            _attackingValue = _attackingValue + _capValue;
        };
    } forEach (_vehicles + [player]);

    _attackingValue = _attackingValue * 50;
    _defendingValue = _defendingValue * 50;

    if (_attackingValue > 0) then {
        [objNull, _attackingValue, "Attacking sector", "#228b22"] call WL2_fnc_killRewardClient;
    };
    if (_defendingValue > 0) then {
        [objNull, _defendingValue, "Defending sector", "#228b22"] call WL2_fnc_killRewardClient;
    };
    private _totalValue = _attackingValue + _defendingValue;
    if (_totalValue > 0) then {
        [player, "sectorReward", _totalValue] remoteExec ["WL2_fnc_handleClientRequest", 2];
    };
};