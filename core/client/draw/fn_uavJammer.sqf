#include "..\..\warlords_constants.inc"

params ["_asset", "_owner"];

private _side = side _owner;

// Jammer checker (5s loop)
[_asset, _side] spawn {
    params ["_asset", "_side"];
    while { alive _asset } do {
        private _activeVehicles = vehicles select {
            alive _x &&
            isEngineOn _x
        };
        private _enemyJammers = _activeVehicles + ("Land_MobileRadar_01_radar_F" allObjects 0) select {
            [_x] call WL2_fnc_getAssetSide != _side &&
            alive _x
        };
        private _enemyJammersActive = _enemyJammers select {
            _x getVariable ["WL_ewNetActive", false];
        };
        private _enemyJammersActivating = _enemyJammers select {
            _x getVariable ["WL_ewNetActivating", false];
        };

        private _jammersInRange = _enemyJammersActive select {
            private _distanceToJammer = _asset distanceSqr _x;
            private _range = _x getVariable ["WL_ewNetRange", 0];
            _distanceToJammer < (_range * _range);
        };

        private _activatingInRange = _enemyJammersActivating select {
            private _distanceToJammer = _asset distanceSqr _x;
            private _range = _x getVariable ["WL_ewNetRange", 0];
            _distanceToJammer < (_range * _range);
        };

        _asset setVariable ["BIS_WL_relevantJammers", _jammersInRange];
        _asset setVariable ["BIS_WL_relevantJammersActivating", _activatingInRange];

        [_jammersInRange, 10] remoteExec ["WL2_fnc_reportTargets", BIS_WL_enemySide];

        sleep 5;
    };
};

// Jammer strength checker (1s loop)
[_asset] spawn {
    params ["_asset"];
    private _hardlineDistanceSqr = WL_JAMMER_HARDLINE_RANGE * WL_JAMMER_HARDLINE_RANGE;
    while { alive _asset } do {
        sleep 1;

        private _controller = (UAVControl _asset) # 0;
        private _controllerDistanceToAsset = _controller distanceSqr _asset;
        if (_controllerDistanceToAsset < _hardlineDistanceSqr) then {
            _asset setVariable ["BIS_WL_jammerStrength", 0];
            continue;
        };

        private _spectrumJammed = _asset getVariable ["BIS_WL_spectrumJammed", false];
        if (_spectrumJammed) then {
            _asset setVariable ["BIS_WL_spectrumJammed", false, true];
            playSoundUI ["a3\sounds_f\vehicles\air\CAS_01\noise.wss", 1, 1, false, 3.6];
            systemChat (localize "STR_A3_UAV_jammed");

            // Effect
            if (getPosATL _asset # 2 <= 1 && !isNull _controller) then {
                _controller connectTerminalToUAV objNull;
            };
        };

        private _relevantJammers = _asset getVariable ["BIS_WL_relevantJammers", []];
        private _activatingJammers = _asset getVariable ["BIS_WL_relevantJammersActivating", []];
        if (count _relevantJammers == 0) then {
            if (count _activatingJammers == 0) then {
                _asset setVariable ["BIS_WL_jammerStrength", 0];
            } else {
                _asset setVariable ["BIS_WL_jammerStrength", 0.15];
            };
            continue;
        };

        private _closestJammerDistance = WL_JAMMER_RANGE_OUTER * WL_JAMMER_RANGE_OUTER;
        private _closestJammer = objNull;
        {
            private _distanceToJammer = _asset distanceSqr _x;
            if (_distanceToJammer < _closestJammerDistance) then {
                _closestJammerDistance = _distanceToJammer;
                _closestJammer = _x;
            };
        } forEach _relevantJammers;
        _closestJammerDistance = sqrt _closestJammerDistance;

        private _jammerStrength = linearConversion [WL_JAMMER_RANGE_OUTER, WL_JAMMER_RANGE_INNER, _closestJammerDistance, 0, 1, true];
        _asset setVariable ["BIS_WL_jammerStrength", _jammerStrength];

        private _isTvMunition = _asset getVariable ["WL_tvMunition", false];
        if (_jammerStrength >= 1 && !_isTvMunition) then {
            if (getPosATL _asset # 2 > 1) then {
                // flyers take damage
                _asset setDamage [damage _asset + 0.1, true, _closestJammer];
            } else {
                // all others, disable control
                if (isAutonomous _asset) then {
                    [_asset, false] remoteExec ["setAutonomous", 0];
                };
                if (!isNull _controller) then {
                    _controller connectTerminalToUAV objNull;
                };
            };
        };
    };
};

