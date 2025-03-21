while { !BIS_WL_missionEnd } do {
    sleep 5;
    private _laserTargets = entities "LaserTarget";

    private _playerOwnerIds = createHashMap;
    {
        _playerOwnerIds set [owner _x, _x];
    } forEach allPlayers;

    {
        private _laserTarget = _x;
        private _laserTargetOwner = owner _laserTarget;
        private _owner = _playerOwnerIds getOrDefault [_laserTargetOwner, objNull];
        if (_laserTarget getVariable ["WL_laserPlayer", objNull] != _owner) then {
            _laserTarget setVariable ["WL_laserPlayer", _owner, true];
        };
    } forEach _laserTargets;
};