#include "constants.inc"

class PERF_Menu {
    idd = PERF_DISPLAY;
    movingEnable = true;
    class controls {
        class PERF_Draggable: IGUIBackMRTM {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 0.05;
            colorBackground[] = {0, 0, 0, 1};
            moving = 1;
        };
        class PERF_TitleBar: RscText {
            idc = -1;
            x = 0.05;
            y = -0.05;
            w = 0.9;
            h = 0.05;
            text = "Performance Menu";
            style = ST_LEFT;
        };
        class PERF_Background: IGUIBackMRTM {
            idc = -1;
            x = 0;
            y = 0;
            w = 1;
            h = 1;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
        class PERF_Frame: RscPicture {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 1.05;
            style = ST_PICTURE;
            colorText[] = {1, 1, 1, 1};
            text = "a3\ui_f\data\igui\rsctitles\interlacing\interlacing_ca.paa";
        };
        class PERF_CloseButton: RscCheckboxMRTM {
            idc = PERF_CLOSE_BUTTON;
            sizeEx = "0.021 / (getResolution select 5)";
            x = 1 - 0.0375;
            y = -0.05;
            w = 0.0375;
            h = 0.05;
            colorBackgroundHover[] = {1, 1, 1, 0.3};
            font = "PuristaMedium";
            textureUnChecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            textureChecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            textureFocusedChecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            textureFocusedUnchecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            textureHoverChecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            textureHoverUnchecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            texturePressedChecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            texturePressedUnchecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            textureDisabledChecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
            textureDisabledUnchecked = "\A3\ui_f\data\map\groupicons\waypoint.paa";
        };
        class PERF_Frame_T: RscPicture {
            idc = -1;
            x = 0;
            y = -0.1;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_T_ca.paa";
            moving = 1;
        };
        class PERF_Frame_B: RscPicture {
            idc = -1;
            x = 0;
            y = 0.97;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_B_ca.paa";
            moving = 1;
        };
        class PERF_Frame_L: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_L_ca.paa";
            moving = 1;
        };
        class PERF_Frame_R: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_R_ca.paa";
            moving = 1;
        };
        class PERF_Frame_TL: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TL_ca.paa";
            moving = 1;
        };
        class PERF_Frame_TR: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TR_ca.paa";
            moving = 1;
        };
        class PERF_Frame_BL: RscPicture {
            idc = -1;
            x = -0.05;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BL_ca.paa";
            moving = 1;
        };
        class PERF_Frame_BR: RscPicture {
            idc = -1;
            x = 0.975;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BR_ca.paa";
            moving = 1;
        };

        class PERF_ERROR: RscStructuredText {
            idc = PERF_ERROR_TEXT;
            x = 0.05;
            y = 0.05;
            w = 0.9;
            h = 0.15;
            text = "";
            style = ST_CENTER;
            colorText[] = {1, 1, 1, 1};
        };
        class PERF_LOWFPS: RscText {
            idc = PERF_LOWFPS_TEXT;
            x = 0.05;
            y = 0.1;
            w = 0.6;
            h = 0.12;
            text = "0 FPS";
            style = ST_CENTER;
            sizeEx = "0.05";
            colorText[] = {1, 1, 1, 1};
        };
        class PERF_LOWFPS_CLEAR: RscButton {
            idc = PERF_LOWFPS_CLEAR_BUTTON;
            x = 0.65;
            y = 0.1;
            w = 0.30;
            h = 0.12;
            text = "Clear Longest Frame";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
        class PERF_CAPTURE_ENTRY: RscEdit {
            idc = PERF_CAPTURE_ENTRY_TEXT;
            x = 0.05;
            y = 0.35;
            w = 0.25;
            h = 0.08;
            text = "0";
            style = ST_RIGHT;
            sizeEx = "0.05";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
        class PERF_CAPTURE_ENTRY_LABEL: RscText {
            idc = PERF_CAPTURE_MS_LABEL;
            x = 0.32;
            y = 0.35;
            w = 0.1;
            h = 0.08;
            text = "ms";
            style = ST_LEFT;
            sizeEx = "0.05";
            colorText[] = {1, 1, 1, 1};
        };
        class PERF_CAPTURE_BUTTON: RscButton {
            idc = PERF_CAPTURE_BUTTON;
            x = 0.45;
            y = 0.35;
            w = 0.5;
            h = 0.08;
            text = "Capture Frame";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
    };
};