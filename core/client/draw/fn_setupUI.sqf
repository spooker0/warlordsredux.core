#include "includes.inc"
params ["_displayClass"];

waitUntil {!isNull (findDisplay 46)};

private _side = BIS_WL_playerSide;
if (_displayClass == "RequestMenu_open") then {
	WL2_tutorialComplete = true;
	if (WL_GEAR_BUY_MENU) exitWith {};
	if (lifeState player == "INCAPACITATED") exitWith {};

	disableSerialization;

	WL_GEAR_BUY_MENU = true;

	hintSilent "";

	_xDef = safezoneX;
	_yDef = safezoneY;
	_wDef = safezoneW;
	_hDef = safezoneH;

	_myDisplay = (findDisplay 46) createDisplay "RscDisplayEmpty";

	WL_CONTROL_MAP ctrlEnable false;

	_myDisplay displayAddEventHandler ["Unload", {
		_display = _this # 0;
		uiNamespace setVariable ["BIS_WL_purchaseMenuLastSelection", [lbCurSel (_display displayCtrl 100), lbCurSel (_display displayCtrl 101), lbCurSel (_display displayCtrl 109)]];
		if (ctrlEnabled (_display displayCtrl 120)) then {
			playSound "AddItemFailed";
		};
		WL_GEAR_BUY_MENU = false;
		WL_CONTROL_MAP ctrlEnable true;
		hint "";
	}];

	uiNamespace setVariable ["WL_BuyMenuCode", ""];
	_myDisplay displayAddEventHandler ["KeyDown", {
		private _key = _this # 1;
		[_key] call WL2_fnc_handleBuyMenuKeypress;
	}];

	_myDisplay spawn {
		disableSerialization;
		waitUntil {uiSleep WL_TIMEOUT_SHORT; lifeState player == "INCAPACITATED" || {isNull _this}};
		"RequestMenu_close" call WL2_fnc_setupUI;
	};

	_myDisplay displayAddEventHandler ["KeyUp", {
		_key = _this # 1;
		if (_key in actionKeys "Gear") then {
			WL_gearKeyPressed = false;
		};
	}];

	private _purchase_background = _myDisplay ctrlCreate ["RscText", -1];
	private _purchase_title_assets = _myDisplay ctrlCreate ["RscStructuredText", -1];
	private _purchase_title_details = _myDisplay ctrlCreate ["RscStructuredText", -1];

	private _purchase_frame = _myDisplay ctrlCreate ["RscPicture", -1];
	private _purchase_frame_top = _myDisplay ctrlCreate ["RscPicture", -1];
	private _purchase_frame_bottom = _myDisplay ctrlCreate ["RscPicture", -1];
	private _purchase_frame_left = _myDisplay ctrlCreate ["RscPicture", -1];
	private _purchase_frame_right = _myDisplay ctrlCreate ["RscPicture", -1];
	private _purchase_frame_topleft = _myDisplay ctrlCreate ["RscPicture", -1];
	private _purchase_frame_topright = _myDisplay ctrlCreate ["RscPicture", -1];
	private _purchase_frame_bottomleft = _myDisplay ctrlCreate ["RscPicture", -1];
	private _purchase_frame_bottomright = _myDisplay ctrlCreate ["RscPicture", -1];

	private _purchase_info_asset_container = _myDisplay ctrlCreate ["RscControlsGroup", 106];

	private _purchase_category = _myDisplay ctrlCreate ["RscListBox", 100];
	private _purchase_items = _myDisplay ctrlCreate ["RscListBox", 101];
	private _purchase_pic = _myDisplay ctrlCreate ["RscStructuredText", 102];
	private _purchase_info = _myDisplay ctrlCreate ["RscStructuredText", 103];
	private _purchase_info_asset = _myDisplay ctrlCreate ["RscStructuredText", 105, _purchase_info_asset_container];
	private _purchase_request = _myDisplay ctrlCreate ["RscStructuredText", 107];
	private _purchase_transfer_background = _myDisplay ctrlCreate ["RscText", 115];
	private _purchase_transfer_units = _myDisplay ctrlCreate ["RscListBox", 116];
	private _purchase_transfer_amount = _myDisplay ctrlCreate ["RscEdit", 117];
	private _purchase_transfer_slider = _myDisplay ctrlCreate ["RscXSliderH", 118];
	private _purchase_transfer_ok = _myDisplay ctrlCreate ["RscStructuredText", 119];
	private _purchase_transfer_cancel = _myDisplay ctrlCreate ["RscStructuredText", 120];

	uiNamespace setVariable ["BIS_WL_purchaseMenuDisplay", _myDisplay];

	_purchase_background ctrlSetPosition [_xDef + (_wDef / 4), _yDef + (_hDef * 0.15), _wDef / 2, _hDef * 0.7];
	_purchase_title_assets ctrlSetPosition [_xDef + (_wDef / 4), _yDef + (_hDef * 0.15), _wDef / 4, _hDef * 0.045];
	_purchase_title_details ctrlSetPosition [_xDef + (_wDef / 2), _yDef + (_hDef * 0.15), _wDef / 4, _hDef * 0.045];

	_purchase_frame ctrlSetPosition [_xDef + (_wDef / 4), _yDef + (_hDef * 0.15), _wDef / 2, _hDef * 0.7];
	_purchase_frame_top ctrlSetPosition [_xDef + (_wDef * 0.25), _yDef + (_hDef * 0.117), _wDef * 0.5, _hDef * 0.05];
	_purchase_frame_bottom ctrlSetPosition [_xDef + (_wDef * 0.25), _yDef + (_hDef * 0.834), _wDef * 0.5, _hDef * 0.05];
	_purchase_frame_left ctrlSetPosition [_xDef + (_wDef * 0.227), _yDef + (_hDef * 0.15), _wDef * 0.035, _hDef * 0.7];
	_purchase_frame_right ctrlSetPosition [_xDef + (_wDef * 0.739), _yDef + (_hDef * 0.15), _wDef * 0.035, _hDef * 0.7];
	_purchase_frame_topleft ctrlSetPosition [_xDef + (_wDef * 0.227), _yDef + (_hDef * 0.117), _wDef * 0.035, _hDef * 0.05];
	_purchase_frame_topright ctrlSetPosition [_xDef + (_wDef * 0.739), _yDef + (_hDef * 0.117), _wDef * 0.035, _hDef * 0.05];
	_purchase_frame_bottomleft ctrlSetPosition [_xDef + (_wDef * 0.227), _yDef + (_hDef * 0.834), _wDef * 0.035, _hDef * 0.05];
	_purchase_frame_bottomright ctrlSetPosition [_xDef + (_wDef * 0.739), _yDef + (_hDef * 0.834), _wDef * 0.035, _hDef * 0.05];

	_purchase_info_asset_container ctrlSetPosition [_xDef + (_wDef * 0.5), _yDef + (_hDef * 0.425), _wDef * 0.25, _hDef * 0.27];

	_purchase_category ctrlSetPosition [_xDef + (_wDef / 4), _yDef + (_hDef * 0.195), _wDef * 3 / 32, _hDef * 0.5];
	_purchase_items ctrlSetPosition [_xDef + (_wDef * 11 / 32), _yDef + (_hDef * 0.195), _wDef * 5 / 32, _hDef * 0.5];
	_purchase_info ctrlSetPosition [_xDef + (_wDef / 4), _yDef + (_hDef * 0.695), _wDef / 2, _hDef * 0.11];
	_purchase_pic ctrlSetPosition [_xDef + (_wDef * 0.5), _yDef + (_hDef * 0.195), _wDef * 0.25, _hDef * 0.23];
	_purchase_info_asset ctrlSetPosition [0, 0, _wDef * 0.25, 1];
	_purchase_request ctrlSetPosition [_xDef + (_wDef / 4), _yDef + (_hDef * 0.805), _wDef / 2, _hDef * 0.045];
	_purchase_transfer_background ctrlSetPosition [_xDef + (_wDef / 3), _yDef + (_hDef / 3), _wDef / 3, _hDef / 3];
	_purchase_transfer_units ctrlSetPosition [_xDef + (_wDef / 3), _yDef + (_hDef / 3), _wDef / 6, _hDef / 3];
	_purchase_transfer_amount ctrlSetPosition [_xDef + (_wDef / 3) + (_wDef / 6), _yDef + (_hDef * 0.425), _wDef / 6.5, _hDef * 0.035];
	_purchase_transfer_slider ctrlSetPosition [_xDef + (_wDef / 3) + (_wDef / 6), _yDef + (_hDef * 0.46), _wDef / 6.5, _hDef * 0.025];
	_purchase_transfer_ok ctrlSetPosition [_xDef + (_wDef / 3) + (_wDef / 6), _yDef + (_hDef * 0.5502), _wDef / 6.5, _hDef * 0.035];
	_purchase_transfer_cancel ctrlSetPosition [_xDef + (_wDef / 3) + (_wDef / 6), _yDef + (_hDef * 0.59), _wDef / 6.5, _hDef * 0.035];

	_purchase_frame ctrlSetText "a3\ui_f\data\igui\rsctitles\interlacing\interlacing_ca.paa";
	_purchase_frame_top ctrlSetText "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_T_ca.paa";
	_purchase_frame_bottom ctrlSetText "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_B_ca.paa";
	_purchase_frame_left ctrlSetText "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_L_ca.paa";
	_purchase_frame_right ctrlSetText "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_R_ca.paa";
	_purchase_frame_topleft ctrlSetText "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TL_ca.paa";
	_purchase_frame_topright ctrlSetText "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TR_ca.paa";
	_purchase_frame_bottomleft ctrlSetText "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BL_ca.paa";
	_purchase_frame_bottomright ctrlSetText "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BR_ca.paa";

	private _listBoxTextHeight = (0.03 call WL2_fnc_purchaseMenuGetUIScale) min 0.05;
	_purchase_category ctrlSetFontHeight _listBoxTextHeight;
	_purchase_items ctrlSetFontHeight _listBoxTextHeight;

	{_x ctrlSetFade 1; _x ctrlEnable false; _x ctrlCommit 0} forEach [
		_purchase_transfer_background,
		_purchase_transfer_units,
		_purchase_transfer_amount,
		_purchase_transfer_slider,
		_purchase_transfer_ok,
		_purchase_transfer_cancel
	];

	{_x ctrlCommit 0} forEach [
		_purchase_frame_top,
		_purchase_frame_bottom,
		_purchase_frame_left,
		_purchase_frame_right,
		_purchase_frame_topleft,
		_purchase_frame_topright,
		_purchase_frame_bottomleft,
		_purchase_frame_bottomright
	];

	{_x ctrlEnable false; _x ctrlCommit 0} forEach [
		_purchase_background,
		_purchase_title_assets,
		_purchase_title_details,
		_purchase_info,
		_purchase_pic,
		_purchase_info_asset,
		_purchase_frame
	];

	{_x ctrlCommit 0} forEach [
		_purchase_category,
		_purchase_items,
		_purchase_request,
		_purchase_info_asset_container
	];

	_purchase_background ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];
	_purchase_title_assets ctrlSetBackgroundColor [0, 0, 0, 0.5];
	_purchase_title_details ctrlSetBackgroundColor [0, 0, 0, 0.5];
	_purchase_info ctrlSetBackgroundColor [0, 0, 0, 0.3];
	_purchase_pic ctrlSetBackgroundColor [0, 0, 0, 0.3];
	_purchase_info_asset ctrlSetBackgroundColor [0, 0, 0, 0.3];
	_purchase_request ctrlSetBackgroundColor BIS_WL_colorFriendly;
	_purchase_transfer_background ctrlSetBackgroundColor [0, 0, 0, 1];
	_purchase_transfer_ok ctrlSetBackgroundColor BIS_WL_colorFriendly;
	_purchase_transfer_cancel ctrlSetBackgroundColor BIS_WL_colorFriendly;
	_purchase_transfer_amount ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
	_purchase_transfer_slider ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];

	{_x ctrlSetTextColor [0.65, 0.65, 0.65, 1]} forEach [
		_purchase_title_assets,
		_purchase_title_details,
		_purchase_info,
		_purchase_info_asset
	];

	_purchase_title_assets ctrlSetStructuredText parseText format ["<t size = '%2' align = 'center' shadow = '2'>%1</t>", localize "STR_A3_WL_purchase_menu_title_assets", (1.5 call WL2_fnc_purchaseMenuGetUIScale)];
	_purchase_title_details ctrlSetStructuredText parseText format ["<t size = '%2' align = 'center' shadow = '2'>%1</t>", localize "STR_A3_WL_purchase_menu_title_detail", (1.5 call WL2_fnc_purchaseMenuGetUIScale)];
	_purchase_request ctrlSetStructuredText parseText format ["<t font = 'PuristaLight' align = 'center' shadow = '2' size = '%2'>%1</t>", toUpper localize "STR_A3_WL_menu_request", (1.75 call WL2_fnc_purchaseMenuGetUIScale)];
	_purchase_transfer_ok ctrlSetStructuredText parseText format ["<t align = 'center' shadow = '2' size = '%2'>%1</t>", localize "STR_A3_WL_button_transfer", (1.25 call WL2_fnc_purchaseMenuGetUIScale)];
	_purchase_transfer_cancel ctrlSetStructuredText parseText format ["<t align = 'center' shadow = '2' size = '%2'>%1</t>", localize "STR_disp_cancel", (1.25 call WL2_fnc_purchaseMenuGetUIScale)];

	{
		private _gearCode = "";
		private _zeroes = _forEachIndex / 9;
		for "_i" from 1 to _zeroes do {
			_gearCode = _gearCode + "0";
		};
		private _tailNumber = _forEachIndex % 9 + 1;
		_gearCode = _gearCode + str _tailNumber;

		if (count (WL_PLAYER_REQUISITION_LIST # _forEachIndex) > 0) then {
			_purchase_category lbAdd format ["%1 [%2]", _x, _gearCode];
		};
		_purchase_category lbSetValue [(lbSize _purchase_category) - 1, _forEachIndex];
	} forEach [
		localize "STR_A3_cfgmarkers_nato_inf",
		localize "STR_A3_WL_LightVehicles",
		localize "STR_A3_WL_HeavyVehicles",
		localize "STR_A3_WL_RotaryWing",
		localize "STR_A3_WL_FixedWing",
		localize "STR_A3_WL_RemoteControl",
		localize "STR_A3_WL_AirDefense",
		localize "STR_A3_WL_SectorDefense",
		localize "STR_A3_WL_Structures",
		localize "STR_A3_rscdisplaygarage_tab_naval",
		localize "STR_A3_rscdisplaywelcome_exp_parb_list4_title",
		"Fast Travel",
		localize "STR_A3_WL_menu_strategy"
	];
	_purchase_category lbSetCurSel ((uiNamespace getVariable ["BIS_WL_purchaseMenuLastSelection", [0, 0, 0]]) # 0);
	_purchase_category ctrlAddEventHandler ["LBSelChanged", {
		(_this # 1) call WL2_fnc_purchaseMenuSetItemsList;
	}];

	_purchase_items ctrlAddEventHandler ["LBSelChanged", {
		call WL2_fnc_purchaseMenuSetAssetDetails;
	}];

	_purchase_items ctrlAddEventHandler ["LBDblClick", {
		params ["_control", "_selectedIndex"];
		private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
		private _purchase_category = _display displayCtrl 100;
		private _category = WL_REQUISITION_CATEGORIES # ((lbCurSel _purchase_category) max 0);
		private _cost = _control lbValue _selectedIndex;
		if (isNil "_cost") then {
			_cost = 0;
		};
		private _assetDetails = (_control lbData _selectedIndex) splitString "|||";
		_assetDetails set [6, _cost];
		_assetDetails set [7, _category];
		_assetDetails call WL2_fnc_purchaseFromMenu;
	}];

	_purchase_request ctrlAddEventHandler ["MouseEnter", {
		_button = _this # 0;
		if (uiNamespace getVariable ["BIS_WL_purchaseMenuItemAffordable", false]) then {
			_color = BIS_WL_colorFriendly;
			_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
			uiNamespace setVariable ["BIS_WL_purchaseMenuButtonHover", true];
			playSound "click";
		};
	}];
	_purchase_request ctrlAddEventHandler ["MouseExit", {
		_button = _this # 0;
		_color = BIS_WL_colorFriendly;
		if (uiNamespace getVariable ["BIS_WL_purchaseMenuItemAffordable", false]) then {
			_button ctrlSetTextColor [1, 1, 1, 1];
			_button ctrlSetBackgroundColor _color;
		} else {
			_button ctrlSetTextColor [0.5, 0.5, 0.5, 1];
			_button ctrlSetBackgroundColor [(_color # 0) * 0.5, (_color # 1) * 0.5, (_color # 2) * 0.5, _color # 3];
		};
		uiNamespace setVariable ["BIS_WL_purchaseMenuButtonHover", false];
	}];
	_purchase_request ctrlAddEventHandler ["MouseButtonDown", {
		if (uiNamespace getVariable ["BIS_WL_purchaseMenuItemAffordable", false]) then {
			_button = _this # 0;
			_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
		};
	}];
	_purchase_request ctrlAddEventHandler ["MouseButtonUp", {
		if (uiNamespace getVariable ["BIS_WL_purchaseMenuItemAffordable", false]) then {
			_button = _this # 0;
			_button ctrlSetTextColor [1, 1, 1, 1];
		};
	}];
	_purchase_request ctrlAddEventHandler ["ButtonClick", {
		private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
		private _purchase_category = _display displayCtrl 100;
		private _category = WL_REQUISITION_CATEGORIES # ((lbCurSel _purchase_category) max 0);
		private _purchase_items = _display displayCtrl 101;
		private _curSel = (lbCurSel _purchase_items) max 0;
		private _cost = _purchase_items lbValue _curSel;
		if (isNil "_cost") then {
			_cost = 0;
		};
		private _assetDetails = (_purchase_items lbData _curSel) splitString "|||";
		_assetDetails set [6, _cost];
		_assetDetails set [7, _category];
		_assetDetails call WL2_fnc_purchaseFromMenu;
	}];

	_purchase_transfer_slider ctrlAddEventHandler ["SliderPosChanged", {
		params ["_control", "_newValue"];
		private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
		private _purchase_transfer_amount = _display displayCtrl 117;
		_purchase_transfer_amount ctrlSetText (str _newValue);
	}];

	_purchase_transfer_ok ctrlAddEventHandler ["MouseEnter", {
		if (uiNamespace getVariable ["BIS_WL_fundsTransferPossible", false]) then {
			_button = _this # 0;
			_color = BIS_WL_colorFriendly;
			_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
			playSound "click";
		};
	}];
	_purchase_transfer_ok ctrlAddEventHandler ["MouseExit", {
		if (uiNamespace getVariable ["BIS_WL_fundsTransferPossible", false]) then {
			_button = _this # 0;
			_color = BIS_WL_colorFriendly;
			_button ctrlSetTextColor [1, 1, 1, 1];
			_button ctrlSetBackgroundColor _color;
		};
	}];
	_purchase_transfer_ok ctrlAddEventHandler ["MouseButtonDown", {
		if (uiNamespace getVariable ["BIS_WL_fundsTransferPossible", false]) then {
			_button = _this # 0;
			_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
		};
	}];
	_purchase_transfer_ok ctrlAddEventHandler ["MouseButtonUp", {
		if (uiNamespace getVariable ["BIS_WL_fundsTransferPossible", false]) then {
			_button = _this # 0;
			_button ctrlSetTextColor [1, 1, 1, 1];
		};
	}];
	_purchase_transfer_ok ctrlAddEventHandler ["ButtonClick", {
		if (uiNamespace getVariable ["BIS_WL_fundsTransferPossible", false]) then {
			_display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
			_targetName = (_display displayCtrl 116) lbText lbCurSel (_display displayCtrl 116);
			_amount = (parseNumber ctrlText (_display displayCtrl 117)) min ((missionNamespace getVariable "fundsDatabaseClients") get (getPlayerUID player));
			_targetArr = allPlayers select {name _x == _targetName};
			if (count _targetArr > 0) then {
				playSound "AddItemOK";
				_target = _targetArr # 0;

				private _transfers = profileNamespace getVariable ["WL2_playerTransfers", createHashMap];
				private _existingAmount = _transfers getOrDefault [_targetName, 0];
				_transfers set [_targetName, _existingAmount + _amount];
				profileNamespace setVariable ["WL2_playerTransfers", _transfers];

				[player, "fundsTransfer", _amount, _target] remoteExec ["WL2_fnc_handleClientRequest", 2];
				_i = 100;
				for "_i" from 100 to 114 do {
					(_display displayCtrl _i) ctrlEnable true;
				};
				_i = 115;
				for "_i" from 115 to 120 do {
					(_display displayCtrl _i) ctrlEnable false;
					(_display displayCtrl _i) ctrlSetFade 1;
					(_display displayCtrl _i) ctrlCommit 0;
				};
			} else {
				playSound "AddItemFailed";
			};
		};
	}];

	_purchase_transfer_cancel ctrlAddEventHandler ["MouseEnter", {
		_button = _this # 0;
		_color = BIS_WL_colorFriendly;
		_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
		playSound "click";
	}];
	_purchase_transfer_cancel ctrlAddEventHandler ["MouseExit", {
		_button = _this # 0;
		_color = BIS_WL_colorFriendly;
		_button ctrlSetTextColor [1, 1, 1, 1];
		_button ctrlSetBackgroundColor _color;
	}];
	_purchase_transfer_cancel ctrlAddEventHandler ["MouseButtonDown", {
		_button = _this # 0;
		_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
	}];
	_purchase_transfer_cancel ctrlAddEventHandler ["MouseButtonUp", {
		_button = _this # 0;
		_button ctrlSetTextColor [1, 1, 1, 1];
	}];
	_purchase_transfer_cancel ctrlAddEventHandler ["ButtonClick", {
		_display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
		_i = 100;
		for "_i" from 100 to 114 do {
			(_display displayCtrl _i) ctrlEnable true;
		};
		_i = 115;
		for "_i" from 115 to 120 do {
			(_display displayCtrl _i) ctrlEnable false;
			(_display displayCtrl _i) ctrlSetFade 1;
			(_display displayCtrl _i) ctrlCommit 0;
		};
		playSound "AddItemFailed";
	}];
	((uiNamespace getVariable ["BIS_WL_purchaseMenuLastSelection", [0, 0, 0]]) # 0) call WL2_fnc_purchaseMenuSetItemsList;
} else {
	if (_displayClass == "RequestMenu_close") then {
		(uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull]) closeDisplay 1;
	};
};