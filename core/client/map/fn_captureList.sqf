#include "..\..\warlords_constants.inc"

private _captureDisplay = uiNamespace getVariable ["RscWLCaptureDisplay", objNull];
if (isNull _captureDisplay) then {
	"CaptureDisplay" cutRsc ["RscWLCaptureDisplay", "PLAIN", -1, true, true];
	_captureDisplay = uiNamespace getVariable "RscWLCaptureDisplay";
};

private _indicator = _captureDisplay displayCtrl 7005;
private _indicatorBackground = _captureDisplay displayCtrl 7004;
_indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0.7];

while { !BIS_WL_missionEnd } do {
	sleep WL_TIMEOUT_STANDARD;

	private _side = BIS_WL_playerSide;
	private _sectorsBeingCaptured = BIS_WL_allSectors select {
		private _isBeingCaptured = _x getVariable ["BIS_WL_captureProgress", 0] > 0;
		private _revealed = _side in (_x getVariable ["BIS_WL_revealedBy", []]) || _side == independent || WL_IsSpectator || WL_IsReplaying;
		_isBeingCaptured && _revealed;
	};

	if (count _sectorsBeingCaptured == 0) then {
		_indicator ctrlSetText "";
		_indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0];
		continue;
	};

	private _captureIndicatorText = format ["<t size='1.8'>%1</t><br/>", localize "STR_WL2_CAPTURE_PROGRESS"];
	{
		private _sectorName = _x getVariable "WL2_name";
		private _capturingTeam = _x getVariable ["BIS_WL_capturingTeam", independent];
		private _captureProgress = _x getVariable ["BIS_WL_captureProgress", 0];
		private _defendingTeam = _x getVariable ["BIS_WL_owner", independent];
		private _displayPercent = (_captureProgress * 100) toFixed 1;
		private _captureColor = switch (_capturingTeam) do {
			case west: { "#004d99" };
			case east: { "#ff4b4b" };
			case independent: { "#00a300" };
		};
		private _defendColor = switch (_defendingTeam) do {
			case west: { "#004d99" };
			case east: { "#ff4b4b" };
			case independent: { "#00a300" };
		};
		private _captureBar = "";
		private _totalBars = 15;
		private _barProgress = (round (_captureProgress * _totalBars)) max 1;
		private _attackBar = "";
		private _defendBar = "";
		for "_i" from 1 to _totalBars do {
			if (_i <= _barProgress) then {
				_attackBar = _attackBar + "=";
			} else {
				_defendBar = _defendBar + "=";
			};
			if (_i == _barProgress) then {
				_attackBar = _attackBar + "|";
			};
		};
		_captureBar = format ["<t font='EtelkaMonospaceProBold' size='0.9'>[<t color='%1'>%2</t><t color='%3'>%4</t>]</t>", _captureColor, _attackBar, _defendColor, _defendBar];
		_captureIndicatorText = _captureIndicatorText + format [
			"<t size='1.2' shadow='2' color='%1'>%2 %3%4</t><br/>%5<br/>",
			_captureColor, _sectorName, _displayPercent, "%", _captureBar
		];
	} forEach _sectorsBeingCaptured;

	_indicator ctrlSetStructuredText (parseText _captureIndicatorText);
	_indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0.7];
	_indicatorBackground ctrlSetPositionH (0.09 + (count _sectorsBeingCaptured) * 0.08);
	_indicatorBackground ctrlCommit 0;
};