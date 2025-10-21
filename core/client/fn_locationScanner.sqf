#include "includes.inc"

uiNamespace setVariable ["WL2_damagedDrawIcons", []];
uiNamespace setVariable ["WL2_drawPlayerIcons", []];
uiNamespace setVariable ["WL2_drawSectorHudIcons", []];
uiNamespace setVariable ["WL2_playerIconTextCache", createHashMap];
uiNamespace setVariable ["WL2_playerIconColorCache", createHashMap];

0 spawn {
    while { !BIS_WL_missionEnd } do {
        uiSleep 0.5;

        private _nearbyUnconscious = (player nearObjects ["Man", 8]) select {
            lifeState _x == "INCAPACITATED" && side group _x == BIS_WL_playerSide
        };
        _nearbyUnconscious = _nearbyUnconscious select {
            [getPosASL player, getDir player, 90, getPosASL _x] call WL2_fnc_inAngleCheck
        };
        if (count _nearbyUnconscious > 1) then {
            _nearbyUnconscious = [_nearbyUnconscious, [], {
                if (_x == cursorTarget) then {
                    -1
                } else {
                    player distance _x
                };
            }, "ASCEND"] call BIS_fnc_sortBy;
        };
        private _reviveTarget = if (count _nearbyUnconscious > 0) then { _nearbyUnconscious # 0 } else { objNull };
        if (!isNull _reviveTarget) then {
            private _reviveActionId = player getVariable ["WL2_reviveActionId", -1];
            private _displayText = name _reviveTarget;
            private _reviveText = format ["<t color='#00ff00'>Revive %1</t>", _displayText];
            private _reviveImage = format [
                "<img size='3' color='#00ff00' image='a3\ui_f\data\igui\cfg\revive\overlayIcons\u100_ca.paa'/> <t size='1.5' color='#00ff00'>Revive %1</t>",
                _displayText
            ];
            player setUserActionText [_reviveActionId, _reviveText, _reviveImage];
        };
        player setVariable ["WL2_reviveTarget", _reviveTarget];

        private _nearbyDemolishableItems = (cameraOn nearObjects 35) select {
            _x getVariable ["WL2_canDemolish", false];
        };

        private _nearbyDamagedItems = _nearbyDemolishableItems select {
            private _maxHealth = _x getVariable ["WL2_demolitionMaxHealth", 5];
            alive _x && (_x getVariable ["WL2_demolitionHealth", _maxHealth] < _maxHealth)
        };

        // do distance checks after, visible within 35 anyway
        _nearbyDemolishableItems = _nearbyDemolishableItems select {
            private _isNotStronghold = isNull (_x getVariable ["WL_strongholdSector", objNull]);
            private _distanceLimit = if (_isNotStronghold) then { 10 } else { 35 };
            private _inAngle = if (_isNotStronghold) then {
                [getPosASL player, getDir player, 90, getPosASL _x] call WL2_fnc_inAngleCheck;
            } else {
                true
            };
            player distance2D _x <= _distanceLimit && _inAngle
        };
        private _currentTarget = [_nearbyDemolishableItems] call WL2_fnc_demolishEligibility;
        if (!isNull _currentTarget) then {
            private _isStronghold = !isNull (_currentTarget getVariable ["WL_strongholdSector", objNull]);
            private _demolishActionId = player getVariable ["WL2_demolishActionId", -1];
            private _displayText = if (_isStronghold) then {
                "Stronghold"
            } else {
                [_currentTarget] call WL2_fnc_getAssetTypeName
            };
            private _demolishText = format ["<t color='#ff0000'>Demolish %1</t>", _displayText];
            private _demolishImage = format [
                "<img size='3' color='#ff0000' image='a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa'/> <t size='1.5' color='#ff0000'>Demolish %1</t>",
                _displayText
            ];
            player setUserActionText [_demolishActionId, _demolishText, _demolishImage];
        };
        player setVariable ["WL2_demolishableTarget", _currentTarget];

        private _demolishIcons = [];
        {
            private _maxHealth = _x getVariable ["WL2_demolitionMaxHealth", 5];
            _demolishIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
                [1, 1, 0, 1],
                [_x, 0.5],
                1.4,
                1.4,
                0,
                format [
                    "%1/%2",
                    _x getVariable ["WL2_demolitionHealth", _maxHealth],
                    _maxHealth
                ],
                true,
                0.07,
                "RobotoCondensedBold",
                "center",
                true
            ];
        } forEach _nearbyDamagedItems;

        private _nearSaboteurs = allPlayers select {
            _x distance2D player < 100
        };
        {
            private _sabotageTarget = _x getVariable ["WL2_sabotageTarget", [0, ""]];
            if (_sabotageTarget # 0 < serverTime) then { continue; };
            _demolishIcons pushBack [
                "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa",
                [1, 0, 0, 1],
                [_x, 0.5],
                1,
                1,
                0,
                format ["%1", _sabotageTarget # 1],
                true,
                0.035,
                "RobotoCondensedBold",
                "center",
                true,
                0,
                -0.05
            ];
        } forEach _nearSaboteurs;

        uiNamespace setVariable ["WL2_damagedDrawIcons", _demolishIcons];

        private _playerIconTextCache = uiNamespace getVariable ["WL2_playerIconTextCache", createHashMap];
        private _playerIconColorCache = uiNamespace getVariable ["WL2_playerIconColorCache", createHashMap];
        private _viewDistance = (getObjectViewDistance # 0) min 1000;
        private _detectableUnits = allUnits;
        _detectableUnits pushBackUnique cursorTarget;
        _detectableUnits pushBackUnique cursorObject;
        private _playerIcons = [];
        {
            if (_x == player) then { continue; };
            if ((typeof _x) in ["B_UAV_AI", "O_UAV_AI", "I_UAV_AI"]) then { continue; };
            private _assetSide = [_x] call WL2_fnc_getAssetSide;

            if (BIS_WL_playerSide != _assetSide) then {
                private _isNotStronghold = isNull (_x getVariable ["WL_strongholdSector", objNull]);
                if (_isNotStronghold) then { continue; };
            };

            private _isntCursorTarget = _x != cursorTarget && _x != cursorObject;
            if (_x distance cameraOn > _viewDistance && _isntCursorTarget) then { continue; };

            private _isInMySquad = ["isInMySquad", [getPlayerID _x]] call SQD_fnc_client;
            if (!_isInMySquad && _x distance cameraOn > 100 && _isntCursorTarget) then { continue; };

            if (!(_x isKindOf "Man") && !alive _x) then { continue; };

            private _color = [_x, _playerIconColorCache] call WL2_fnc_iconColor;

            private _displayName = [_x, true, true, _playerIconTextCache] call WL2_fnc_iconText;
            private _size = if (_isInMySquad) then { 0.04 } else { 0.03 };

            private _boundingSize = ((boundingBoxReal _x) # 2) / 2;

            if (lifeState _x == "INCAPACITATED") then {
                _playerIcons pushBack [
                    "a3\ui_f\data\igui\cfg\revive\overlayIcons\u100_ca.paa",
                    _color,
                    [_x, _boundingSize],
                    1.2,
                    1.2,
                    0,
                    _displayName,
                    2,
                    _size,
                    "RobotoCondensedBold",
                    "center",
                    true,
                    0,
                    -0.05
                ];
            } else {
                _playerIcons pushBack [
                    "",
                    _color,
                    [_x, _boundingSize],
                    0,
                    0,
                    0,
                    _displayName,
                    2,
                    _size,
                    "RobotoCondensedBold",
                    "center"
                ];
            };
        } forEach _detectableUnits;
        uiNamespace setVariable ["WL2_playerIconColorCache", _playerIconColorCache];
        uiNamespace setVariable ["WL2_playerIconTextCache", _playerIconTextCache];
        uiNamespace setVariable ["WL2_drawPlayerIcons", _playerIcons];

        private _sectorIcons = [];
        {
            private _target = _x;
            if (isNull _target) then { continue; };

            private _revealedBy = _target getVariable ["BIS_WL_revealedBy", []];
            private _isRevealed = BIS_WL_playerSide in _revealedBy;
            if (!_isRevealed && _x != WL_TARGET_FRIENDLY) then { continue; };

            private _owner = _target getVariable ["BIS_WL_owner", independent];
            private _color = if (_isRevealed) then {
                BIS_WL_colorsArray # (BIS_WL_sidesArray find _owner);
            } else {
                BIS_WL_colorsArray # 3;
            };
            _color set [3, 0.5];

            private _mapMarker = (_target getVariable ["BIS_WL_markers", []]) # 0;
            private _mapMarkerType = markerType _mapMarker;
            private _mapMarkerPath = getText (configFile >> "CfgMarkers" >> _mapMarkerType >> "icon");

            private _sectorName = _target getVariable ["WL2_name", "Sector"];

            _sectorIcons pushBack [
                _mapMarkerPath,
                _color,
                _target,
                1,
                1,
                0,
                _sectorName,
                2,
                0.03,
                "RobotoCondensedBold",
                "center"
            ];

            private _distance = cameraOn distance _target;
            private _distanceText = if (_distance >= 1000) then {
                format ["(%1 %2)", (_distance / 1000) toFixed 1, toUpper BIS_WL_localized_km]
            } else {
                ""
            };
            private _displayText = if (_owner == BIS_WL_playerSide) then {
                format ["DEFEND %1", _distanceText]
            } else {
                format ["ATTACK %1", _distanceText]
            };
            private _sectorTextColor = if (_owner == BIS_WL_playerSide) then {
                [0, 1, 0, 1]
            } else {
                [1, 0, 0, 1]
            };

            _sectorIcons pushBack [
                "",
                _sectorTextColor,
                _target,
                0,
                0,
                0,
                _displayText,
                2,
                0.031,
                "RobotoCondensedBold",
                "center",
                false,
                0,
                -0.035
            ];
        } forEach [WL_TARGET_FRIENDLY, WL_TARGET_ENEMY];
        uiNamespace setVariable ["WL2_drawSectorHudIcons", _sectorIcons];
    };
};

addMissionEventHandler ["Draw3D", {
    private _drawIcons = uiNamespace getVariable ["WL2_damagedDrawIcons", []];
    private _playerIcons = uiNamespace getVariable ["WL2_drawPlayerIcons", []];
    {
        private _icon = +_x;
        private _targetInfo = _icon select 2;
        private _target = _targetInfo # 0;
        private _boundingSize = _targetInfo # 1;
        private _offset = if (_target isKindOf "Man") then {
            (_target selectionPosition "head") vectorAdd [0, 0, 0.5]
        } else {
            private _centerOfMass = getCenterOfMass _target;
            _centerOfMass vectorAdd [0, 0, _boundingSize]
        };
        private _position = _target modelToWorldVisual _offset;
        _icon set [2, _position];
        drawIcon3D _icon;
    } forEach (_drawIcons + _playerIcons);

    if (WL_IsSpectator) exitWith {};

    private _sectorIcons = uiNamespace getVariable ["WL2_drawSectorHudIcons", createHashMap];
    {
        private _icon = +_x;
        private _target = _icon select 2;
        private _sectorPos = _target modelToWorldVisual [0, 0, 5];
        _icon set [2, _sectorPos];
        drawIcon3D _icon;
    } forEach _sectorIcons;
}];

private _side = BIS_WL_playerSide;
private _fobNextWarn = 0;
private _strongholdNextWarn = 0;
while { !BIS_WL_missionEnd } do {
    private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
    private _newStrongholds = [];
    private _allScannedUnits = [];
    {
        private _stronghold = _x;
        private _strongholdSector = _stronghold getVariable ["WL_strongholdSector", objNull];

        // check if stronghold has been deleted
        private _sectorStronghold = _strongholdSector getVariable ["WL_stronghold", objNull];
        if (_sectorStronghold == _stronghold) then {
            _newStrongholds pushBack _stronghold;
        } else {
            _stronghold setVariable ["WL2_strongholdIntruders", false];
            continue;
        };

        private _sectorOwner = _strongholdSector getVariable ["BIS_WL_owner", independent];
        if (_sectorOwner != _side) then {
            _stronghold setVariable ["WL2_strongholdIntruders", false];
            continue;
        };

        private _strongholdRadius = _stronghold getVariable ["WL_strongholdRadius", 0];
        private _strongholdArea = [
            getPosASL _stronghold,
            _strongholdRadius,
            _strongholdRadius,
            0,
            false
        ];
        private _scannedUnits = [_side, _strongholdArea] call WL2_fnc_detectUnits;
        _allScannedUnits append _scannedUnits;

        // don't consider unconscious units as intruders
        _scannedUnits = _scannedUnits select {
            lifeState _x != "INCAPACITATED"
        };

        if (count _scannedUnits > 0) then {
            _stronghold setVariable ["WL2_strongholdIntruders", true];
            if (serverTime >= _strongholdNextWarn) then {
                _strongholdNextWarn = serverTime + 30;
                systemChat "Stronghold intrusion detected!";
            };
        } else {
            _stronghold setVariable ["WL2_strongholdIntruders", false];
        };
    } forEach _strongholds;
    missionNamespace setVariable ["WL_strongholds", _newStrongholds];

    private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];

    {
        private _forwardBase = _x;

        if (_forwardBase getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side) then {
            private _forwardBaseArea = [_forwardBase, WL_FOB_RANGE, WL_FOB_RANGE, 0, false];
            private _scannedUnits = [_side, _forwardBaseArea] call WL2_fnc_detectUnits;
            _allScannedUnits append _scannedUnits;

            if (count _scannedUnits > 0) then {
                _forwardBase setVariable ["WL2_forwardBaseIntruders", true];
                if (serverTime >= _fobNextWarn) then {
                    _fobNextWarn = serverTime + 30;
                    systemChat "Forward base intrusion detected!";
                };
            } else {
                _forwardBase setVariable ["WL2_forwardBaseIntruders", false];
            };
        } else {
            private _sectorsInRange = _forwardBase getVariable ["WL2_forwardBaseSectors", []];
            _sectorsInRange = _sectorsInRange select {
                _x getVariable ["BIS_WL_owner", independent] == _side
            };
            _forwardBase setVariable ["WL2_forwardBaseShowOnMap", count _sectorsInRange > 0];
        };
    } forEach _forwardBases;

    {
        _side reportRemoteTarget [_x, 5];
    } forEach _allScannedUnits;

    missionNamespace setVariable ["WL2_detectedUnits", _allScannedUnits];
    uiSleep 2;
};