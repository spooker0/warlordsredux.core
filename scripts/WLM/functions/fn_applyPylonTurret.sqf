params ["_asset", "_pylonLoadout"];
[_asset, _pylonLoadout] remoteExec ["setPylonLoadout", _asset turretOwner [0], true];