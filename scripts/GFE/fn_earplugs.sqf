//________________	Author : GEORGE FLOROS [GR]	___________	29.03.19	___________
/*
________________	GF Earplugs Script - Mod	________________
https://forums.bohemia.net/forums/topic/215844-gf-earplugs-script-mod/
*/

disableSerialization;

waitUntil {
	sleep 1;
	!(isNull (findDisplay 46))
};

private _display = findDisplay 46;
_display displayAddEventHandler["KeyDown", {
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
	private _toggleKey = 0xD2;
	if (_key != _toggleKey) exitWith {};
	if (_alt) then {
		private _oldValue = player getVariable ["WL_ViewRangeReduced", false];
		if (_oldValue) then {
			"ViewRange" cutText ["", "PLAIN"];
			titleText ["<t color='#339933' size='2'font='PuristaBold'>CQB MODE OFF</t>", "PLAIN DOWN", -1, true, true];
			player setVariable ["WL_ViewRangeReduced", false];
			0 spawn MRTM_fnc_updateViewDistance;
		} else {
			"ViewRange" cutRsc ["RscViewRangeReduce", "PLAIN"];
			titleText ["<t color='#FF3333' size='2'font='PuristaBold'>CQB MODE ON</t>", "PLAIN DOWN", -1, true, true];
			player setVariable ["WL_ViewRangeReduced", true];
			0 spawn MRTM_fnc_updateViewDistance;
		};
	} else {
		["TaskEarplugs"] call WLT_fnc_taskComplete;
		if (soundVolume != 0.1) then {
			"GF_Earplugs" cutRsc ["Rsc_GF_Earplugs", "PLAIN"];
			titleText ["<t color='#339933' size='2'font='PuristaBold'>EARPLUGS IN</t>", "PLAIN DOWN", -1, true, true];
			0 fadeSound 0.1;
		} else {
			"GF_Earplugs" cutText ["", "PLAIN"];
			titleText ["<t color='#FF3333' size='2'font='PuristaBold'>EARPLUGS OUT</t>", "PLAIN DOWN", -1, true, true];
			0 fadeSound 1;
		};
	};
}];