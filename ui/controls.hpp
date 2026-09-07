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

class WL_WelcomeDisplay {
	idd = -1;
	class controls {
		class WL_WelcomeDisplay_Background: RscText {
			idc = -1;
			x = 0;
			y = 0;
			w = 1;
			h = 1;
			colorBackground[] = {0.09, 0.09, 0.095, 1};
		};
		class WL_WelcomeDisplay_Text: RscStructuredText {
			idc = 100;
            text = "";
            x = 0.1;
            y = 0.1;
            w = 0.8;
            h = 0.8;
            size = 0.04;
		};
		class WL_WelcomeDisplay_ExitButton: RscButton {
			idc = 101;
			text = "A3\ui_f\data\map\groupicons\waypoint.paa";
            style = ST_CENTER + ST_PICTURE;
			x = 0.95;
			y = 0;
			w = 0.05;
			h = 0.05 * 4 / 3;
		};
		class WL_WelcomeDisplay_DiscordButton: RscButton {
			idc = 102;
			text = "Discord";
			url = "https://discord.gg/grmzsZE4ua";
			x = 0.1;
			y = 0.9;
			w = 0.8;
			h = 0.05;
		};
	};
};

class RscWLSideButton: RscShortcutButton {
	animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureDisabled = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureOver = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)";
	animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)";
	colorBackground[] = {0, 0, 0, 0.8};
	color[] = {1, 1, 1, 1};
	colorFocused[] = {1, 1, 1, 1};
	color2[] = {1, 1, 1, 1};
	colorText[] = {1, 1, 1, 1};
	colorDisabled[] = {1, 1, 1, 0.25};

	size = safeZoneW * 0.012;
	y = safeZoneY + safeZoneH * 0.2;
	w = safeZoneW * 0.4;
	h = safeZoneH * 0.75;

	class TextPos {
		left = 0.01;
		top = 0.01;
		right = 0.01;
		bottom = 0.01;
	};

	class Attributes {
		font = "PuristaMedium";
	};
};

class RscWLVideo: RscVideo {
	autoplay = 1;
	loops = 1000;
};

class RscWLSidePicker {
	idd = -1;
	movingEnable = false;
	class controlsBackground {
		class RscWLSidePicker_Background: RscText {
			idc = -1;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH;
			colorBackground[] = {0, 0, 0, 1};
		};
	};
	class controls {
		class RscWLSidePicker_BackgroundVideos: RscControlsGroupNoScrollbars {
			idc = 100;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH;
		};
		class RscDummyButton: RscShortcutButton {
			idc = 101;
			x = safeZoneX;
			y = safeZoneY;
			w = 0;
			h = 0;
		};
		class RscWLSidePicker_BackgroundText: RscPictureKeepAspect {
			idc = -1;
			x = safeZoneX + safeZoneW * 0.05;
			y = safeZoneY;
			w = safeZoneW * 0.9;
			h = safeZoneH * 0.2;
			text = "src\img\reduxlogosmall.paa";
		};
		class RscWLSidePicker_WestButton: RscWLSideButton {
			idc = 102;
			colorBackgroundFocused[] = {0.2, 0.2, 0.6, 0.7};
			colorBackground2[] = {0.2, 0.2, 0.6, 0.7};
			x = safeZoneX + safeZoneW * 0.05;
			tooltip = "$STR_WL_joinBlufor";
		};
		class RscWLSidePicker_EastButton: RscWLSideButton {
			idc = 103;
			colorBackgroundFocused[] = {0.6, 0.2, 0.2, 0.7};
			colorBackground2[] = {0.6, 0.2, 0.2, 0.7};
			x = safeZoneX + safeZoneW * 0.55;
			tooltip = "$STR_WL_joinOpfor";
		};
		class RscWLSidePicker_Reason: RscStructuredText {
			idc = 104;
			x = safeZoneX + safeZoneW * 0.1;
			y = safeZoneY + safeZoneH * 0.87;
			w = safeZoneW * 0.8;
			h = safeZoneH * 0.1;
			size = 0.04;
			colorBackground[] = {0, 0, 0, 1};
		};
		class RscWLSidePicker_Unassigned: RscStructuredText {
			idc = 105;
			x = safeZoneX + safeZoneW * 0.455;
			y = safeZoneY + safeZoneH * 0.22;
			w = safeZoneW * 0.09;
			h = safeZoneH * 0.3;
			size = 0.023 * safeZoneW;

			class Attributes {
				font = "PuristaMedium";
			};
		};
	};
};

