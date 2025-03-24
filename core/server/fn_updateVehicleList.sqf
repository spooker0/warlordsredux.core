while { !BIS_WL_missionEnd } do {
    private _westOwnedVehicles = [];
    private _eastOwnedVehicles = [];
    private _guerOwnedVehicles = [];
    {
        private _playerVehicleVariable = format ["BIS_WL_ownedVehicles_%1", getPlayerUID _x];
        private _vehicles = missionNamespace getVariable [_playerVehicleVariable, []];
        switch (side group _x) do {
            case west: {
                _westOwnedVehicles append _vehicles;
            };
            case east: {
                _eastOwnedVehicles append _vehicles;
            };
            case independent: {
                _guerOwnedVehicles append _vehicles;
            };
        };
    } forEach (call BIS_fnc_listPlayers);

    _westOwnedVehicles = _westOwnedVehicles select { alive _x };
    _eastOwnedVehicles = _eastOwnedVehicles select { alive _x };

    private _originalWestOwnedVehicles = missionNamespace getVariable ["BIS_WL_westOwnedVehicles", []];
    private _originalEastOwnedVehicles = missionNamespace getVariable ["BIS_WL_eastOwnedVehicles", []];

    if !(_originalWestOwnedVehicles isEqualTo _westOwnedVehicles) then {
        missionNamespace setVariable ["BIS_WL_westOwnedVehicles", _westOwnedVehicles, true];
    };
    if !(_originalEastOwnedVehicles isEqualTo _eastOwnedVehicles) then {
        missionNamespace setVariable ["BIS_WL_eastOwnedVehicles", _eastOwnedVehicles, true];
    };

#if WL_FACTION_THREE_ENABLED
    private _originalGuerOwnedVehicles = missionNamespace getVariable ["BIS_WL_guerOwnedVehicles", []];
    if !(_originalGuerOwnedVehicles isEqualTo _guerOwnedVehicles) then {
        missionNamespace setVariable ["BIS_WL_guerOwnedVehicles", _guerOwnedVehicles, true];
    };
#endif

    sleep 5;
};