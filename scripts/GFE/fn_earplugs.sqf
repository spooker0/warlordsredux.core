//________________	Author : GEORGE FLOROS [GR]	___________	29.03.19	___________
/*
________________	GF Earplugs Script - Mod	________________
https://forums.bohemia.net/forums/topic/215844-gf-earplugs-script-mod/
*/

params ["_displayNumber"];

disableSerialization;

waitUntil {
	sleep 1;
	!(isNull (findDisplay _displayNumber))
};

private _display = findDisplay _displayNumber;
_display displayAddEventHandler ["KeyDown", {
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
	if (_key == 0xD2) then {
		["TaskEarplugs"] call WLT_fnc_taskComplete;
		private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
		private _earplugVolume = _settingsMap getOrDefault ["earplugVolume", 0.1];

		if (soundVolume == 1) then {
			"GF_Earplugs" cutRsc ["Rsc_GF_Earplugs", "PLAIN"];
			titleText ["<t color='#339933' size='2'font='PuristaBold'>EARPLUGS IN</t>", "PLAIN DOWN", -1, true, true];
			0 fadeSound _earplugVolume;
		} else {
			"GF_Earplugs" cutText ["", "PLAIN"];
			titleText ["<t color='#FF3333' size='2'font='PuristaBold'>EARPLUGS OUT</t>", "PLAIN DOWN", -1, true, true];
			0 fadeSound 1;
		};
	};

	if (_key == 0xD3) then {
		private _oldValue = player getVariable ["WL_ViewRangeReduced", false];
		if (_oldValue) then {
			"ViewRange" cutText ["", "PLAIN"];
			titleText ["<t color='#339933' size='2'font='PuristaBold'>CQB MODE OFF</t>", "PLAIN DOWN", -1, true, true];
			player setVariable ["WL_ViewRangeReduced", false];
			0 spawn MENU_fnc_updateViewDistance;
		} else {
			"ViewRange" cutRsc ["RscViewRangeReduce", "PLAIN"];
			titleText ["<t color='#FF3333' size='2'font='PuristaBold'>CQB MODE ON</t>", "PLAIN DOWN", -1, true, true];
			player setVariable ["WL_ViewRangeReduced", true];
			0 spawn MENU_fnc_updateViewDistance;
		};
	};
}];