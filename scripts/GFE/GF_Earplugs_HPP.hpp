//________________	Author : GEORGE FLOROS [GR]	___________	29.03.19	___________


/*
________________	GF Earplugs Script - Mod	________________
https://forums.bohemia.net/forums/topic/215844-gf-earplugs-script-mod/
*/

class Rsc_GF_Earplugs {
	idd = -1;
	duration = 1000000000;
	fadein = 0;
	fadeout = 0;
	class controls {
		class Rsc_GF_Earplugs_Control {
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