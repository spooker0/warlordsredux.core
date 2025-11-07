#include "includes.inc"
params ["_asset"];

waitUntil {
    uiSleep 0.1;
    cameraOn == _asset;
};

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeof _asset];

private _ecmParameters = WL_ASSET(_assetActualType, "ecm", []);
if (count _ecmParameters < 3) exitWith {};

private _ecmJammerType = _ecmParameters # 0;
private _ecmRequiresPod = _ecmParameters # 1;
private _ecmRange = _ecmParameters # 2;
private _ecmSpeed = _ecmParameters # 3;
private _ecmCharges = _ecmParameters # 4;
private _ecmRechargeTime = _ecmParameters # 5;

private _jammerPods = { _x # 0 == "PylonFuelTank_UH80" } count (magazinesAllTurrets _asset);

if (_ecmRequiresPod == 1 && _jammerPods == 0) exitWith {};
if (_ecmRequiresPod == 0) then {
    _jammerPods = 1;
};

_ecmCharges = round (_ecmCharges * _jammerPods);
_ecmRechargeTime = round (_ecmRechargeTime / _jammerPods);

// set default if not set
private _charges = _asset getVariable ["WL2_ecmCharges", -100];
if (_charges == -100) then {
    _asset setVariable ["WL2_ecmCharges", _ecmCharges];
};

uiNamespace setVariable ["WL2_ECMMunitions", []];
uiNamespace setVariable ["WL2_ECMMunitionLocks", []];

private _ecmDraw = addMissionEventHandler ["Draw3D", {
    private _ecmMunitions = uiNamespace getVariable ["WL2_ECMMunitions", []];

    {
        private _munition = _x;
        if (!alive _munition) then {
            continue;
        };
        private _munitionPos = _munition modelToWorldVisual [0, 0, 0];

        private _originator = getShotParents _munition # 0;
        private _originatorType = if (_originator isKindOf "Man") then {
            "INFANTRY";
        } else {
            toUpper ([_originator] call WL2_fnc_getAssetTypeName);
        };
        private _distance = _munitionPos distance cameraOn;
        private _munitionText = format ["%1 (%2 KM)", _originatorType, (_distance / 1000) toFixed 1];

        drawIcon3D [
            "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
            [0.5, 0, 0, 1],
            _munitionPos,
            1,
            1,
            0,
            _munitionText,
            true,
            0.035,
            "RobotoCondensedBold",
            "center",
            true
        ];
    } forEach _ecmMunitions;

    private _ecmLocks = uiNamespace getVariable ["WL2_ECMMunitionLocks", []];
    {
        private _munition = _x;
        if (!alive _munition) then {
            continue;
        };
        private _munitionPos = _munition modelToWorldVisual [0, 0, 0];

        private _jamPercent = _munition getVariable ["WL2_jamPercent", 0];
        if (_jamPercent <= 0) then {
            continue;
        };
        private _jamLockSize = linearConversion [0, 100, _jamPercent, 3.0, 0.8];

        drawIcon3D [
            "\A3\ui_f\data\IGUI\Cfg\Cursors\lock_target_ca.paa",
            [1, 1, 1, 1],
            _munitionPos,
            _jamLockSize,
            _jamLockSize,
            0
        ];
    } forEach _ecmLocks;
}];

[_asset, _jammerPods, _ecmRange, _ecmSpeed] spawn {
    params ["_asset", "_jammerPods", "_ecmRange", "_ecmSpeed"];

    private _isAir = _asset isKindOf "Air";

    while { alive _asset && cameraOn == _asset } do {
        uiSleep 0.1;
        private _ecmMunitions = uiNamespace getVariable ["WL2_ECMMunitions", []];

        private _sensitivity = 0.2;
        private _charges = _asset getVariable ["WL2_ecmCharges", 0];
        if (_charges <= 0) then {
            continue;
        };

        if (_isAir) then {
            private _assetAGL = _asset modelToWorld [0, 0, 0];
            if (_assetAGL # 2 < 50) then {
                continue;
            };
        };

        private _fovMultiplier = getObjectFOV cameraOn / 0.5;

        private _jamMarkers = [];
        {
            if (!alive _x) then {
                continue;
            };
            if (_x getVariable ["WL2_jamDestroy", false]) then {
                continue;
            };

            private _munitionPos = _x modelToWorldVisual [0, 0, 0];

            private _screenPos = worldToScreen _munitionPos;
            private _distanceToCenter = if (count _screenPos == 2) then {
                _screenPos distance2D [0.5, 0.5]
            } else {
                100
            };

            if (_distanceToCenter > _sensitivity / _fovMultiplier) then {
                if (_jammerPods != 0) then {
                    _x setVariable ["WL2_jamPercent", 0];
                };
                continue;
            };

            private _munitionDistance = _munitionPos distance cameraOn;
            private _addPercent = linearConversion [0, _ecmRange ^ 2, _munitionDistance ^ 2, 5 * _ecmSpeed, _ecmSpeed];

            private _chargesRemaining = _asset getVariable ["WL2_ecmCharges", 0];
            if (_chargesRemaining <= 0) then {
                _x setVariable ["WL2_jamPercent", 0];
                continue;
            };

            private _jamPercent = _x getVariable ["WL2_jamPercent", 0];
            _jamPercent = (_jamPercent + _addPercent) min 100;
            _x setVariable ["WL2_jamPercent", _jamPercent];

            _jamMarkers pushBack _x;

            if (_jamPercent >= 100) then {
                _asset setVariable ["WL2_ecmCharges", _chargesRemaining - 1];

                private _originator = getShotParents _x # 0;
                private _originatorUid = _originator getVariable ["BIS_WL_ownerAsset", "123"];
                if !(_x getVariable ["WL2_jamDestroy", false]) then {
                    [player, _originatorUid] remoteExec ["WL2_fnc_missileDestroy", 2];
                };

                triggerAmmo _x;
                _x setVariable ["WL2_jamDestroy", true, true];
            };
        } forEach _ecmMunitions;

        if (count _jamMarkers > 0) then {
            playSoundUI ["AddItemOk", 1, 5.0];
        };

        uiNamespace setVariable ["WL2_ECMMunitionLocks", _jamMarkers];
    };
};

private _nextChargeTime = serverTime + _ecmRechargeTime;
private _lastCharges = _charges;
private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _apsVolume = _settingsMap getOrDefault ["apsVolume", 1];
while { alive _asset && cameraOn == _asset } do {
    uiSleep 0.25;

    private _munitions = (8 allObjects 2) select {
        _x distance _asset < _ecmRange
    } select {
        typeOf _x != "ammo_Missile_Cruise_01"
    } select {
        private _munition = _x;
        _ecmJammerType findIf { _munition isKindOf _x } >= 0
    };
#if WL_ECM_TEST == 0
    _munitions = _munitions select {
        private _shotParent = getShotParents _x # 0;
        BIS_WL_playerSide != [_shotParent] call WL2_fnc_getAssetSide
    };
#endif

    uiNamespace setVariable ["WL2_ECMMunitions", _munitions];

    private _currentCharges = _asset getVariable ["WL2_ecmCharges", _ecmCharges];
    if (serverTime > _nextChargeTime || _currentCharges >= _ecmCharges) then {
        _nextChargeTime = serverTime + _ecmRechargeTime;
        if (_currentCharges < _ecmCharges) then {
            _asset setVariable ["WL2_ecmCharges", _currentCharges + 1];
            playSoundUI ["AddItemOk", 1, 5.0];
        };
    };

    cameraOn setVariable ["WL2_ecmNextChargeTime", ceil (_nextChargeTime - serverTime)];

    if (_lastCharges > 0 && _currentCharges == 0) then {
        playSoundUI ["a3\sounds_f\vehicles\air\noises\heli_alarm_rotor_low.wss", _apsVolume * 0.2, 0.5];
    };
    _lastCharges = _currentCharges;
};

removeMissionEventHandler ["Draw3D", _ecmDraw];