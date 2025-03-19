if (player getVariable ["WL2_rappelling", false]) exitWith {
    objNull
};

if (vehicle player != player) exitWith {
    objNull
};

private _ropes = missionNamespace getVariable ["WL2_rappelRopes", []];
private _ropesInRange = _ropes select {
    _x distance2D player < 5
};
if (count _ropesInRange > 0) then {
    _ropesInRange # 0
} else {
    objNull
};