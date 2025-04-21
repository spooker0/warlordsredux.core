#include "..\..\warlords_constants.inc"

while { !BIS_WL_missionEnd } do {
	if (isNull WL_CONTROL_MAP) then {
		uiSleep 0.01;
		continue;
	};

	private _controlMap = ctrlParent WL_CONTROL_MAP;
	private _sectorInfoBox = _controlMap getVariable ["BIS_sectorInfoBox", controlNull];
	if (isNull _sectorInfoBox) then {
		_sectorInfoBox = _controlMap ctrlCreate ["RscStructuredText", 9999000];
		_controlMap setVariable ["BIS_sectorInfoBox", _sectorInfoBox];
		_sectorInfoBox ctrlSetBackgroundColor [0, 0, 0, 0];
		_sectorInfoBox ctrlSetTextColor [1, 1, 1, 1];
		_sectorInfoBox ctrlEnable false;
	};

	private _assetInfoBox = _controlMap getVariable ["BIS_assetInfoBox", controlNull];
	if (isNull _assetInfoBox) then {
		_assetInfoBox = _controlMap ctrlCreate ["RscStructuredText", 9999001];
		_controlMap setVariable ["BIS_assetInfoBox", _assetInfoBox];
		_assetInfoBox ctrlSetBackgroundColor [0, 0, 0, 0];
		_assetInfoBox ctrlSetTextColor [1, 1, 1, 1];
		_assetInfoBox ctrlEnable false;
	};

	uiSleep 0.01;
};