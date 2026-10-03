#include "includes.inc"

class INTRO_MapLabel: RscText {
    style = ST_CENTER;
    font = "RobotoCondensedBold";
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0};
    shadow = 2;
};

class INTRO_MenuButton: WLRscButtonMenu {
    colorDisabled[] = {1, 1, 1, 1};
    colorDisabledSecondary[] = {1, 1, 1, 1};
};

class INTRO_Display {
    idd = INTRO_DISPLAY_IDD;
    movingEnable = false;
    enableSimulation = true;
    onUnload = "_this call INTRO_fnc_cleanup";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH;
            colorBackground[] = {0.025, 0.035, 0.05, 1};
        };
    };

    class controls {
        class Map: RscMapControl {
            idc = INTRO_MAP_IDC;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH;
            showMarkers = 0;
            drawObjects = 0;
            moveOnEdges = 0;
            scaleMin = 0.001;
            maxSatelliteAlpha = 0.2;
            ptsPerSquareSea = 0;
            colorBackground[] = {0.07, 0.09, 0.11, 1};
            colorSea[] = {0.035, 0.075, 0.105, 1};
            colorForest[] = {0.075, 0.12, 0.105, 1};
            colorForestBorder[] = {0.09, 0.14, 0.12, 0.6};
            colorRocks[] = {0.16, 0.18, 0.19, 0.6};
            colorRocksBorder[] = {0.18, 0.2, 0.21, 0.5};
            colorCountlines[] = {0.19, 0.23, 0.25, 0.5};
            colorMainCountlines[] = {0.24, 0.28, 0.3, 0.65};
            colorCountlinesWater[] = {0.07, 0.12, 0.17, 0.4};
            colorMainCountlinesWater[] = {0.1, 0.16, 0.21, 0.5};
            colorRoads[] = {0.5, 0.55, 0.56, 1};
            colorRoadsFill[] = {0.27, 0.32, 0.34, 1};
            colorMainRoads[] = {0.67, 0.64, 0.48, 1};
            colorMainRoadsFill[] = {0.38, 0.37, 0.28, 1};
            colorLines[] = {0.2, 0.25, 0.28, 0.7};
            colorNames[] = {0, 0, 0, 0};
            colorGrid[] = {0, 0, 0, 0};
            colorGridMap[] = {0, 0, 0, 0};
            colorText[] = {0, 0, 0, 0};
            colorOutside[] = {0.025, 0.035, 0.05, 1};
        };

        // Keep the visible map rendering behind the opening logo for preloading.
        class LogoBackground: RscText {
            idc = INTRO_LOGO_BACKGROUND_IDC;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH;
            colorBackground[] = {0.025, 0.035, 0.05, 1};
        };

        class Logo: RscPictureKeepAspect {
            idc = INTRO_LOGO_IDC;
            text = "src\img\reduxlogosmall.paa";
            x = safeZoneX + safeZoneW * 0.14;
            y = safeZoneY + safeZoneH * 0.13;
            w = safeZoneW * 0.72;
            h = safeZoneH * 0.61;
            colorText[] = {1, 1, 1, 1};
        };

        class Labels: RscControlsGroupNoScrollbars {
            idc = INTRO_LABELS_IDC;
            x = safeZoneXAbs;
            y = safeZoneY + safeZoneH * 0.08;
            w = safeZoneWAbs;
            h = safeZoneH * 0.81;
            class controls {};
        };

        class Hold: RscText {
            idc = INTRO_HOLD_IDC;
            text = "";
            style = ST_CENTER;
            x = safeZoneX + safeZoneW * 0.05;
            y = safeZoneY + safeZoneH * 0.105;
            w = safeZoneW * 0.9;
            h = safeZoneH * 0.075;
            sizeEx = safeZoneH * 0.05;
            font = "RobotoCondensedBold";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0, 0, 0, 0};
            shadow = 2;
        };

        class HeaderBackground: RscText {
            idc = -1;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH * 0.08;
            colorBackground[] = {0.025, 0.035, 0.05, 0.94};
        };

        class Scene: RscStructuredText {
            idc = INTRO_SCENE_IDC;
            text = "$STR_WL_introHeader";
            x = safeZoneX + safeZoneW * 0.035;
            y = safeZoneY + safeZoneH * 0.021;
            w = safeZoneW * 0.73;
            h = safeZoneH * 0.045;
            size = safeZoneH * 0.025;
            colorText[] = {0.79, 0.86, 0.9, 1};
            shadow = 0;
            class Attributes {
                font = "RobotoCondensed";
                color = "#CADBE6";
                align = "left";
                valign = "middle";
                shadow = 0;
            };
        };

        class Progress: RscProgress {
            idc = INTRO_PROGRESS_IDC;
            x = safeZoneXAbs;
            y = safeZoneY + safeZoneH * 0.99;
            w = safeZoneWAbs;
            h = safeZoneH * 0.003;
            colorFrame[] = {0, 0, 0, 0};
            colorBar[] = {0.15, 0.56, 0.88, 1};
            texture = "#(argb,8,8,3)color(1,1,1,1)";
        };
        class EndingBlack: RscText {
            idc = INTRO_BLACKOUT_IDC;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH;
            fade = 1;
            colorBackground[] = {0, 0, 0, 1};
        };
        class EndingLogo: RscPictureKeepAspect {
            idc = INTRO_ENDLOGO_IDC;
            text = "src\img\reduxlogosmall.paa";
            x = safeZoneX + safeZoneW * 0.12;
            y = safeZoneY + safeZoneH * 0.19;
            w = safeZoneW * 0.76;
            h = safeZoneH * 0.62;
            fade = 1;
            colorText[] = {1, 1, 1, 1};
        };
        class Caption: RscStructuredText {
            idc = INTRO_CAPTION_IDC;
            text = "";
            x = safeZoneX + safeZoneW * 0.06;
            y = safeZoneY + safeZoneH * 0.905;
            w = safeZoneW * 0.88;
            h = safeZoneH * 0.078;
            size = safeZoneH * 0.034;
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0, 0, 0, 0};
            shadow = 2;
            class Attributes {
                font = "RobotoCondensed";
                color = "#FFFFFF";
                align = "center";
                valign = "middle";
                shadow = 2;
            };
        };
        class SkipBackground: RscText {
            idc = INTRO_SKIP_BACKGROUND_IDC;
            text = "";
            x = safeZoneX + safeZoneW * 0.795;
            y = safeZoneY + safeZoneH * 0.018;
            w = safeZoneW * 0.17;
            h = safeZoneH * 0.044;
            colorBackground[] = {0.1, 0.15, 0.18, 1};
        };
        class SkipFill: RscProgress {
            idc = INTRO_SKIP_FILL_IDC;
            x = safeZoneX + safeZoneW * 0.795;
            y = safeZoneY + safeZoneH * 0.018;
            w = safeZoneW * 0.17;
            h = safeZoneH * 0.044;
            colorFrame[] = {0, 0, 0, 0};
            colorBar[] = {0.15, 0.56, 0.88, 0.35};
            texture = "#(argb,8,8,3)color(1,1,1,1)";
        };
        class Skip: RscText {
            idc = INTRO_SKIP_IDC;
            text = "";
            style = ST_CENTER;
            x = safeZoneX + safeZoneW * 0.795;
            y = safeZoneY + safeZoneH * 0.018;
            w = safeZoneW * 0.17;
            h = safeZoneH * 0.044;
            sizeEx = safeZoneH * 0.026;
            font = "RobotoCondensed";
            shadow = 0;
            colorText[] = {0.88, 0.93, 0.96, 1};
            colorBackground[] = {0, 0, 0, 0};
        };
    };
};
