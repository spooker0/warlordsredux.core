#include "includes.inc"
params ["_unit"];

if (!hasInterface || isNull _unit) exitWith {};
if (cameraOn distance _unit > viewDistance) exitWith {};

private _pairCount = 10;
private _pairInterval = 0.06;
private _smokeInterval = 0.05;
private _smokeDuration = 0.8;
private _riseSpeed = 12;
private _coreWeight = 50;
private _coreVolume = 0.1;
private _coreRubbing = 0.5;
private _coreScale = 64;
private _coreBrightness = 1000;
private _emissiveColor = [_coreBrightness, _coreBrightness * 0.9, _coreBrightness * 0.7, 0];
private _sizeCurve = [0.08, 0.073, 0.08, 0.07, 0] apply { _x * _coreScale };
private _colorCurve = [
    [1, 1, 1, -8],
    [1, 1, 1, -6],
    [1, 1, 1, -8],
    [1, 1, 1, -6],
    [1, 1, 1, 0]
];
private _flareSounds = [
    "a3\sounds_f\arsenal\weapons\ugl\ugl_midshot_01.wss",
    "a3\sounds_f\arsenal\weapons\ugl\ugl_midshot_02.wss",
    "a3\sounds_f\arsenal\weapons\ugl\ugl_midshot_03.wss"
];

private _bounds = boundingBoxReal _unit;
private _halfWidth = abs ((_bounds # 0) # 0) max abs ((_bounds # 1) # 0);
private _wingOffset = (_halfWidth * 0.35) max 1.5;
private _burstOffset = [0, -3, -0.5];

for "_pair" from 0 to (_pairCount - 1) do {
    private _unitVelocity = velocity _unit;
    private _angle = linearConversion [0, _pairCount - 1, _pair, 15, 75, true];
    private _ejectionSpeed = linearConversion [0, _pairCount - 1, _pair, 100, 150, true];
    private _rearSpeed = (random 100) - 50;

    {
        if (_unit == cameraOn) then {
            playSoundUI [selectRandom _flareSounds, 1, 1];
        };

        private _side = _x;
        private _offset = _burstOffset vectorAdd [_side * _wingOffset, 0, 0];
        private _position = ASLToAGL (_unit modelToWorldWorld _offset);
        private _ejectionVelocity = _unit vectorModelToWorld [
            _side * (sin _angle) * _ejectionSpeed,
            _rearSpeed,
            (cos _angle) * _riseSpeed
        ];
        private _velocity = _unitVelocity vectorAdd _ejectionVelocity;

        private _flareLife = 4 + random 2;

        private _flareParticle = drop [
            ["\A3\data_f\ParticleEffects\Universal\Universal.p3d", 16, 13, 2, 0],
            "",
            "Billboard",
            1,
            _flareLife,
            _position,
            _velocity,
            0,
            _coreWeight,
            _coreVolume,
            _coreRubbing,
            _sizeCurve,
            _colorCurve,
            [1000],
            0.1,
            1,
            "",
            "",
            "",
            random (2 * pi),
            false,
            -1,
            [_emissiveColor, _emissiveColor, [0, 0, 0, 0]]
        ];

        private _light = "#lightpoint" createVehicleLocal [0, 0, 0];
        _light lightAttachObject [_flareParticle, [0, 0, 0]];
        _light setLightColor [1, 0.6, 0.5];
        _light setLightAmbient [0.8, 0.65, 0.5];
        _light setLightAttenuation [0, 1, 1, 1];
        _light setLightUseFlare true;
        _light setLightFlareSize 5;
        _light setLightFlareMaxDistance 4000;
        _light setLightIntensity 1500;

        private _unitFlareParticles = _unit getVariable ["DIS_flareParticles", []];
        _unitFlareParticles pushBack _flareParticle;
        _unit setVariable ["DIS_flareParticles", _unitFlareParticles];
    } forEach [-1, 1];

    if (_pair < _pairCount - 1) then {
        uiSleep _pairInterval;
    };
};
