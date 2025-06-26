params ["_projectile"];
while { alive _projectile } do {
    sleep 0.05;
    if (_projectile getVariable ["WL2_jamDestroy", false]) then {
        triggerAmmo _projectile;
        break;
    };
};