class RscWLGulag {
	idd = -1;
	movingEnable = false;
	class controlsBackground {
		class RscWLGulag_Background: RscText {
			idc = -1;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH;
			colorBackground[] = {0, 0, 0, 1};
		};
	};
	class controls {
		class RscDummyButton: RscShortcutButton {
			idc = -1;
			x = safeZoneX;
			y = safeZoneY;
			w = 0;
			h = 0;
		};
		class RscWLGulag_BackgroundText: RscText {
			idc = 100;
			x = safeZoneX + safeZoneW * 0.15;
			y = safeZoneY + safeZoneH * 0.07;
			w = safeZoneW * 0.7;
			h = safeZoneH * 0.16;
			font = "PuristaBold";
			style = ST_CENTER + ST_MULTI;
			shadow = 0;
			linespacing = 1;
			sizeEx = 0.02 * safeZoneW;
		};
		class RscWLGulag_Instructions: RscText {
			idc = 101;
			x = safeZoneX + safeZoneW * 0.1;
			y = safeZoneY + safeZoneH * 0.25;
			w = safeZoneW * 0.8;
			h = safeZoneH * 0.06;
			font = "PuristaBold";
			style = ST_CENTER;
			shadow = 0;
			sizeEx = 0.025 * safeZoneH;
			text = "Pick the enemy. Hold your cursor over a card to select it.";
		};
		class RscWLGulag_LeftCard: RscText {
			idc = 110;
			x = safeZoneX + safeZoneW * 0.18;
			y = safeZoneY + safeZoneH * 0.34;
			w = safeZoneW * 0.28;
			h = safeZoneH * 0.4;
			colorBackground[] = {0.11, 0.13, 0.16, 1};
		};
		class RscWLGulag_RightCard: RscWLGulag_LeftCard {
			idc = 120;
			x = safeZoneX + safeZoneW * 0.54;
		};
		class RscWLGulag_LeftPicture: RscPictureKeepAspect {
			idc = 111;
			x = safeZoneX + safeZoneW * 0.195;
			y = safeZoneY + safeZoneH * 0.355;
			w = safeZoneW * 0.25;
			h = safeZoneH * 0.28;
			text = "";
			colorText[] = {1, 1, 1, 1};
		};
		class RscWLGulag_RightPicture: RscWLGulag_LeftPicture {
			idc = 121;
			x = safeZoneX + safeZoneW * 0.555;
		};
		class RscWLGulag_LeftCaption: RscText {
			idc = 112;
			x = safeZoneX + safeZoneW * 0.195;
			y = safeZoneY + safeZoneH * 0.645;
			w = safeZoneW * 0.25;
			h = safeZoneH * 0.04;
			font = "PuristaMedium";
			style = ST_CENTER;
			shadow = 0;
			sizeEx = 0.022 * safeZoneH;
			text = "Hold to select";
		};
		class RscWLGulag_RightCaption: RscWLGulag_LeftCaption {
			idc = 122;
			x = safeZoneX + safeZoneW * 0.555;
		};
		class RscWLGulag_LeftProgressTrack: RscText {
			idc = 113;
			x = safeZoneX + safeZoneW * 0.195;
			y = safeZoneY + safeZoneH * 0.705;
			w = safeZoneW * 0.25;
			h = safeZoneH * 0.012;
			colorBackground[] = {0.25, 0.28, 0.32, 1};
		};
		class RscWLGulag_RightProgressTrack: RscWLGulag_LeftProgressTrack {
			idc = 123;
			x = safeZoneX + safeZoneW * 0.555;
		};
		class RscWLGulag_LeftProgressFill: RscWLGulag_LeftProgressTrack {
			idc = 114;
			w = 0;
			colorBackground[] = {0.9, 0.75, 0.35, 1};
		};
		class RscWLGulag_RightProgressFill: RscWLGulag_LeftProgressFill {
			idc = 124;
			x = safeZoneX + safeZoneW * 0.555;
		};
		class RscWLGulag_Feedback: RscWLGulag_Instructions {
			idc = 102;
			y = safeZoneY + safeZoneH * 0.79;
			h = safeZoneH * 0.05;
			text = "";
		};
		class RscWLGulag_Score: RscWLGulag_Instructions {
			idc = 103;
			y = safeZoneY + safeZoneH * 0.87;
			h = safeZoneH * 0.035;
			font = "PuristaMedium";
			sizeEx = 0.022 * safeZoneH;
			text = "";
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
	colorBackground[] = {0, 0, 0, 0};
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
	idd = 11012;
	class controls {
		class RscSpectatorDisplay_Map: RscMapControl {
			idc = 5503;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH;
			ptsPerSquareSea = 0;
			colorSea[] = {0, 0, 0, 0};
		};
	};
};

class RscWLSectorDisplay_SectorName: RscStructuredText {
	font = "EtelkaMonospaceProBold";
	colorText[] = {1, 1, 1, 1};
	size = 0.022;
	class Attributes {
		font = "EtelkaMonospaceProBold";
		shadow = 0;
	};
};

class RscWLSectorDisplay_SectorBar: RscText {
	text = "";
};
