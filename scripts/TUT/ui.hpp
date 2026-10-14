#include "includes.inc"

class TUT_MapLabel: RscText {
    style = ST_CENTER;
    font = "RobotoCondensedBold";
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0};
    shadow = 2;
};

class TUT_MenuButton: WLRscButtonMenu {
    colorDisabled[] = {1, 1, 1, 1};
    colorDisabledSecondary[] = {1, 1, 1, 1};
};

class TUT_Map: RscMapControl {
    x = safeZoneXAbs;
    y = safeZoneY;
    w = safeZoneWAbs;
    h = safeZoneH;
    showMarkers = 0;
    drawObjects = 0;
    moveOnEdges = 0;
    scaleMin = 0.001;
    scaleMax = 1.5;
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

class TUT_Canvas: TUT_Map {};

class TUT_Display {
    idd = TUT_DISPLAY_IDD;
    movingEnable = false;
    enableSimulation = true;
    onUnload = "_this call TUT_fnc_cleanup";

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
        class Map: TUT_Map {
            idc = TUT_MAP_IDC;
        };

        class Canvas: TUT_Canvas {
            idc = TUT_CANVAS_IDC;
        };

        // Keep the visible map rendering behind the opening logo for preloading.
        class LogoBackground: RscText {
            idc = TUT_LOGO_BACKGROUND_IDC;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH;
            colorBackground[] = {0.025, 0.035, 0.05, 1};
        };

        class Logo: RscPictureKeepAspect {
            idc = TUT_LOGO_IDC;
            text = "src\img\reduxlogosmall.paa";
            x = safeZoneX + safeZoneW * 0.14;
            y = safeZoneY + safeZoneH * 0.13;
            w = safeZoneW * 0.72;
            h = safeZoneH * 0.61;
            colorText[] = {1, 1, 1, 1};
        };

        class Labels: RscControlsGroupNoScrollbars {
            idc = TUT_LABELS_IDC;
            x = safeZoneXAbs;
            y = safeZoneY + safeZoneH * 0.08;
            w = safeZoneWAbs;
            h = safeZoneH * 0.81;
            class controls {};
        };

        class Hold: RscText {
            idc = TUT_HOLD_IDC;
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

        class FlareHeader: RscStructuredText {
            idc = TUT_FLARE_HEADER_IDC;
            x = safeZoneX + safeZoneW * 0.25;
            y = safeZoneY + safeZoneH * 0.30;
            w = safeZoneW * 0.50;
            h = safeZoneH * 0.12;
            size = safeZoneH * 0.036;
            colorBackground[] = {0, 0, 0, 0};
            class Attributes {
                font = "EtelkaMonospaceProBold";
                color = "#14CB00";
                align = "left";
                shadow = 2;
            };
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
            idc = TUT_SCENE_IDC;
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
            idc = TUT_PROGRESS_IDC;
            x = safeZoneXAbs;
            y = safeZoneY + safeZoneH * 0.99;
            w = safeZoneWAbs;
            h = safeZoneH * 0.003;
            colorFrame[] = {0, 0, 0, 0};
            colorBar[] = {0.15, 0.56, 0.88, 1};
            texture = "#(argb,8,8,3)color(1,1,1,1)";
        };
        class EndingBlack: RscText {
            idc = TUT_BLACKOUT_IDC;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH;
            fade = 1;
            colorBackground[] = {0, 0, 0, 1};
        };
        class EndingLogo: RscPictureKeepAspect {
            idc = TUT_ENDLOGO_IDC;
            text = "src\img\reduxlogosmall.paa";
            x = safeZoneX + safeZoneW * 0.12;
            y = safeZoneY + safeZoneH * 0.19;
            w = safeZoneW * 0.76;
            h = safeZoneH * 0.62;
            fade = 1;
            colorText[] = {1, 1, 1, 1};
        };
        class Caption: RscStructuredText {
            idc = TUT_CAPTION_IDC;
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
            idc = TUT_SKIP_BACKGROUND_IDC;
            text = "";
            x = safeZoneX + safeZoneW * 0.795;
            y = safeZoneY + safeZoneH * 0.018;
            w = safeZoneW * 0.17;
            h = safeZoneH * 0.044;
            colorBackground[] = {0.1, 0.15, 0.18, 1};
        };
        class SkipFill: RscProgress {
            idc = TUT_SKIP_FILL_IDC;
            x = safeZoneX + safeZoneW * 0.795;
            y = safeZoneY + safeZoneH * 0.018;
            w = safeZoneW * 0.17;
            h = safeZoneH * 0.044;
            colorFrame[] = {0, 0, 0, 0};
            colorBar[] = {0.15, 0.56, 0.88, 0.35};
            texture = "#(argb,8,8,3)color(1,1,1,1)";
        };
        class Skip: RscText {
            idc = TUT_SKIP_IDC;
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

class TUT_CarouselButton: RscButton {
    font = "RobotoCondensedBold";
    sizeEx = safeZoneH * 0.026;
    colorText[] = {0.94, 0.97, 1, 1};
    colorDisabled[] = {0.35, 0.40, 0.45, 1};
    colorBackground[] = {0.08, 0.16, 0.22, 1};
    colorBackgroundActive[] = {0.15, 0.38, 0.55, 1};
    colorBackgroundDisabled[] = {0.04, 0.07, 0.10, 1};
    colorFocused[] = {0.12, 0.30, 0.44, 1};
    colorShadow[] = {0, 0, 0, 0};
    borderSize = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
};

class TUT_Carousel {
    idd = TUT_CAROUSEL_IDD;
    movingEnable = false;
    enableSimulation = true;
    onUnload = "_this call TUT_fnc_cleanup";