// Jammer screen effect (1s loop)
[_asset] spawn {
    params ["_asset"];

    private _initFilmGrain = {
        private _priority = missionNamespace getVariable ["BIS_WL_filmGrainPriority", 2000];
        private _effect = ppEffectCreate ["filmGrain", _priority];
        if (!isNil "_effect") then {
            _effect ppEffectAdjust [1, 0];
            _effect ppEffectEnable false;
            _effect ppEffectForceInNVG true;
            _effect ppEffectCommit 0;
            missionNamespace setVariable ["BIS_WL_filmGrainPriority", _priority + 1];
            _effect;
        };
    };

    private _filmGrain = call _initFilmGrain;

    private _display = uiNamespace getVariable ["RscJammingIndicator", objNull];
    if (isNull _display) then {
        "Jamming" cutRsc ["RscJammingIndicator", "PLAIN", -1, false, true];
        _display = uiNamespace getVariable "RscJammingIndicator";
    };
    private _indicator = _display displayCtrl 7001;
    private _indicatorWidth = (localize "STR_A3_jammer_strength") getTextWidth ["PuristaMedium", 0.04];
    _indicator ctrlSetPosition [1, 0, _indicatorWidth + 0.05, 0.1];
    _indicator ctrlCommit 0;

    private _isTvMunition = _asset getVariable ["WL_tvMunition", false];

    private _sensors = (listVehicleSensors _asset) apply { _x # 0 };
    private _sensorsDisabled = false;
    while { alive _asset } do {
        if (isNil "_filmGrain") then {
            _filmGrain = call _initFilmGrain;
            sleep 10;
            continue;
        };

        private _jammerStrength = _asset getVariable ["BIS_WL_jammerStrength", 0];

        if (_isTvMunition) then {
            private _nearAir = _asset nearEntities ["Air", 300];
            _nearAir = _nearAir select {
                getPosATL _x # 2 > 20 &&
                [_x] call WL2_fnc_getAssetSide != BIS_WL_playerSide
            };
            _nearAir = _nearAir select {
                private _weapons = _x weaponsTurret [-1];
                private _countermeasures = _weapons select {
                    _x in ["CMFlareLauncher", "CMFlareLauncher_Singles", "CMFlareLauncher_Triples"];
                };
                count _countermeasures > 0;
            };

            private _airJammerStrength = if (count _nearAir > 0) then {
                private _nearestAirDistance = 300;
                {
                    private _distanceToAir = _asset distance _x;
                    _nearestAirDistance = _distanceToAir min _nearestAirDistance;
                } forEach _nearAir;
                linearConversion [300, 100, _nearestAirDistance, 0.5, 1, true];
            } else {
                0;
            };
            _jammerStrength = (_jammerStrength * 0.1) max _airJammerStrength;
            if (_jammerStrength >= 0.99) then {
                triggerAmmo _asset;
            };
        };

        if (!isRemoteControlling player && !_isTvMunition) then {
            _filmGrain ppEffectEnable false;

            _indicator ctrlSetText "";
            _indicator ctrlSetBackgroundColor [0, 0, 0, 0];
        } else {
            private _isControllingThisAsset = (UAVControl _asset) # 1 != "";
            if (_isControllingThisAsset || _isTvMunition) then {
                if (_jammerStrength > 0) then {
                    private _indicatorText = format [localize "STR_A3_jammer_strength", round (_jammerStrength * 100)];
                    _indicator ctrlSetText _indicatorText;
                    _indicator ctrlSetBackgroundColor [0, 0, 0, 0.5];

                    _filmGrain ppEffectEnable true;
                    _filmGrain ppEffectAdjust [1, 1 - _jammerStrength];
                } else {
                    _filmGrain ppEffectEnable false;

                    _indicator ctrlSetText "";
                    _indicator ctrlSetBackgroundColor [0, 0, 0, 0];
                };
            };
        };
        _filmGrain ppEffectCommit 0;

        private _exploitActive = !(ppEffectCommitted _filmGrain);
        if (_exploitActive) then {
            _filmGrain = call _initFilmGrain;
        };

        private _thermalDisabled = equipmentDisabled _asset # 1;
        if (_jammerStrength > WL_JAMMER_SENSOR_THRESHOLD && !_thermalDisabled) then {
            _asset disableTIEquipment true;
            _sensorsDisabled = true;
        } else {
            if (_jammerStrength <= WL_JAMMER_SENSOR_THRESHOLD && _thermalDisabled) then {
                _asset disableTIEquipment false;
                _sensorsDisabled = false;
            };
        };

        if (_sensorsDisabled) then {
            {
                _asset enableVehicleSensor [_x, false];
            } forEach _sensors;
            _asset setVehicleReceiveRemoteTargets false;
            _asset setVehicleReportOwnPosition false;
            _asset setVehicleReportRemoteTargets false;
        } else {
            {
                _asset enableVehicleSensor [_x, true];
            } forEach _sensors;
            _asset setVehicleReceiveRemoteTargets true;
            _asset setVehicleReportOwnPosition true;
            _asset setVehicleReportRemoteTargets true;
        };

        sleep 0.1;
    };

    _indicator ctrlSetText "";
    _indicator ctrlSetBackgroundColor [0, 0, 0, 0];

    if (!isNil "_filmGrain") then {
        _filmGrain ppEffectEnable false;
        _filmGrain ppEffectCommit 0;
        ppEffectDestroy _filmGrain;
    };
};