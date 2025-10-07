class RscTitles {
	class RscGFEarplugs {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		class controls {
			class RscGFEarplugs_Control {
				idc = -1;
				type = 0;
				style = ST_PICTURE;
				tileH = 1;
				tileW = 1;
				x = 0.93 * safezoneW + safezoneX;
				y = 0.17  * safezoneH + safezoneY;
				w = 0.06;
				h = 0.08;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 1;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {0.3, 1, 1, 1};
				text = "\A3\ui_f\data\IGUI\RscIngameUI\RscDisplayChannel\MuteVON_crossed_ca.paa";
				lineSpacing = 0;
			};
		};
	};

	class RscViewRangeReduce {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		class controls {
			class RscViewRangeReduce {
				idc = -1;
				type = 0;
				style = ST_PICTURE;
				tileH = 1;
				tileW = 1;
				x = 0.96 * safezoneW + safezoneX;
				y = 0.17  * safezoneH + safezoneY;
				w = 0.06;
				h = 0.08;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 1;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {0.3, 1, 1, 1};
				text = "\A3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\icon_terrain_ca.paa";
				lineSpacing = 0;
			};
		};
	};

	class RscLagMessageDisplay {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscLagMessageDisplay";
		onLoad = "uiNamespace setVariable ['RscLagMessageDisplay', _this select 0];";
		class controlsBackground  {
			class RscLagMessageDisplayBackground {
				idc = 10000;
				type = CT_STATIC;
				style = ST_MULTI;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW;
				h = safeZoneH;
				sizeEx = 0.03;
				colorBackground[] = {0, 0, 0, 1};
				colorText[] = {1, 1, 1, 1};
				lineSpacing = 1;
				font = "PuristaMedium";
				text = "";
			};
		};
		class controls {
			class RscLagMessageDisplayText1 {
				idc = 10001;
				type = CT_STATIC;
				style = ST_MULTI;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW / 4;
				h = safeZoneH;
				sizeEx = 0.03;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				lineSpacing = 1;
				font = "PuristaMedium";
				text = "";
			};
			class RscLagMessageDisplayText2 {
				idc = 10002;
				type = CT_STATIC;
				style = ST_MULTI;
				x = safeZoneX + safeZoneW / 4;
				y = safeZoneY;
				w = safeZoneW / 4;
				h = safeZoneH;
				sizeEx = 0.03;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				lineSpacing = 1;
				font = "PuristaMedium";
				text = "";
			};
			class RscLagMessageDisplayText3 {
				idc = 10003;
				type = CT_STATIC;
				style = ST_MULTI;
				x = safeZoneX + 2 * safeZoneW / 4;
				y = safeZoneY;
				w = safeZoneW / 4;
				h = safeZoneH;
				sizeEx = 0.03;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				lineSpacing = 1;
				font = "PuristaMedium";
				text = "";
			};
			class RscLagMessageDisplayText4 {
				idc = 10004;
				type = CT_STATIC;
				style = ST_MULTI;
				x = safeZoneX + 3 * safeZoneW / 4;
				y = safeZoneY;
				w = safeZoneW / 4;
				h = safeZoneH;
				sizeEx = 0.03;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				lineSpacing = 1;
				font = "PuristaMedium";
				text = "";
			};
		};
	};

	class RscWarlordsHUD {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscWarlordsHUD";
		onLoad = "uiNamespace setVariable ['RscWarlordsHUD', _this select 0];";
		class controls {
			class RscWarlordsHUD_Timer: RscStructuredText {
				idc = 2100;
				x = safeZoneW + safeZoneX - 0.21;
				y = safeZoneH + safeZoneY - 0.13;
				w = 0.23;
				h = 0.05;
				text = "";
				size = 0.045;
			};

			class RscWarlordsHUD_Money: RscStructuredText {
				idc = 2101;
				x = safeZoneW + safeZoneX - 0.45;
				y = safeZoneH + safeZoneY - 0.2;
				w = 0.2;
				h = 0.05;
				text = "";
				size = 0.045;
			};
			class RscWarlordsHUD_AI: RscStructuredText {
				idc = 2102;
				x = safeZoneW + safeZoneX - 0.25;
				y = safeZoneH + safeZoneY - 0.2;
				w = 0.1;
				h = 0.05;
				text = "";
				size = 0.045;
			};
			class RscWarlordsHUD_Squad: RscStructuredText {
				idc = 2103;
				x = safeZoneW + safeZoneX - 0.15;
				y = safeZoneH + safeZoneY - 0.2;
				w = 0.15;
				h = 0.05;
				text = "";
				size = 0.045;
			};

			class RscWarlordsHUD_Rearm: RscStructuredText {
				idc = 2104;
				x = safeZoneW + safeZoneX - 0.45;
				y = safeZoneH + safeZoneY - 0.27;
				w = 0.2;
				h = 0.05;
				text = "";
				size = 0.045;
			};
			class RscWarlordsHUD_Repair: RscStructuredText {
				idc = 2105;
				x = safeZoneW + safeZoneX - 0.25;
				y = safeZoneH + safeZoneY - 0.27;
				w = 0.2;
				h = 0.05;
				text = "";
				size = 0.045;
			};

			class RscWarlordsHUD_APSType: RscStructuredText {
				idc = 2106;
				x = safeZoneW + safeZoneX - 0.45;
				y = safeZoneH + safeZoneY - 0.34;
				w = 0.2;
				h = 0.05;
				text = "";
				size = 0.045;
			};
			class RscWarlordsHUD_APSAmmo: RscStructuredText {
				idc = 2107;
				x = safeZoneW + safeZoneX - 0.25;
				y = safeZoneH + safeZoneY - 0.34;
				w = 0.2;
				h = 0.05;
				text = "";
				size = 0.045;
			};

			class RscWarlordsHUD_CaptureProgress: RscProgress {
				idc = 2108;
				x = 0.08;
				y = safeZoneY + 0.04;
				w = 0.84;
				h = 0.048;
				colorFrame[] = {0, 0, 0, 1};
				colorBar[] = {1, 1, 1, 1};
			};
			class RscWarlordsHUD_Capture: RscStructuredText {
				idc = 2109;
				x = 0;
				y = safeZoneY + 0.04;
				w = 1;
				h = 0.05;
				text = "";
				size = 0.045;
			};
		};
	};

	class RscJammingIndicator {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscJammingIndicator";
		onLoad = "uiNamespace setVariable ['RscJammingIndicator', _this select 0];";
		class controls {
			class RscJammingIndicatorText {
				idc = 7001;
				type = CT_STATIC;
				style = ST_CENTER;
				x = 1;
				y = 0;
				w = 0.35;
				h = 0.1;
				sizeEx = 0.04;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				font = "PuristaMedium";
				text = "";
			};
		};
	};

	class RscSpectrumIndicator {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscSpectrumIndicator";
		onLoad = "uiNamespace setVariable ['RscSpectrumIndicator', _this select 0];";
		class controls {
			class RscSpectrumIndicatorText: RscStructuredText {
				idc = 17001;
				x = 0;
				y = 0;
				w = 0.5;
				h = 0.5;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				font = "PuristaLight";
				text = "";
			};
		};
	};

	class RscWLVoteDisplay {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscWLVoteDisplay";
		onLoad = "uiNamespace setVariable ['RscWLVoteDisplay', _this select 0];";
		class controls {
			class Background: RscText {
				idc = 7003;
				style = 128;
				x = 1 - safeZoneX - 0.3;
				y = 0;
				w = 0.28;
				h = 0.3;
				text = "";
				colorBackground[] = { 0, 0, 0, 0.7 };
				shadow=1;
			};
			class RscWLVoteDisplayText: RscStructuredText {
				idc = 7002;
				x = 1 - safeZoneX - 0.3;
				y = 0.015;
				w = 0.28;
				h = 0.3;
				text = "";
				style = ST_MULTI;
				shadow = 1;
				size = 0.032;
				class Attributes {
					color = "#ffffff";
					align = "center";
				};
			};
		};
	};

	class RscWLCaptureDisplay {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscWLCaptureDisplay";
		onLoad = "uiNamespace setVariable ['RscWLCaptureDisplay', _this select 0];";
		class controls {
			class Background: RscText {
				idc = 7004;
				style = 128;
				x = 1 - safeZoneX - 0.3;
				y = 0.3;
				w = 0.28;
				h = 0.35;
				text = "";
				colorBackground[] = { 0, 0, 0, 0.7 };
				shadow=1;
			};
			class RscWLCaptureDisplayText: RscStructuredText {
				idc = 7005;
				x = 1 - safeZoneX - 0.3;
				y = 0.315;
				w = 0.28;
				h = 0.35;
				text = "";
				style = ST_MULTI;
				shadow = 1;
				size = 0.032;
				class Attributes {
					font = "RobotoCondensed";
					color = "#ffffff";
					align = "center";
				};
			};
		};
	};

	class RscWLAPSDisplay {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscWLAPSDisplay";
		onLoad = "uiNamespace setVariable ['RscWLAPSDisplay', _this select 0];";
		class controls {
			class Background: RscText {
				idc = 7006;
				style = 128;
				x = 1 - safeZoneX - 0.32;
				y = 0;
				w = 0.3;
				h = 0.3 * 4 / 3 + 0.1;
				text = "";
				colorBackground[] = { 0, 0, 0, 0.7 };
				shadow=1;
			};
			class RscWLAPSDisplayIndicator: RscPicture {
				idc = 7007;
				x = 1 - safeZoneX - 0.3;
				y = 0.02;
				w = 0.26;
				h = 0.26 * 4 / 3;
				text = "\a3\ui_f\data\IGUI\Cfg\Radar\danger_ca.paa";
				style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
				shadow = 1;
				colorText[] = {1, 0, 0, 1};
				size = 0.032;
			};
			class RscWLAPSDisplayRadar: RscPicture {
				idc = 7008;
				x = 1 - safeZoneX - 0.3;
				y = 0.02;
				w = 0.26;
				h = 0.26 * 4 / 3;
				text = "\a3\ui_f\data\IGUI\Cfg\Radar\radar_ca.paa";
				style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
				shadow = 1;
				size = 0.032;
			};
			class RscWLAPSDisplayText: RscText {
				idc = 7100;
				x = 1 - safeZoneX - 0.32;
				y = 0.3 * 4 / 3;
				w = 0.3;
				h = 0.1;
				text = "";
				style = ST_CENTER;
				shadow = 1;
				size = 0.032;
				class Attributes {
					font = "RobotoCondensed";
					color = "#ffffff";
					align = "center";
				};
			};
		};
	};

	class RscWLMineDisplay {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscWLMineDisplay";
		onLoad = "uiNamespace setVariable ['RscWLMineDisplay', _this select 0];";
		class controls {
			class Background: RscText {
				idc = 7009;
				style = 128;
				x = 1 - safeZoneX - 0.3125;
				y = 0.45;
				w = 0.30;
				h = 0.5;
				text = "";
				colorBackground[] = { 0, 0, 0, 0.7 };
				shadow=1;
			};
			class RscWLMineDisplayText: RscStructuredText {
				idc = 7010;
				x = 1 - safeZoneX - 0.3125;
				y = 0.465;
				w = 0.30;
				h = 0.5;
				text = "";
				style = ST_MULTI;
				shadow = 1;
				size = 0.032;
				class Attributes {
					font = "RobotoCondensed";
					color = "#ffffff";
					align = "center";
				};
			};
		};
	};

	class RscWLVoiceDisplay {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscWLVoiceDisplay";
		onLoad = "uiNamespace setVariable ['RscWLVoiceDisplay', _this select 0];";
		class controls {
			class Background: RscText {
				idc = 7200;
				style = 128;
				x="(profilenamespace getvariable [""IGUI_GRID_CHAT_X"",	(safezoneX + 1 * (((safezoneW / safezoneH) min 1.2) / 40))])";
				y="(profilenamespace getvariable [""IGUI_GRID_CHAT_Y"",	(safezoneY + safezoneH - 10.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25))]) - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				w="(profilenamespace getvariable [""IGUI_GRID_CHAT_W"",	(20 * (((safezoneW / safezoneH) min 1.2) / 40))])";
				h="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				text = "";
				colorBackground[] = { 0, 0, 0, 0.8 };
				shadow=1;
			};
			class RscWLVoiceDisplayText: RscStructuredText {
				idc = 7201;
				x="(profilenamespace getvariable [""IGUI_GRID_CHAT_X"",	(safezoneX + 1 * (((safezoneW / safezoneH) min 1.2) / 40))])";
				y="(profilenamespace getvariable [""IGUI_GRID_CHAT_Y"",	(safezoneY + safezoneH - 10.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25))]) - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				w="(profilenamespace getvariable [""IGUI_GRID_CHAT_W"",	(20 * (((safezoneW / safezoneH) min 1.2) / 40))])";
				h="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				text = "";
				style = ST_MULTI;
				shadow = 1;
				size = 0.032;
				class Attributes {
					font = "RobotoCondensed";
					color = "#8fed8f";
					align = "left";
				};
			};
		};
	};

	class RscWLGogglesDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLGogglesDisplay";
		onLoad = "uiNamespace setVariable ['RscWLGogglesDisplay', _this select 0];";
		class controls {
			class RscWLGogglesDisplay_Icon {
				idc = -1;
				type = 0;
				style = ST_PICTURE;
				tileH = 1;
				tileW = 1;
				x = 0.90 * safezoneW + safezoneX;
				y = 0.17  * safezoneH + safezoneY;
				w = 0.06;
				h = 0.08;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 1;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {0.3, 1, 1, 1};
				text = "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\goggles_ca.paa";
				lineSpacing = 0;
			};
			class RscWLGogglesDisplay_RangeDisplay: RscText {
				idc = 8000;
				type = CT_STATIC;
				style = ST_CENTER;
				x = 0.90 * safezoneW + safezoneX;
				y = 0.19  * safezoneH + safezoneY;
				w = 0.06;
				h = 0.08;
				font = "RobotoCondensed";
				shadow = 0;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {0.3, 1, 1, 1};
				text = "5000";
				lineSpacing = 0;
			};
		};
	};

	class RscWLEWNetworkDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		class controls {
			class RscWLEWNetworkDisplay_Icon {
				idc = -1;
				type = 0;
				style = ST_PICTURE;
				tileH = 1;
				tileW = 1;
				x = 0.87 * safezoneW + safezoneX;
				y = 0.17  * safezoneH + safezoneY;
				w = 0.06;
				h = 0.08;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 1;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {0.3, 1, 1, 1};
				text = "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\radio_ca.paa";
				lineSpacing = 0;
			};
		};
	};

	class RscWLSpectatorProjectileDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		onLoad = "uiNamespace setVariable ['RscWLSpectatorProjectileDisplay', _this select 0];";
		class controls {
			class RscWLSpectatorProjectileDisplay_Icon {
				idc = 8600;
				type = 0;
				style = ST_PICTURE;
				tileH = 1;
				tileW = 1;
				x = 0.87 * safezoneW + safezoneX;
				y = 0.17  * safezoneH + safezoneY;
				w = 0.06;
				h = 0.08;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 1;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {0.3, 1, 1, 1};
				text = "\a3\Ui_f\data\IGUI\Cfg\CommandBar\imageCommander_ca.paa";
				lineSpacing = 0;
			};
		};
	};

	class RscWLZoneRestrictionDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLZoneRestrictionDisplay";
		onLoad = "uiNamespace setVariable ['RscWLZoneRestrictionDisplay', _this select 0];";
		class controlsBackground {
			class RscWLZoneRestrictionDisplay_Cover: RscText {
				idc = -1;
				type = CT_STATIC;
				style = ST_CENTER;
				x = safezoneX;
				y = safezoneY;
				w = safezoneW;
				h = safezoneH;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 1;
				colorBackground[] = {0.3, 0, 0, 0.15};
				colorText[] = {0, 0, 0, 0.3};
				text = "";
				lineSpacing = 0;
			};
		};
		class controls {
			class RscWLZoneRestrictionDisplay_Text: RscText {
				idc = -1;
				type = CT_STATIC;
				style = ST_CENTER;
				x = 0;
				y = safeZoneY + 0.05;
				w = 1;
				h = 0.2;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 0.08;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				text = "YOU ARE TRESPASSING! TURN AROUND OR DIE!";
				lineSpacing = 0;
			};
			class RscWLZoneRestrictionDisplay_Time: RscText {
				idc = 9000;
				type = CT_STATIC;
				style = ST_CENTER;
				x = 0;
				y = safeZoneY + 0.15;
				w = 1;
				h = 0.3;
				font = "RobotoCondensedBold";
				sizeEx = 0.25;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 0, 0, 1};
				text = "";
				shadow = 0;
				lineSpacing = 1;
			};
		};
	};

	class RscWLExtendedSamWarningDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLExtendedSamWarningDisplay";
		onLoad = "uiNamespace setVariable ['RscWLExtendedSamWarningDisplay', _this select 0];";
		class controls {
			class RscWLExtendedSamWarningDisplay_Text: RscStructuredText {
				idc = 14300;
				style = ST_CENTER + ST_MULTI;
				x = 0;
				y = safeZoneY + 0.1;
				w = 1;
				h = 0.5;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 0.08;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				text = "ENEMY LONG-RANGE AIR DEFENSE DETECTED!";
			};
		};
	};

	class RscWLCruiseMissileDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLCruiseMissileDisplay";
		onLoad = "uiNamespace setVariable ['RscWLCruiseMissileDisplay', _this select 0];";
		class controls {
			class RscWLCruiseMissileDisplay_EnemyText: RscStructuredText {
				idc = 31001;
				x = 0;
				y = safeZoneY + 0.1;
				w = 1;
				h = 0.3;
				text = "<t color='#ff3333' align='center'>ENEMY CRUISE MISSILE LAUNCH DETECTED</t>";
				style = ST_MULTI;
				shadow = 0;
				size = 0.08;
			};

			class RscWLCruiseMissileDisplay_Instruction: RscStructuredText {
				idc = 31002;
				x = 0;
				y = safeZoneY + 0.1;
				w = 1;
				h = 0.3;
				text = "<t color='#ff3333' align='center'>HOLD LEFT CLICK TO LOCK MISSILE TARGETS<br/>BACKSPACE TO CANCEL</t>";
				style = ST_MULTI;
				shadow = 0;
				size = 0.08;
			};
		};
	};

	class RscWLDeathInfoMenu {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLDeathInfoMenu";
		onLoad = "uiNamespace setVariable ['RscWLDeathInfoMenu', _this select 0];";
		class controls {
			class RscWLDeathInfoMenu_Texture: RscText {
				type = 106;
				idc = 5502;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW;
				h = safeZoneH;
				url = "file://src/ui/gen/deathinfo.html";
			};
		};
	};

	class RscWLHintMenu {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLHintMenu";
		onLoad = "uiNamespace setVariable ['RscWLHintMenu', _this select 0];";
		class controls {
			class RscWLHintMenu_Texture: RscText {
				type = 106;
				idc = 5502;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW;
				h = safeZoneH;
				url = "file://src/ui/gen/hint.html";
			};
		};
	};

	class RscWLKillfeedMenu {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLKillfeedMenu";
		onLoad = "uiNamespace setVariable ['RscWLKillfeedMenu', _this select 0];";
		class controls {
			class RscWLKillfeedMenu_Texture: RscText {
				type = 106;
				idc = 5502;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW;
				h = safeZoneH;
				url = "file://src/ui/gen/killfeed.html";
			};
		};
	};

	class RscWLTargetingMenu {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLTargetingMenu";
		onLoad = "uiNamespace setVariable ['RscWLTargetingMenu', _this select 0];";
		class controls {
			class RscWLTargetingMenu_Texture: RscText {
				type = 106;
				idc = 5502;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW;
				h = safeZoneH;
				url = "file://src/ui/gen/target.html";
			};
		};
	};

	class RscWLTurretMenu {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLTurretMenu";
		onLoad = "uiNamespace setVariable ['RscWLTurretMenu', _this select 0];";
		class controls {
			class RscWLTurretMenu_Texture: RscText {
				type = 106;
				idc = 5502;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW;
				h = safeZoneH;
				url = "file://src/ui/gen/turret.html";
			};
		};
	};

	class RscWLMissileCameraDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLMissileCameraDisplay";
		onLoad = "uiNamespace setVariable ['RscWLMissileCameraDisplay', _this select 0];";
		class controls {
			class RscWLMissileCameraDisplay_TitleBar: RscText {
				idc = 5110;
				x = safezoneX + 0.2;
				y = safezoneY + 0.1;
				w = safeZoneW / 4;
				h = 0.05;
				colorBackground[] = {0, 0, 0, 0.9};
				colorText[] = {1, 1, 1, 1};
				text = "MISSILE CAMERA";
			};
			class RscWLMissileCameraDisplay_Picture: RscPicture {
				idc = 5111;
				x = safezoneX + 0.2;
				y = safezoneY + 0.15;
				w = safeZoneW / 4;
				h = safeZoneW / 4;
				colorBackground[] = {0, 0, 0, 0.9};
				colorText[] = {1, 1, 1, 1};
				text = "#(argb,512,512,1)r2t(rtt1,1.0)";
			};
		};
	};
};