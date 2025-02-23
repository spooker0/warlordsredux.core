params ["_carrierData"];

if (isDedicated) exitWith {};

private _rappelPairs = _carrierData # 4;

{
    private _marker = _x # 0;
    private _boat = _x # 1;
    private _tire = _x # 2;

    createMarkerLocal [_marker, _boat];
    _marker setMarkerTypeLocal "loc_Quay";
    _marker setMarkerTextLocal "Carrier Rappel Point";
    _marker setMarkerAlphaLocal 0;

    _boat lock true;
    _boat setPhysicsCollisionFlag false;

    _boat addAction [
        "<t color='#0000ff'>Rappel Up</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];

            private _boat = _arguments # 0;
            private _tire = _arguments # 1;
            [_caller, _boat, _tire, true] spawn WL2_fnc_rappel;
        },
        [_boat, _tire],
        6,
        true,
        true,
        "",
        "vehicle player == player && !(player getVariable ['WL2_rappelling', false])",
        20
    ];

    _tire addAction [
        "<t color='#0000ff'>Rappel Down</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];

            private _boat = _arguments # 0;
            private _tire = _arguments # 1;
            [_caller, _boat, _tire, false] spawn WL2_fnc_rappel;
        },
        [_boat, _tire],
        6,
        true,
        true,
        "",
        "vehicle player == player && !(player getVariable ['WL2_rappelling', false])",
        20
    ];

    [_boat] spawn {
        params ["_boat"];
        private _originalBoatPosition = getPosASL _boat;
        while { alive _boat } do {
            sleep 60;
            _boat setVehiclePosition [_originalBoatPosition, [], 0, "CAN_COLLIDE"];
        };
    };
} forEach _rappelPairs;