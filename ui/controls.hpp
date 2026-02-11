class WL_Prompt_Dialog {
	idd = -1;
	movingEnable = true;
	class controls {
		class WL_Prompt_Draggable: IGUIBackMRTM {
			idc = 5701;
			x = 0.015;
			y = 0.263;
			w = 0.97;
			h = 0.05;
			colorBackground[] = {1, 0.5, 0, 1};
			moving = 1;
		};
		class WL_Prompt_Title : RscTextMRTM {
			idc = 5702;
			sizeEx = 0.04;
			x = 0.015;
			y = 0.263;
			w = 0.97;
			h = 0.05;
			font = "PuristaMedium";
			colorText[] = {1, 1, 1, 1};
			shadow = 0;
			style = ST_LEFT;
		};
		class WL_Prompt_Background: IGUIBackMRTM {
			idc = 5703;
			x = 0.015;
			y = 0.318;
			w = 0.97;
			h = 0.145;
			colorBackground[] = {0, 0, 0, 1};
		};
		class WL_Prompt_ConfirmButton: RscButtonMRTM {
			idc = 5704;
			sizeEx = 0.035;
			colorBackground[] = {0, 0, 0, 0.9};
			x = 0.015;
			y = 0.468;
			w = 0.145;
			h = 0.055;
			font = "PuristaMedium";
		};
		class WL_Prompt_ExitButton: RscButtonMRTM {
			idc = 5705;
			sizeEx = 0.035;
			colorBackground[] = {0, 0, 0, 0.9};
			x = 0.839;
			y = 0.469;
			w = 0.145;
			h = 0.055;
			font = "PuristaMedium";
		};
		class WL_Prompt_Text: RscStructuredText {
			idc = 5706;
			sizeEx = 0.035;
			x = 0.020;
			y = 0.328;
			w = 0.960;
			h = 0.145;
			font = "PuristaMedium";
			colorText[] = {1, 1, 1, 1};
			shadow = 0;
			style = ST_MULTI;
		};
		class WL_Prompt_MiddleBar: IGUIBackMRTM {
			idc = 5707;
			x = 0.165;
			y = 0.469;
			w = 0.669;
			h = 0.0545;
			colorBackground[] = {0, 0, 0, 1};
		};
	};
};

class WL_MapButtonDisplay {
	idd = -1;
	movingEnable = false;
	class controls {};
};

class WLDummyButton: RscButtonMenu {
	idc = 8002;
	x = 0;
	y = 0;
	w = 0;
	h = 0;
};

class WLRscButtonMenu: RscButtonMenu {
	soundClick[] = {"", 0, 1};
};

class WLRscInventoryButton: WLRscButtonMenu {
	colorBackground[] = {0, 0, 0, 1};
	colorBackgroundFocused[] = {0.5, 0.5, 0.5, 1};
	colorBackground2[] = {0.5, 0.5, 0.5, 1};

	color[] = {1, 1, 1, 1};
	color2[] = {1, 1, 1, 1};

	colorFocused[] = {1, 1, 1, 1};
	colorFocusedSecondary[] = {1, 1, 1, 1};

	colorText[] = {1, 1, 1, 1};

	colorSecondary[] = {1, 1, 1, 1};
	color2Secondary[] = {1, 1, 1, 1};
};

class WLRscInventoryCenterButton: WLRscInventoryButton {
	class TextPos {
		left = 0;
		top = 0;
		right = 0;
		bottom = 0;
		forceMiddle = true;
	};
};

class RscTextRight: RscText {
	colorBackground[] = {0.5, 0.5, 0.5, 1};
	shadow = 0;
	style = ST_RIGHT;
};

class RscSpectatorDisplay {
	idd = -1;
	class controls {
		class RscSpectatorDisplay_Map: RscMapControl {
			idc = 5503;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH;
		};
	};
};

class RscWLBrowserMenu {
	idd = 5500;
	class controls {
		class RscWLBrowserMenu_Texture: RscText {
			type = 106;
			idc = 5501;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH;
		};
	};
};

class RscWLSidePickerMenu {
	idd = 5500;
	class controls {
		class RscWLSidePickerMenu_Texture: RscText {
			type = 106;
			idc = 5501;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH;
			url = "file://src/ui/gen/picker.html";
			onKeyDown = "(_this select 1) isEqualTo 1";
		};
	};
};