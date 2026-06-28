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

			class RscWarlordsHUD_TeamPriority: RscStructuredText {
				idc = 2111;
				x = safeZoneX + 0.028;
				y = safeZoneH + safeZoneY - 0.2;
				w = 0.5;
				h = 0.05;
				text = "";
				size = 0.045;
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
				x = 0.3;
				y = safeZoneY + 0.15;
				w = 0.4;
				h = 0.15;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				font = "PuristaLight";
				text = "";
			};
		};
	};

	class RscWLMinimap {
		idd = -1;
		movingEnable = 0;
		duration = 1e+011;
		name = "RscWLMinimap";
		onLoad = "uiNamespace setVariable ['RscWLMinimap', _this select 0];";
		class controls {
			class RscBetterMinimap: RscMapControl {
				idc = 1200;

				x = safezoneX + 0.02;
				y = safezoneY + safezoneH - 0.87;
				w = 0.33;
				h = 0.44;

				showCountourInterval = 0;
				moveOnEdges = 1;
				maxSatelliteAlpha = 0;
				alphaFadeStartScale = 10;
				alphaFadeEndScale = 10;
				ptsPerSquareTxt = 500;
				ptsPerSquareFor = 15;
				ptsPerSquareForEdge = 15;
				ptsPerSquareRoad = 15;
				ptsPerSquareObj = 15;
				ptsPerSquareSea = 0;

				colorBackground[] = {0.2, 0.2, 0.2, 0.5};
				colorSea[] = {0, 0, 0, 0.4};
				colorForest[] = {0.2, 0.2, 0.2, 0.7};
				colorForestBorder[] = {0.2, 0.2, 0.2, 0.5};
				colorRocks[] = {0.95, 0.95, 0.95, 0.1};
				colorRocksBorder[] = {0.95, 0.95, 0.95, 0.5};
				colorLevels[] = {0, 0, 0, 0};
				colorMainCountlines[] = {0.2, 0.2, 0.2, 0.6};
				colorCountlines[] = {0.2, 0.2, 0.2, 0.2};
				colorMainCountlinesWater[] = {0.95, 0.95, 0.95, 0.7};
				colorCountlinesWater[] = {0.95, 0.95, 0.95, 0.4};
				colorPowerLines[] = {0.95, 0.95, 0.95, 0.5};
				colorRailWay[] = {0.95, 0.95, 0.95, 1};
				colorTracks[] = {0.95, 0.95, 0.95, 0.15};
				colorTracksFill[] = {0.95, 0.95, 0.95, 0.3};
				colorRoads[] = {0.95, 0.95, 0.95, 1};
				colorRoadsFill[] = {0.95, 0.95, 0.95, 0.5};
				colorMainRoads[] = {0.95, 0.95, 0.95, 1};
				colorMainRoadsFill[] = {0.95, 0.95, 0.95, 0.7};
				colorGrid[] = {0.95, 0.95, 0.95, 0.3};
				colorGridMap[] = {0.95, 0.95, 0.95, 0.2};

				class bush: Bush {
					color[] = {0.2, 0.2, 0.2, 0.4};
				};

				class rock: Rock {
					color[] = {0.2, 0.2, 0.2, 0.8};
				};

				class smalltree: SmallTree {
					color[] = {0.2, 0.2, 0.2, 0.4};
				};

				class tree: Tree {
					color[] = {0.2, 0.2, 0.2, 0.4};
				};

				class busstop: busstop {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class fuelstation: fuelstation {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class hospital: hospital {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class church: church {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class lighthouse: lighthouse {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class power: power {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class powersolar: powersolar {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class powerwave: powerwave {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class powerwind: powerwind {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class quay: quay {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class shipwreck: Shipwreck {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class transmitter: transmitter {
					color[] = {0.95, 0.95, 0.95, 1};
				};

				class watertower: watertower {
					color[] = {0.95, 0.95, 0.95, 1};
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
		class controlsBackground {
			class RscWLExtendedSamWarningDisplay_Cover: RscText {
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
			class RscWLExtendedSamWarningDisplay_Text: RscText {
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
				text = "ENEMY NO FLY ZONE DETECTED!";
				lineSpacing = 0;
			};
			class RscWLExtendedSamWarningDisplay_Sector: RscText {
				idc = 35600;
				type = CT_STATIC;
				style = ST_CENTER;
				x = 0;
				y = safeZoneY + 0.1;
				w = 1;
				h = 0.3;
				font = "EtelkaNarrowMediumPro";
				sizeEx = 0.15;
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {1, 1, 1, 1};
				text = "SECTOR";
				lineSpacing = 0;
			};
		};
	};

	class RscWLPromptDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLPromptDisplay";
		onLoad = "uiNamespace setVariable ['RscWLPromptDisplay', _this select 0];";
		class controls {
			class RscWLPromptDisplay_Background: RscText {
				idc = 41001;
				x = 0;
				y = safeZoneY + 0.1;
				w = 1;
				h = 0.17;
				colorBackground[] = {0, 0, 0, 0.7};
				colorText[] = {1, 1, 1, 1};
				text = "";
			};
			class RscWLPromptDisplay_Text: RscStructuredText {
				idc = 41002;
				x = 0.01;
				y = safeZoneY + 0.11;
				w = 0.98;
				h = 0.15;
				text = "";
				font = "EtelkaNarrowMediumPro";
				style = ST_MULTI;
				shadow = 0;
				size = 0.045;
			};
			class RscWLPromptDisplay_Timer: RscProgress {
				idc = 41003;
				x = 0;
				y = safeZoneY + 0.26;
				w = 1;
				h = 0.01;
				colorFrame[] = {0, 0, 0, 0};
				colorBar[] = {0.18, 1, 0.18, 1};
			};
			class RscWLPromptDisplay_Image: RscPicture {
				idc = 41004;
				x = 0.47;
				y = safeZoneY + 0.17;
				w = 0.06;
				h = 0.08;
				text = "\a3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa";
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

	class RscWLSectorDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLSectorDisplay";
		onLoad = "uiNamespace setVariable ['RscWLSectorDisplay', _this select 0];";

		class controls {
			class RscWLSectorDisplay_Background: RscText {
				idc = 4000;
				text = "";
				colorBackground[] = {0.2, 0.2, 0.2, 1};
			};
			class RscWLSectorDisplay_CaptureTitle: RscStructuredText {
				idc = 4001;
				text = "";
				size = 0.032;
				class Attributes {
					font = "EtelkaMonospaceProBold";
					shadow = 0;
				};
			};
			class RscWLSectorDisplay_VoteTitle: RscStructuredText {
				idc = 4002;
				text = "";
				size = 0.032;
				class Attributes {
					font = "EtelkaMonospaceProBold";
					shadow = 0;
				};
			};
		};
	};

	class RscWLDeathDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLDeathDisplay";
		onLoad = "uiNamespace setVariable ['RscWLDeathDisplay', _this select 0];";
		class controls {
			class SQD_DeathInfo_Status: RscStructuredText {
				idc = 11001;
				x = 0.2;
				y = 0.2;
				w = 0.6;
				h = 0.8;
				size = 0.08;
				text = "";

				class Attributes {
					font = "RobotoCondensedBold";
					color = SQD_COLOR_TEXT;
					align = "center";
				};
			};
			class SQD_DeathInfo_Tips: RscStructuredText {
				idc = 11002;
				x = 0;
				y = 0;
				w = 1;
				h = 0.2;
				size = 0.08;
				text = "";

				class Attributes {
					font = "RobotoCondensedBold";
					color = SQD_COLOR_TEXT;
					align = "center";
				};
			};
			class SQD_DeathInfo_Timer: RscStructuredText {
				idc = 11003;
				x = 0;
				y = safeZoneY + 0.1;
				w = 1;
				h = 0.2;
				size = 0.15;
				text = "";

				class Attributes {
					font = "RobotoCondensedBold";
					color = SQD_COLOR_TEXT;
					align = "center";
				};
			};
		};
	};

	class RscWLProgressDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLProgressDisplay";
		onLoad = "uiNamespace setVariable ['RscWLProgressDisplay', _this select 0];";
		class controls {
			class RscWLProgressDisplay_Bar: RscProgress {
				idc = 5000;
				x = 0.08;
				y = safeZoneY + safeZoneH - 0.25;
				w = 0.84;
				h = 0.055;
				colorFrame[] = {1, 1, 1, 1};
				colorBar[] = {0, 1, 0, 1};
			};
			class RscWLProgressDisplay_Timer: RscStructuredText {
				idc = 5001;
				x = 0.08;
				y = safeZoneY + safeZoneH - 0.25;
				w = 0.84;
				h = 0.055;
				text = "";
				size = 0.045;
			};
			class RscWLProgressDisplay_Text: RscStructuredText {
				idc = 5002;
				style = ST_MULTI;
				x = safeZoneX + 0.028;
				y = 0.2;
				w = 0.5;
				h = 0.5;
				text = "";
				size = 0.032;
				colorBackground[] = {0.2, 0.2, 0.2, 1};
				class Attributes {
					font = "EtelkaMonospaceProBold";
					shadow = 0;
				};
			};
		};
	};

	class RscWLHmdSettingDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLHmdSettingDisplay";
		onLoad = "uiNamespace setVariable ['RscWLHmdSettingDisplay', _this select 0];";
		class controls {
			class RscWLHmdSettingDisplay_Main: RscStructuredText {
				idc = 7000;
				style = ST_MULTI;
				x = 0.3;
				y = 0;
				w = 0.4;
				h = 1;
				text = "";
				size = 0.04;
				class Attributes {
					color = "#14cb00";
					font = "EtelkaMonospaceProBold";
					shadowColor = "#000000";
				};
			};
		};
	};

	class RscWLKillfeedDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLKillfeedDisplay";
		onLoad = "uiNamespace setVariable ['RscWLKillfeedDisplay', _this select 0];";
		class controls {
			class RscWLKillfeedDisplay_Main: RscStructuredText {
				idc = 8000;
				style = ST_MULTI;
				x = 0;
				y = 0;
				w = 1;
				h = 1;
				text = "";
				size = 0.042;
				class Attributes {
					align = "center";
					color = "#ffffff";
					font = "RobotoCondensed";
					shadowColor = "#000000";
				};
			};
			class RscWLKillfeedDisplay_Numbers: RscStructuredText {
				idc = 8001;
				style = ST_MULTI;
				x = 0;
				y = 0;
				w = 1;
				h = 1;
				text = "";
				size = 0.042;
				class Attributes {
					align = "right";
					color = "#ffffff";
					font = "RobotoCondensed";
					shadowColor = "#000000";
				};
			};
			class RscWLKillfeedDisplay_Icons: RscStructuredText {
				idc = 8002;
				style = ST_MULTI;
				x = 0;
				y = 0;
				w = 1;
				h = 1;
				text = "";
				size = 0.05;
				class Attributes {
					align = "center";
					shadowColor = "#000000";
				};
			};
			class RscWLKillfeedDisplay_Total: RscStructuredText {
				idc = 8003;
				style = ST_MULTI;
				x = 0;
				y = 0;
				w = 1;
				h = 1;
				text = "";
				size = 0.045;
				class Attributes {
					align = "right";
					color = "#ffffff";
					font = "RobotoCondensed";
					shadowColor = "#000000";
				};
			};

			class RscWLKillfeedDisplay_BadgeFrame: RscText {
				idc = 8004;
				x = 0.2;
				y = safeZoneY + 0.095;
				w = 0.6;
				h = 0.185;
				colorBackground[] = {0, 0, 0, 0.5};
			};
			class RscWLKillfeedDisplay_BadgeText: RscStructuredText {
				idc = 8005;
				style = ST_MULTI;
				x = 0.2;
				y = safeZoneY + 0.1;
				w = 0.6;
				h = 0.18;
				text = "";
				size = 0.05;
				class Attributes {
					align = "center";
					color = "#ffffff";
					font = "RobotoCondensed";
					shadowColor = "#000000";
				};
			};
		};
	};

	class RscWLScoreboardMenu {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLScoreboardMenu";
		onLoad = "uiNamespace setVariable ['RscWLScoreboardMenu', _this select 0];";
		class controls {
			class RscWLScoreboardMenu_Texture: RscText {
				type = 106;
				idc = 5502;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW;
				h = safeZoneH;
				url = "file://src/ui/gen/scoreboard.html";
			};
		};
	};

	class RscWLSpectatorMenu {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLSpectatorMenu";
		onLoad = "uiNamespace setVariable ['RscWLSpectatorMenu', _this select 0];";
		class controls {
			class RscWLSpectatorMenu_Texture: RscText {
				type = 106;
				idc = 5502;
				x = safeZoneX;
				y = safeZoneY;
				w = safeZoneW;
				h = safeZoneH;
				url = "file://src/ui/gen/spectator.html";
			};
		};
	};

	class RscWLTargetingDisplay {
		idd = -1;
		duration = 1000000000;
		fadein = 0;
		fadeout = 0;
		name = "RscWLTargetingDisplay";
		onLoad = "uiNamespace setVariable ['RscWLTargetingDisplay', _this select 0];";
		class controls {
			class RscWLTargetingDisplay_Main: RscStructuredText {
				idc = 6000;
				style = ST_MULTI;
				x = 0;
				y = 0;
				w = 1;
				h = 1;
				text = "";
				size = 0.032;
				class Attributes {
					color = "#14cb00";
					font = "EtelkaMonospaceProBold";
					shadowColor = "#000000";
				};
			};
			class RscWLTargetingDisplay_Incoming: RscStructuredText {
				idc = 6001;
				style = ST_MULTI;
				x = 0;
				y = 0;
				w = 0.4;
				h = 1;
				text = "";
				size = 0.028;
				class Attributes {
					color = "#14cb00";
					font = "EtelkaMonospaceProBold";
					shadowColor = "#000000";
				};
			};
			class RscWLTargetingDisplay_Status: RscStructuredText {
				idc = 6002;
				style = ST_MULTI;
				x = 0;
				y = safeZoneY + 0.25;
				w = 1;
				h = 1;
				text = "";
				size = 0.032;
				class Attributes {
					color = "#14cb00";
					font = "EtelkaMonospaceProBold";
					shadowColor = "#000000";
				};
			};
			class RscWLTargetingDisplay_Weapon: RscText {
				idc = 6003;
				x = 0;
				y = 0;
				w = 0;
				h = 0;
				font = "RobotoCondensed";
				style = ST_RIGHT;
				shadow = 0;
				text = "";
				sizeEx = 0.032;
				colorText[] = {1, 1, 1, 0.8};
				colorBackground[] = {0.5, 0.5, 0.5, 1};
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