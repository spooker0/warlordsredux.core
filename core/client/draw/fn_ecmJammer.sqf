#include "includes.inc"
params ["_asset"];

waitUntil {
    sleep 0.1;
    cameraOn == _asset;
};

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeof _asset];

private _ecmParameters = WL_ASSET(_assetActualType, "ecm", []);
if (count _ecmParameters < 3) exitWith {};

private _ecmJammerType = _ecmParameters # 0;
private _ecmPodsRequired = _ecmParameters # 1;
private _ecmRange = _ecmParameters # 2;
private _ecmSpeed = _ecmParameters # 3;
private _ecmCharges = _ecmParameters # 4;
private _ecmRechargeTime = _ecmParameters # 5;

private _jammerPods = { _x # 0 == "PylonFuelTank_UH80" } count (magazinesAllTurrets _asset);
if (_jammerPods < _ecmPodsRequired) exitWith {
    private _assetName = [_asset] call WL2_fnc_getAssetTypeName;
    if (_jammerPods > 0) then {
        systemChat format ["%1: Not enough ECM Jammer pods installed. Required: %2, Installed: %3", _assetName, _ecmPodsRequired, _jammerPods];
    };
};

private _jammerRatio = if (_ecmPodsRequired > 0) then {
    _jammerPods / _ecmPodsRequired
} else {
    1
};
_ecmCharges = round (_ecmCharges * _jammerRatio);
_ecmRechargeTime = round (_ecmRechargeTime / _jammerRatio);

// set default if not set
private _charges = _asset getVariable ["WL2_ecmCharges", -100];
if (_charges == -100) then {
    _asset setVariable ["WL2_ecmCharges", _ecmCharges];
};

uiNamespace setVariable ["WL2_ECMMunitions", []];
uiNamespace setVariable ["WL2_ECMMunitionLocks", []];

"ecmJammer" cutRsc ["RscWLECMJammerDisplay", "PLAIN"];
private _display = uiNamespace getVariable ["RscWLECMJammerDisplay", displayNull];

private _chargesIcon = _display displayCtrl 33001;
private _chargesText = _display displayCtrl 33002;
private _chargesTimer = _display displayCtrl 33003;

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

    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
    private _apsVolume = _settingsMap getOrDefault ["apsVolume", 1];

    while { alive _asset && cameraOn == _asset } do {
        sleep 0.1;
        private _ecmMunitions = uiNamespace getVariable ["WL2_ECMMunitions", []];

        private _sensitivity = 0.15;
        if (_jammerPods == 0) then {
            _sensitivity = 0.08;
            if (freelook) then {
                continue;
            };
            if (inputAction "defaultAction" == 0) then {
                continue;
            };
            if (!someAmmo _asset) then {
                continue;
            };
        };

        private _charges = _asset getVariable ["WL2_ecmCharges", 0];
        if (_charges <= 0) then {
            continue;
        };

        private _fovMultiplier = getObjectFOV cameraOn / 0.5;

        private _jamMarkers = [];
        {
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
            private _addPercent = linearConversion [0, _ecmRange, _munitionDistance, 20 * _ecmSpeed, 2 * _ecmSpeed];

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
                if (_chargesRemaining == 1 && _jammerPods > 0) then {
                    playSoundUI ["a3\sounds_f\vehicles\air\noises\heli_alarm_rotor_low.wss", _apsVolume * 0.2, 0.5];
                };
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

private _playerUid = getPlayerUID player;
private _nextChargeTime = serverTime + _ecmRechargeTime;
while { alive _asset && cameraOn == _asset } do {
    sleep 0.25;

    private _munitions = (8 allObjects 2) select { _x distance _asset < _ecmRange } select {
        private _munition = _x;
        _ecmJammerType findIf { _munition isKindOf _x } >= 0 && {
            private _shotParent = getShotParents _munition # 0;
            private _shotParentUid = _shotParent getVariable ["BIS_WL_ownerAsset", "123"];
            _shotParentUid != _playerUid;
        };
    };
    uiNamespace setVariable ["WL2_ECMMunitions", _munitions];

    private _currentChanges = _asset getVariable ["WL2_ecmCharges", _ecmCharges];
    if (serverTime > _nextChargeTime || _currentChanges >= _ecmCharges) then {
        _nextChargeTime = serverTime + _ecmRechargeTime;
        if (_currentChanges < _ecmCharges) then {
            _asset setVariable ["WL2_ecmCharges", _currentChanges + 1];
            playSoundUI ["AddItemOk", 1, 5.0];
        };
    };

    private _charges = _asset getVariable ["WL2_ecmCharges", _ecmCharges];

    private _chargesColor = "#33ff33";
    if (_charges <= 0) then {
        _chargesIcon ctrlSetTextColor [1, 0, 0, 1];
        _chargesColor = "#ff3333";
    } else {
        _chargesIcon ctrlSetTextColor [1, 1, 1, 1];
    };

    _chargesText ctrlSetStructuredText parseText format ["<t color='%1' align='center'>%2</t>", _chargesColor, _charges];
    _chargesTimer ctrlSetStructuredText parseText format ["<t color='#ffffff' align='center'>%1</t>", ceil (_nextChargeTime - serverTime)];
};

"ecmJammer" cutText ["", "PLAIN"];
removeMissionEventHandler ["Draw3D", _ecmDraw];