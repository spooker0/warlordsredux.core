params ["_asset", "_side"];

if (!isRemoteExecutedJIP && side group player != _side) then {
	[_asset] spawn {
		params ["_asset"];

		systemChat "Enemy long-range air defenses detected.";

		private _warningDisplay = uiNamespace getVariable ["RscWLExtendedSamWarningDisplay", displayNull];
		if (isNull _warningDisplay) then {
			"SamWarning" cutRsc ["RscWLExtendedSamWarningDisplay", "PLAIN", -1, true, true];
			_warningDisplay = uiNamespace getVariable ["RscWLExtendedSamWarningDisplay", displayNull];
		};

		private _warningTextDisplay = _warningDisplay displayCtrl 14300;

		private _endTime = serverTime + 120;
		private _enemySide = BIS_WL_enemySide;
		while { alive _asset && alive player && serverTime < _endTime } do {
			if !(cameraOn isKindOf "Air") then {
				_warningTextDisplay ctrlSetText "";
				sleep 2;
				continue;
			};

			private _enemyDatalinkList = (listRemoteTargets _enemySide) apply { _x # 0 };
			private _warningText = if (cameraOn in _enemyDatalinkList) then {
				"ENEMY LONG-RANGE AIR DEFENSE DETECTED!<br/>YOU ARE BEING TRACKED!";
			} else {
				"ENEMY LONG-RANGE AIR DEFENSE DETECTED!<br/>STAY OUT OF ENEMY AIRSPACE!";
			};
			private _timeRemaining = _endTime - serverTime;

			_warningTextDisplay ctrlSetStructuredText parseText format [
				"<t size='2.2' align='center'>%1</t><br/><t size='4' align='center' color='#ff0000' shadow='0'>%2</t>",
				_warningText,
				round _timeRemaining
			];
			sleep 0.01;
		};

		"SamWarning" cutText ["", "PLAIN"];
		systemChat "Enemy long-range air defenses active.";
	};
};

private _waitActionId = _asset addAction [
	"<t color='#00ffcc'>WAIT</t>",
	{},
	[],
	100,
	true,
	false,
	"",
	"_target == cameraOn",
	50,
	false
];

sleep 120;
_asset removeAction _waitActionId;

private _actionID = _asset addAction [
	"<t color='#00ffcc'>Extended SAM Configuration</t>",
	DIS_fnc_setupExtendedSamMenu,
	[],
	100,
	true,
	false,
	"",
	"_target == cameraOn",
	50,
	false
];