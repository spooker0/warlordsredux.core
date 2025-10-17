#include "includes.inc"
params ["_smokeEntity"];

private _smokePos = _smokeEntity modelToWorld [0, 0, 0];
_smokePos set [2, 1];

private _smoke = createVehicle ["#particlesource", _smokePos, [], 0, "NONE"];
_smoke setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "", "Billboard", 1, 10, [0, 0, 0], [0, 0, 0.5], 0, 1.277, 1, 0.025, [1, 16, 24, 30], [[1, 1, 1, 0.7],[1, 1, 1, 0.5], [1, 1, 1, 0.25], [1, 1, 1, 0]], [0.2], 1, 0.04, "", "", _smoke];;
_smoke setParticleRandom [2, [0.3, 0.3, 0.3], [1.5, 1.5, 1], 20, 0.2, [0, 0, 0, 0.1], 0, 0, 360];
_smoke setDropInterval 0.4;

private _smoke2 = createVehicle ["#particlesource", _smokePos, [], 0, "NONE"];
_smoke2 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 12, 7, 0], "", "Billboard", 1, 5, [0, 0, 0], [0, 0, 0.5], 0, 1.277, 1, 0.025, [1, 16, 24, 30], [[1, 1, 1, 1],[1, 1, 1, 1], [1, 1, 1, 0.5], [1, 1, 1, 0]], [0.2], 1, 0.04, "", "", _smoke2];
_smoke2 setParticleRandom [2, [0.3, 0.3, 0.3], [1.5, 1.5, 1], 20, 0.2, [0, 0, 0, 0.1], 0, 0, 360];
_smoke2 setDropInterval 0.3;

uiSleep 45;

_smoke setDropInterval 0;
_smoke2 setDropInterval 0;