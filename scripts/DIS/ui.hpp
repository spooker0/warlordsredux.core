#include "constants.inc"

import RscListBox;

class DIS_GPS_MenuUI {
    idd = DIS_GPS_DISPLAY;
    movingEnable = true;
    class controls {
        class DIS_GPS_Draggable: IGUIBackMRTM {
            idc = DIS_GPS_DRAGGABLE;
            x = 0;
            y = -0.05;
            w = 1;
            h = 0.05;
            colorBackground[] = {0, 0, 0, 1};
            moving = 1;
        };
        class DIS_GPS_TitleBar: RscText {
            idc = -1;
            x = 0.05;
            y = -0.05;
            w = 0.9;
            h = 0.05;
            text = "GPS Munition Configuration";
            style = ST_LEFT;
        };
        class DIS_GPS_Background: IGUIBackMRTM {
            idc = DIS_GPS_BACKGROUND;
            x = 0;
            y = 0;
            w = 1;
            h = 1;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
        class DIS_GPS_Frame: RscPicture {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 1.05;
            style = ST_PICTURE;
            colorText[] = {1, 1, 1, 1};
            text = "a3\ui_f\data\igui\rsctitles\interlacing\interlacing_ca.paa";
        };
        class DIS_GPS_CloseButton: RscCheckboxMRTM {
            idc = DIS_GPS_CLOSE_BUTTON;
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
        class DIS_GPS_Frame_T: RscPicture {
            idc = -1;
            x = 0;
            y = -0.1;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_T_ca.paa";
            moving = 1;
        };
        class DIS_GPS_Frame_B: RscPicture {
            idc = -1;
            x = 0;
            y = 0.97;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_B_ca.paa";
            moving = 1;
        };
        class DIS_GPS_Frame_L: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_L_ca.paa";
            moving = 1;
        };
        class DIS_GPS_Frame_R: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_R_ca.paa";
            moving = 1;
        };
        class DIS_GPS_Frame_TL: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TL_ca.paa";
            moving = 1;
        };
        class DIS_GPS_Frame_TR: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TR_ca.paa";
            moving = 1;
        };
        class DIS_GPS_Frame_BL: RscPicture {
            idc = -1;
            x = -0.05;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BL_ca.paa";
            moving = 1;
        };
        class DIS_GPS_Frame_BR: RscPicture {
            idc = -1;
            x = 0.975;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BR_ca.paa";
            moving = 1;
        };

        class DIS_GPS_InputLon: RscButton {
            idc = DIS_GPS_INPUTLON;
            x = 0.02;
            y = 0.02;
            w = 0.35;
            h = 0.2;

            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {0, 0, 0, 0};
            colorFocused[] = {0, 0, 0, 0};
            colorFocused2[] = {0, 0, 0, 0};
            colorSelection[] = {0, 0, 0, 0};
            colorShadow[] = {0, 0, 0, 0};

            shadow = 0;
            style = ST_LEFT;
            text = "000.0";
            font = "LCD14";
            sizeEx = 0.22;
        };
        class DIS_GPS_InputLat: RscButton {
            idc = DIS_GPS_INPUTLAT;
            x = 0.4;
            y = 0.02;
            w = 0.35;
            h = 0.2;

            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {0, 0, 0, 0};
            colorFocused[] = {0, 0, 0, 0};
            colorFocused2[] = {0, 0, 0, 0};
            colorSelection[] = {0, 0, 0, 0};
            colorShadow[] = {0, 0, 0, 0};

            shadow = 0;
            style = ST_LEFT;
            text = "000.0";
            font = "LCD14";
            sizeEx = 0.22;
        };

        class DIS_GPS_DatalinkList: RscListBox {
            idc = DIS_GPS_DATALINK_LIST;

            x = 0.1;
            y = 0.3;
            w = 0.8;
            h = 0.6;
            rowHeight = 0.05;

            deletable = 0;
            canDrag = 0;

            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {0, 0, 0, 0};
            colorFocused[] = {0, 0, 0, 0};
            colorFocused2[] = {0, 0, 0, 0};
            colorSelection[] = {0, 0, 0, 0};
            colorShadow[] = {0, 0, 0, 0};

            period = -1;
            type = CT_LISTBOX;
            autoScrollSpeed = -1;
            autoScrollDelay = 5;
            autoScrollRewind = 0;
            class ListScrollBar{
                color[] = {1,1,1,1};
                thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
            };
            style = LB_TEXTURES;
        };

        class DIS_GPS_SeaLevel: RscStructuredText {
            idc = DIS_GPS_SEALEVEL;
            x = 0.75;
            y = 0.02;
            w = 0.25;
            h = 0.2;

            shadow = 0;
            style = ST_CENTER;
            text = "???";
            sizeEx = 0.02;
        };

        class DIS_GPS_Sector: RscStructuredText {
            idc = DIS_GPS_SECTOR;
            x = 0.75;
            y = 0.14;
            w = 0.25;
            h = 0.1;

            shadow = 0;
            style = ST_CENTER;
            text = "???";
            sizeEx = 0.015;
        };
    };
};