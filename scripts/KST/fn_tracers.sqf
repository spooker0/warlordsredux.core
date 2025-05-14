params ["_projectile"];

private _blasterSound = getMissionPath format ["src\sounds\blaster%1.ogg", ceil (random 4)];

private _shotParent = getShotParents _projectile # 0;
private _blaster = if (isNull _shotParent) then {
    _projectile
} else {
    _shotParent
};
playSound3D [_blasterSound, _blaster];

private _color = if (isNull _shotParent) then {
    [0, 0, 1]
} else {
    if (side group _shotParent == west) then {
        [0, 1, 0]
    } else {
        [1, 0, 0]
    };
};

private _lightPoint =  createVehicleLocal ["#lightpoint", getPosATL _projectile, [], 0, "FLY"];
_lightPoint setLightAttenuation [0, 0, 100, 100];
_lightPoint setLightDayLight true;
_lightPoint setLightColor _color;
_lightPoint setLightAmbient _color;
_lightPoint setLightIntensity 200000;
_lightPoint setLightUseFlare true;
_lightPoint setLightFlareSize 1;
_lightPoint setLightFlareMaxDistance 3000;
_lightPoint attachTo [_projectile, [0, 0, 0]];

private _startTime = serverTime;
waitUntil {
    sleep 0.1;
    _lightPoint distance _projectile > 500 || serverTime - _startTime > 3 || speed _projectile < 0.1;
};
deleteVehicle _lightPoint;