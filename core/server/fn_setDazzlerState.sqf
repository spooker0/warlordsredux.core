params ["_asset", "_state"];

if (local _asset) then {
    _asset engineOn _state;
} else {
    [_asset, _state] remoteExec ["engineOn", _asset];
};