#include "constants.inc"

import RscEdit;
import RscCheckBox;

class MENU_Settings {
    idd = MENU_DISPLAY;
    movingEnable = true;
    class controls {
        class MENU_Draggable: IGUIBackMRTM {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 0.05;
            colorBackground[] = {0, 0, 0, 1};
            moving = 1;
        };
        class MENU_TitleBar: RscText {
            idc = -1;
            x = 0.05;
            y = -0.05;
            w = 0.9;
            h = 0.05;
            text = "Settings Menu";
            style = ST_LEFT;
        };
        class MENU_Background: IGUIBackMRTM {
            idc = -1;
            x = 0;
            y = 0;
            w = 1;
            h = 1;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
        class MENU_Frame: RscPicture {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 1.05;
            style = ST_PICTURE;
            colorText[] = {1, 1, 1, 1};
            text = "a3\ui_f\data\igui\rsctitles\interlacing\interlacing_ca.paa";
        };
        class MENU_CloseButton: RscCheckboxMRTM {
            idc = MENU_CLOSE_BUTTON;
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
        class MENU_Frame_T: RscPicture {
            idc = -1;
            x = 0;
            y = -0.1;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_T_ca.paa";
            moving = 1;
        };
        class MENU_Frame_B: RscPicture {
            idc = -1;
            x = 0;
            y = 0.97;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_B_ca.paa";
            moving = 1;
        };
        class MENU_Frame_L: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_L_ca.paa";
            moving = 1;
        };
        class MENU_Frame_R: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_R_ca.paa";
            moving = 1;
        };
        class MENU_Frame_TL: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TL_ca.paa";
            moving = 1;
        };
        class MENU_Frame_TR: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TR_ca.paa";
            moving = 1;
        };
        class MENU_Frame_BL: RscPicture {
            idc = -1;
            x = -0.05;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BL_ca.paa";
            moving = 1;
        };
        class MENU_Frame_BR: RscPicture {
            idc = -1;
            x = 0.975;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BR_ca.paa";
            moving = 1;
        };

        class MENU_Controls: RscControlsGroup {
            idc = MENU_CONTROLS_GROUP;
            deletable = 0;
            fade = 0;
            type = CT_CONTROLS_GROUP;

            x = 0;
            y = 0;
            w = 1;
            h = 1;
            shadow = 0;
            style = ST_MULTI;

            class VScrollbar: ScrollBar {
                color[] = {1,1,1,1};
                width = 0.021;
                autoScrollEnabled = 1;
            };
            class HScrollbar: ScrollBar {
                height = 0;
            };
            class controls {};
        };
    };
};

class MENU_MenuItemLabel: RscStructuredText {
    idc = -1;
    sizeEx = 0.04;
    text = "Text";
    colorText[] = {1, 1, 1, 1};
    font = "PuristaMedium";
    shadow = 0;
    style = ST_LEFT;
};

class MENU_MenuItemSliderControl: RscStructuredText {
    idc = -1;
    style = SL_HORZ;
	type = CT_XSLIDER;
    shadow = 0;
	color[] = {1, 1, 1, 1};
	arrowEmpty = "\A3\ui_f\data\gui\cfg\slider\arrowEmpty_ca.paa";
	arrowFull = "\A3\ui_f\data\gui\cfg\slider\arrowFull_ca.paa";
	border = "\A3\ui_f\data\gui\cfg\slider\border_ca.paa";
	thumb = "\A3\ui_f\data\gui\cfg\slider\thumb_ca.paa";
};

class MENU_MenuItemSliderEntry: RscEdit {
    idc = -1;
    sizeEx = 0.035;
    text = "";
    color[] = {1, 1, 1, 1};
    font = "PuristaMedium";
    shadow = 0;
};

class MENU_MenuItemCheckbox: RscCheckBox {
    idc = -1;
    sizeEx = 0.035;
    text = "";
    colorText[] = {1, 1, 1, 1};
};

class MENU_MenuItemButton: RscButton {
    idc = -1;
    sizeEx = 0.035;
    text = "Text";
    colorText[] = {1, 1, 1, 1};
    font = "PuristaMedium";
    shadow = 0;
    style = ST_CENTER;
};

