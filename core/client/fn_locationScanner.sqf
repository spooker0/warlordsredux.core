#include "includes.inc"

uiNamespace setVariable ["WL2_damagedDrawIcons", []];
0 spawn {
    while { !BIS_WL_missionEnd } do {
        sleep 0.5;

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

        private _nearbyDemolishableItems = (player nearObjects 35) select {
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
                _x,
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
            side group _x != BIS_WL_playerSide
        } select {
            _x distance2D player < 50
        };
        {
            private _sabotageTarget = _x getVariable ["WL2_sabotageTarget", [0, ""]];
            if (_sabotageTarget # 0 < serverTime) then { continue; };
            _demolishIcons pushBack [
                "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa",
                [1, 0, 0, 1],
                _x,
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
    };
};

addMissionEventHandler ["Draw3D", {
    private _drawIcons = uiNamespace getVariable ["WL2_damagedDrawIcons", []];
    {
        private _icon = +_x;
        private _target = _icon select 2;
        if (!alive _target) then { continue; };
        private _offset = if (_target isKindOf "Man") then { [0, 0, 2] } else { [0, 0, 0] };
        private _position = _target modelToWorldVisual _offset;
        _icon set [2, _position];
        drawIcon3D _icon;
    } forEach _drawIcons;
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
                if (serverTime >= _fobNextWarn) then {
                    _fobNextWarn = serverTime + 30;
                    systemChat "Forward base intrusion detected!";
                };
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
    sleep 2;
};