    class controlsBackground {
        class Frame: RscText {
            x = safeZoneX + safeZoneW * 0.07;
            y = safeZoneY + safeZoneH * 0.07;
            w = safeZoneW * 0.86;
            h = safeZoneH * 0.86;
            colorBackground[] = {0.15, 0.32, 0.44, 1};
        };
        class Panel: RscText {
            x = safeZoneX + safeZoneW * 0.071;
            y = safeZoneY + safeZoneH * 0.072;
            w = safeZoneW * 0.858;
            h = safeZoneH * 0.856;
            colorBackground[] = {0.025, 0.035, 0.05, 1};
        };
    };

    class controls {
        class Map: TUT_Map {
            idc = TUT_MAP_IDC;
            x = TUT_VIEW_X;
            y = TUT_VIEW_Y;
            w = TUT_VIEW_W;
            h = TUT_VIEW_H;
        };
        class Canvas: TUT_Canvas {
            idc = TUT_CANVAS_IDC;
            x = TUT_VIEW_X;
            y = TUT_VIEW_Y;
            w = TUT_VIEW_W;
            h = TUT_VIEW_H;
        };
        class Labels: RscControlsGroupNoScrollbars {
            idc = TUT_LABELS_IDC;
            x = TUT_VIEW_X;
            y = TUT_VIEW_Y;
            w = TUT_VIEW_W;
            h = TUT_VIEW_H;
            class controls {};
        };
        class Header: RscText {
            idc = TUT_SCENE_IDC;
            style = ST_CENTER;
            x = safeZoneX + safeZoneW * 0.11;
            y = safeZoneY + safeZoneH * 0.087;
            w = safeZoneW * 0.78;
            h = safeZoneH * 0.045;
            font = "RobotoCondensedBold";
            sizeEx = safeZoneH * 0.028;
            colorText[] = {0.79, 0.86, 0.9, 1};
            colorBackground[] = {0, 0, 0, 0.6};
        };
        class FlareHeader: RscStructuredText {
            idc = TUT_FLARE_HEADER_IDC;
            x = safeZoneX + safeZoneW * 0.27;
            y = safeZoneY + safeZoneH * 0.18;
            w = safeZoneW * 0.46;
            h = safeZoneH * 0.11;
            size = safeZoneH * 0.032;
            colorBackground[] = {0, 0, 0, 0};
            class Attributes {
                font = "EtelkaMonospaceProBold";
                color = "#14CB00";
                align = "left";
                shadow = 2;
            };
        };
        class Caption: RscStructuredText {
            idc = TUT_CAPTION_IDC;
            x = safeZoneX + safeZoneW * 0.15;
            y = safeZoneY + safeZoneH * 0.805;
            w = safeZoneW * 0.70;
            h = safeZoneH * 0.03;
            size = safeZoneH * 0.027;
            class Attributes {
                font = "RobotoCondensed";
                color = "#FFFFFF";
                align = "center";
                shadow = 2;
            };
        };
        class Previous: TUT_CarouselButton {
            idc = TUT_PREVIOUS_IDC;
            text = "";
            tooltip = "$STR_WL_previous";
            x = TUT_VIEW_X;
            y = TUT_VIEW_Y;
            w = safeZoneW * 0.039;
            h = TUT_VIEW_H;
            sizeEx = safeZoneH * 0.042;
            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {0.5, 0.5, 0.5, 0.35};
            colorBackgroundDisabled[] = {0, 0, 0, 0};
            colorFocused[] = {0, 0, 0, 0};
        };
        class Next: Previous {
            idc = TUT_NEXT_IDC;
            tooltip = "$STR_WL_next";
            x = safeZoneX + safeZoneW * 0.890;
        };
        class PreviousIcon: RscPictureKeepAspect {
            idc = TUT_PREVIOUS_ICON_IDC;
            text = "\a3\Ui_F_Curator\Data\CfgMarkers\minefield_ca.paa";
            x = safeZoneX + safeZoneW * 0.0905 - safeZoneH * 0.02 * pixelW / pixelH;
            y = safeZoneY + safeZoneH * 0.48;
            w = safeZoneH * 0.04 * pixelW / pixelH;
            h = safeZoneH * 0.04;
            colorText[] = {0.94, 0.97, 1, 1};
        };
        class NextIcon: PreviousIcon {
            idc = TUT_NEXT_ICON_IDC;
            x = safeZoneX + safeZoneW * 0.9095 - safeZoneH * 0.02 * pixelW / pixelH;
        };
        class Continue: TUT_CarouselButton {
            idc = TUT_CONTINUE_IDC;
            text = "$STR_WL_next";
            x = safeZoneX + safeZoneW * 0.38;
            y = safeZoneY + safeZoneH * 0.844;
            w = safeZoneW * 0.24;
            h = safeZoneH * 0.055;
            colorBackground[] = {0.10, 0.32, 0.48, 1};
        };
        class Progress: RscProgress {
            idc = TUT_PROGRESS_IDC;
            x = safeZoneX + safeZoneW * 0.071;
            y = safeZoneY + safeZoneH * 0.922;
            w = safeZoneW * 0.858;
            h = safeZoneH * 0.004;
            colorFrame[] = {0, 0, 0, 0};
            colorBar[] = {0.15, 0.56, 0.88, 1};
            texture = "#(argb,8,8,3)color(1,1,1,1)";
        };
    };
};
