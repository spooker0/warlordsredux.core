#include "includes.inc"
params ["_asset"];

private _actionId = _asset addAction [
	"<t color='#00FF00'>Smoke Curtain</t>",
	{
		params ["_asset", "_caller", "_actionId"];
        _asset setVariable ['WL2_smokeCurtains', (_asset getVariable ['WL2_smokeCurtains', 0]) - 1];

        [_asset] spawn {
            params ["_asset"];

            private _smokeGrenades = [];
            private _grenadesLeft = 60;
            while { _grenadesLeft > 0 } do {
                private _smokeGrenade = createVehicle ["SmokeShell", _asset modelToWorld [0, -7, 1], [], 0, "FLY"];
                [_smokeGrenade] remoteExec ["WL2_fnc_smokeCurtainParticles", 0, true];
                _smokeGrenades pushBack _smokeGrenade;
                uiSleep 1;
                _grenadesLeft = _grenadesLeft - 1;
            };

            {
                deleteVehicle _x;
            } forEach _smokeGrenades;
        };
	},
	[],
	10,
	false,
	false,
	"",
	"vehicle _this == _target && _target getVariable ['WL2_smokeCurtains', 0] > 0",
	30,
	false
];