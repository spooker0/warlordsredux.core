params ["_asset"];

private _assetConfig = configFile >> "CfgVehicles" >> typeOf _asset;
private _pylonConfig = _assetConfig >> "Components" >> "TransportPylonsComponent";
private _isAircraft = !(isNull _pylonConfig);

if (!_isAircraft) exitWith {
    _asset setVariable ["WLM_assetCanRearm", true, true];
};

private _turrets = [[-1]] + allTurrets _asset;

if (count _turrets == 1) exitWith {
    _asset setVariable ["WLM_assetCanRearm", true, true];
};

while { alive _asset } do {
    private _turretLocalities = [];
    {
        private _locality = _asset turretOwner _x;
        _turretLocalities pushBackUnique _locality;
    } forEach _turrets;

    private _turretLocalityMatch = count _turretLocalities == 1;

    private _assetCanRearm = _asset getVariable ["WLM_assetCanRearm", false];
    if (_assetCanRearm != _turretLocalityMatch) then {
        _asset setVariable ["WLM_assetCanRearm", _turretLocalityMatch, true];
    };

    sleep 0.5;
};