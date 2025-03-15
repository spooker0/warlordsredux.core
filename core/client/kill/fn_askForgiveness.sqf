params ["_killer", "_victim"];

private _assetType = [_victim] call WL2_fnc_getAssetTypeName;
if (isNil "WL2_ffBuffer") then {
	WL2_ffBuffer = [];
	0 spawn {
		private _busy = false;
		while {!BIS_WL_missionEnd && {(count WL2_ffBuffer) > 0}} do {
			waitUntil {sleep 1; (count WL2_ffBuffer > 0) && {!_busy}};
			_busy = true;

			private _params = WL2_ffBuffer # 0;
			private _killer = _params # 0;
			private _victim = _params # 1;
			private _assetType = _params # 2;

			private _result = if (isPlayer _victim) then {
				private _askForgiveness = [
					"Forgive Friendly Fire",
					format ["Choose to forgive %1?", name _killer],
					"Forgive", "Don't forgive"
				] call WL2_fnc_prompt;

				WL2_ffBuffer deleteAt 0;
				_busy = false;
				_askForgiveness;
			} else {
				private _askForgiveness = [
					"Forgive Friendly Fire",
					format ["Choose to forgive %1 for killing %2?", name _killer, _assetType],
					"Forgive", "Don't forgive"
				] call WL2_fnc_prompt;

				WL2_ffBuffer deleteAt 0;
				_busy = false;
				_askForgiveness;
			};
			[_killer, player, _result, _victim] remoteExec ["WL2_fnc_forgiveTeamkill", 2];
		};
		WL2_ffBuffer = nil;
	};
};

WL2_ffBuffer pushBack [_killer, _victim, _assetType];