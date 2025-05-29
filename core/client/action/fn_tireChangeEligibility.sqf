params ["_target", "_caller"];

if (!local _target) exitWith {
    false
};

if (!alive _target) exitWith {
    false
};

if (player != _caller) exitWith {
    false
};

if (cursorObject != _target) exitWith {
    false
};

if (vehicle _caller != _caller) exitWith {
    false
};

private _allHitPoints = getAllHitPointsDamage _target;
if (count _allHitPoints == 0) exitWith {};
private _validHitPoints = _allHitPoints select 0 select {
    _x regexMatch "hit.*wheel" || _x regexMatch "hit.*track";
};

private _anyDamaged = false;
{
    if (_target getHitPointDamage _x != 0) then {
        _anyDamaged = true;
        break;
    };
} forEach _validHitPoints;

_anyDamaged;