params ["_shooter", "_dazzled"];

private _reward = if (_dazzled) then {
    0
} else {
    50
};
private _rewardText = if (_dazzled) then {
    "Dazzler"
} else {
    "Active protection system"
};

private _shooterUid = _shooter getVariable ["BIS_WL_ownerAsset", "123"];
private _responsiblePlayer = _shooterUid call BIS_fnc_getUnitByUID;
if (isPlayer _responsiblePlayer) then {
    [_reward, _shooterUid] call WL2_fnc_fundsDatabaseWrite;
    [objNull, _reward, _rewardText, "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _responsiblePlayer];
};