class MENU_DebugConsole {
    idd = DEBUG_DISPLAY;
    movingEnable = true;
    class controls {
        class DEBUG_Draggable: IGUIBackMRTM {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 0.05;
            colorBackground[] = {0, 0, 0, 1};
            moving = 1;
        };
        class DEBUG_TitleBar: RscText {
            idc = -1;
            x = 0.05;
            y = -0.05;
            w = 0.9;
            h = 0.05;
            text = "Debug Menu";
            style = ST_LEFT;
        };
        class DEBUG_Background: IGUIBackMRTM {
            idc = -1;
            x = 0;
            y = 0;
            w = 1;
            h = 1;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
        class DEBUG_Frame: RscPicture {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 1.05;
            style = ST_PICTURE;
            colorText[] = {1, 1, 1, 1};
            text = "a3\ui_f\data\igui\rsctitles\interlacing\interlacing_ca.paa";
        };
        class DEBUG_CloseButton: RscCheckboxMRTM {
            idc = DEBUG_CLOSE_BUTTON;
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
        class DEBUG_Frame_T: RscPicture {
            idc = -1;
            x = 0;
            y = -0.1;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_T_ca.paa";
            moving = 1;
        };
        class DEBUG_Frame_B: RscPicture {
            idc = -1;
            x = 0;
            y = 0.97;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_B_ca.paa";
            moving = 1;
        };
        class DEBUG_Frame_L: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_L_ca.paa";
            moving = 1;
        };
        class DEBUG_Frame_R: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_R_ca.paa";
            moving = 1;
        };
        class DEBUG_Frame_TL: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TL_ca.paa";
            moving = 1;
        };
        class DEBUG_Frame_TR: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TR_ca.paa";
            moving = 1;
        };
        class DEBUG_Frame_BL: RscPicture {
            idc = -1;
            x = -0.05;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BL_ca.paa";
            moving = 1;
        };
        class DEBUG_Frame_BR: RscPicture {
            idc = -1;
            x = 0.975;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BR_ca.paa";
            moving = 1;
        };

        class DEBUG_Exec: RscText {
			idc = -1;
			x = 0.05;
			y = 0;
			w = 0.9;
			h = 0.05;
			text = "Execute";
			colorBackground[] = {0, 0, 0, 0};
		};
		class DEBUG_ExecEdit: RscEdit {
			idc = DEBUG_EXEC_EDIT;
            x = 0.05;
			y = 0.05;
			w = 0.9;
			h = 0.65;
			colorBackground[] = {0, 0, 0, 0};
			autocomplete = "scripting";
			type = CT_EDIT;
			style = ST_MULTI;
		};
		class DEBUG_Return: RscStructuredText {
			idc = -1;
            x = 0.05;
			y = 0.7;
			w = 0.9;
			h = 0.05;
			text = "Return value";
			colorBackground[] = {0, 0, 0, 0};
		};
		class DEBUG_ReturnReadOnly: RscEdit {
			idc = DEBUG_EXEC_RETURN;
            x = 0.05;
			y = 0.75;
			w = 0.9;
			h = 0.2;
			canModify = 0;
			colorBackground[] = {0, 0, 0, 0};
			autocomplete = "";
			type = CT_EDIT;
			style = ST_MULTI;
		};
		class DEBUG_ServerExecButton: RscButton {
			idc = DEBUG_SERVER_EXEC_BUTTON;
            x = 0.05;
			y = 0.95;
			w = 0.4;
			h = 0.05;
			text = "SERVER";
			sizeEx = "0.04";
			colorBackground[] = {1, 0, 0, 1};
		};
		class DEBUG_LocalExecButton: RscButton {
			idc = DEBUG_LOCAL_EXEC_BUTTON;
            x = 0.55;
			y = 0.95;
			w = 0.4;
			h = 0.05;
			text = "LOCAL";
			sizeEx = "0.04";
			colorBackground[] = {0, 1, 0, 1};
		};
    };
};

class MODR_Menu {
    idd = MODR_DISPLAY;
    movingEnable = true;
    class controls {
        class MODR_Draggable: IGUIBackMRTM {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 0.05;
            colorBackground[] = {0, 0, 0, 1};
            moving = 1;
        };
        class MODR_TitleBar: RscText {
            idc = MODR_TITLE_BAR;
            x = 0.05;
            y = -0.05;
            w = 0.9;
            h = 0.05;
            text = "Moderator Menu";
            style = ST_LEFT;
        };
        class MODR_Background: IGUIBackMRTM {
            idc = -1;
            x = 0;
            y = 0;
            w = 1;
            h = 1;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
        class MODR_Frame: RscPicture {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 1.05;
            style = ST_PICTURE;
            colorText[] = {1, 1, 1, 1};
            text = "a3\ui_f\data\igui\rsctitles\interlacing\interlacing_ca.paa";
        };
        class MODR_CloseButton: RscCheckboxMRTM {
            idc = MODR_CLOSE_BUTTON;
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
        class MODR_Frame_T: RscPicture {
            idc = -1;
            x = 0;
            y = -0.1;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_T_ca.paa";
            moving = 1;
        };
        class MODR_Frame_B: RscPicture {
            idc = -1;
            x = 0;
            y = 0.97;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_B_ca.paa";
            moving = 1;
        };
        class MODR_Frame_L: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_L_ca.paa";
            moving = 1;
        };
        class MODR_Frame_R: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_R_ca.paa";
            moving = 1;
        };
        class MODR_Frame_TL: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TL_ca.paa";
            moving = 1;
        };
        class MODR_Frame_TR: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TR_ca.paa";
            moving = 1;
        };
        class MODR_Frame_BL: RscPicture {
            idc = -1;
            x = -0.05;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BL_ca.paa";
            moving = 1;
        };
        class MODR_Frame_BR: RscPicture {
            idc = -1;
            x = 0.975;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BR_ca.paa";
            moving = 1;
        };

        class MODR_PlayerList: RscListBox {
            idc = MODR_PLAYER_LIST;
            x = 0.05;
            y = 0.05;
            w = 0.3;
            h = 0.6;
            colorBackground[] = {0, 0, 0, 0.4};
            font = "PuristaMedium";
            sizeEx = 0.035;
            rowHeight = 0.04;
        };
        class MODR_InfoDisplay: RscEdit {
            idc = MODR_INFO_DISPLAY;
            x = 0.38;
            y = 0.05;
            w = 0.57;
            h = 0.18;
            colorBackground[] = {0, 0, 0, 0.4};
            font = "EtelkaMonospacePro";
            style = ST_MULTI;
            sizeEx = 0.034;
            canModify = 0;
            text = "Loading...";
        };
        class MODR_TimeoutText: RscText {
            idc = MODR_TIMEOUT_REASON_LABEL;
            x = 0.38;
            y = 0.25;
            w = 0.1;
            h = 0.045;
            text = "Reason:";
            colorBackground[] = {0, 0, 0, 0};
        };
        class MODR_TimeoutReason: RscEdit {
            idc = MODR_TIMEOUT_REASON;
            x = 0.50;
            y = 0.25;
            w = 0.45;
            h = 0.045;
            colorBackground[] = {0, 0, 0, 0.4};
            font = "PuristaMedium";
            sizeEx = 0.035;
            text = "unsportsmanlike conduct";
        };
        class MODR_TimeoutTime: RscStructuredText {
            idc = MODR_TIMEOUT_TIME;
            x = 0.38;
            y = 0.31;
            w = 0.57;
            h = 0.04;
            style = SL_HORZ;
            type = CT_XSLIDER;
            shadow = 0;
            color[] = {1, 1, 1, 1};
            sliderPosition = 10;
            sliderRange[] = {1, 600};
            sliderStep = 1;
            arrowEmpty = "\A3\ui_f\data\gui\cfg\slider\arrowEmpty_ca.paa";
            arrowFull = "\A3\ui_f\data\gui\cfg\slider\arrowFull_ca.paa";
            border = "\A3\ui_f\data\gui\cfg\slider\border_ca.paa";
            thumb = "\A3\ui_f\data\gui\cfg\slider\thumb_ca.paa";
        };
        class MODR_TimeoutButton: RscButton {
            idc = MODR_TIMEOUT_BUTTON;
            x = 0.38;
            y = 0.36;
            w = 0.57;
            h = 0.05;
            text = "Timeout";
            sizeEx = 0.04;
            colorBackground[] = {1, 0, 0, 1};
        };

        class MODR_ChatHistory: RscEdit {
            idc = MODR_CHAT_HISTORY;
            x = 0.05;
            y = 0.68;
            w = 0.9;
            h = 0.28;
            colorBackground[] = {0, 0, 0, 0.4};
            font = "PuristaMedium";
            style = ST_MULTI;
            canModify = 0;
            sizeEx = 0.03;
        };

        class MODR_CopyChat5: RscButton {
            idc = MODR_CHAT_HISTORY_COPY_5;
            x = 0.63;
            y = 0.96;
            w = 0.10;
            h = 0.035;
            text = "COPY 5";
            sizeEx = 0.035;
            colorBackground[] = {0, 0, 0, 0.6};
        };
        class MODR_CopyChat20: RscButton {
            idc = MODR_CHAT_HISTORY_COPY_20;
            x = 0.74;
            y = 0.96;
            w = 0.10;
            h = 0.035;
            text = "COPY 20";
            sizeEx = 0.035;
            colorBackground[] = {0, 0, 0, 0.6};
        };
        class MODR_CopyChatAll: RscButton {
            idc = MODR_CHAT_HISTORY_COPY_ALL;
            x = 0.85;
            y = 0.96;
            w = 0.10;
            h = 0.035;
            text = "COPY ALL";
            sizeEx = 0.035;
            colorBackground[] = {0, 0, 0, 0.6};
        };

        class MODR_ReportTable: RscListBox {
            idc = MODR_REPORT_TABLE;
            x = 0.38;
            y = 0.42;
            w = 0.57;
            h = 0.19;
            colorBackground[] = {0, 0, 0, 0.4};
            font = "PuristaMedium";
            sizeEx = 0.035;
            rowHeight = 0.04;
        };
        class MODR_ClearReports: RscButton {
            idc = MODR_CLEAR_REPORTS;
            x = 0.38;
            y = 0.62;
            w = 0.17;
            h = 0.04;
            text = "CLEAR REPORTS";
            sizeEx = 0.035;
            colorBackground[] = {1, 0, 0, 1};
        };
        class MODR_Rebalance: RscButton {
            idc = MODR_REBALANCE;
            x = 0.78;
            y = 0.62;
            w = 0.17;
            h = 0.04;
            text = "REBALANCE";
            sizeEx = 0.035;
            colorBackground[] = {1, 0, 0, 1};
        };

        class MODR_ClearTimeout: RscButton {
            idc = MODR_CLEAR_TIMEOUT;
            x = 0.05;
            y = 0.96;
            w = 0.25;
            h = 0.035;
            text = "CLEAR ALL TIMEOUTS";
            sizeEx = 0.035;
            colorBackground[] = {1, 0, 0, 1};
        };
    };
};