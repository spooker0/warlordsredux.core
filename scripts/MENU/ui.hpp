#include "includes.inc"
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

class WL2_SettingsMenu_Button: RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = SETTINGS_BUTTON_W;
    h = SETTINGS_BUTTON_H;

    class controls {
        class Button: RscButton {
            idc = SETTINGS_BUTTON_CONTROL_ID;
            text = "";
            x = 0;
            y = 0;
            w = SETTINGS_BUTTON_W;
            h = SETTINGS_BUTTON_H;
            sizeEx = SETTINGS_TEXT_SIZE;
        };
        class Icon: RscPictureKeepAspect {
            idc = SETTINGS_BUTTON_ICON_ID;
            text = "";
            x = SETTINGS_PADDING_X * 0.5;
            y = SETTINGS_PADDING_Y * 0.5;
            w = SETTINGS_BUTTON_H - SETTINGS_PADDING_Y;
            h = SETTINGS_BUTTON_H - SETTINGS_PADDING_Y;
        };
    };
};

class WL2_SettingsMenu_Category: RscText {
    idc = -1;
    text = "";
    x = 0;
    y = 0;
    w = SETTINGS_CONTENT_ROW_W;
    h = SETTINGS_CATEGORY_H;
    sizeEx = SETTINGS_TEXT_SIZE;
    colorBackground[] = {MENU_RGBA_CATEGORY};
};

class WL2_SettingsMenu_Slider: RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = SETTINGS_CONTENT_ROW_W;
    h = SETTINGS_SLIDER_H;

    class controls {
        class Background: RscText {
            idc = -1;
            x = 0;
            y = 0;
            w = SETTINGS_CONTENT_ROW_W;
            h = SETTINGS_SLIDER_H;
            colorBackground[] = {MENU_RGBA_ROW};
        };
        class Label: RscStructuredText {
            idc = SETTINGS_SLIDER_LABEL_ID;
            text = "";
            x = SETTINGS_PADDING_X;
            y = SETTINGS_SLIDER_H / 2 - SETTINGS_TEXT_SIZE / 2;
            w = SETTINGS_SLIDER_LABEL_W - SETTINGS_PADDING_X;
            h = SETTINGS_TEXT_SIZE;
            size = SETTINGS_TEXT_SIZE;
        };
        class Slider: RscXSliderH {
            idc = SETTINGS_SLIDER_CONTROL_ID;
            x = SETTINGS_SLIDER_X;
            y = SETTINGS_SLIDER_H * 0.24;
            w = SETTINGS_SLIDER_W;
            h = SETTINGS_SLIDER_H * 0.52;
        };
        class Value: RscText {
            idc = SETTINGS_SLIDER_VALUE_ID;
            text = "";
            x = SETTINGS_SLIDER_VALUE_X;
            y = 0;
            w = SETTINGS_SLIDER_VALUE_W;
            h = SETTINGS_SLIDER_H;
            sizeEx = SETTINGS_TEXT_SIZE;
            colorText[] = {MENU_RGBA_TEXT};
        };
    };
};

class WL2_SettingsMenu_Checkbox: RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = SETTINGS_CONTENT_ROW_W;
    h = SETTINGS_CHECKBOX_H;

    class controls {
        class Background: RscText {
            idc = -1;
            x = 0;
            y = 0;
            w = SETTINGS_CONTENT_ROW_W;
            h = SETTINGS_CHECKBOX_H;
            colorBackground[] = {MENU_RGBA_ROW};
        };
        class Label: RscStructuredText {
            idc = SETTINGS_CHECKBOX_LABEL_ID;
            text = "";
            x = SETTINGS_PADDING_X;
            y = SETTINGS_CHECKBOX_H / 2 - SETTINGS_TEXT_SIZE / 2;
            w = SETTINGS_CHECKBOX_X - SETTINGS_PADDING_X;
            h = SETTINGS_TEXT_SIZE;
            size = SETTINGS_TEXT_SIZE;
        };
        class Checkbox: RscCheckBox {
            idc = SETTINGS_CHECKBOX_CONTROL_ID;
            x = SETTINGS_CHECKBOX_X;
            y = (SETTINGS_CHECKBOX_H - SETTINGS_CHECKBOX_SIZE) * 0.5;
            w = SETTINGS_CHECKBOX_SIZE * 3 / 4;
            h = SETTINGS_CHECKBOX_SIZE;
            color[] = {MENU_RGBA_TEXT};
        };
    };
};

class WL2_SettingsMenu {
    idd = SETTINGS_IDD;

    class controlsBackground {
        class Background: RscText {
            idc = SETTINGS_BACKGROUND_ID;
            x = SETTINGS_MENU_X;
            y = SETTINGS_MENU_Y;
            w = SETTINGS_MENU_W;
            h = SETTINGS_MENU_H;
            colorBackground[] = {MENU_RGBA_BG};
        };
    };
    class controls {
        class Title: RscText {
            idc = SETTINGS_TITLE_ID;
            text = "Settings";
            x = SETTINGS_MENU_X;
            y = SETTINGS_MENU_Y;
            w = SETTINGS_MENU_W;
            h = SETTINGS_HEADER_H;
            sizeEx = SETTINGS_TITLE_SIZE;
            colorBackground[] = {MENU_RGBA_HEADER};
        };
        class Close: RscButton {
            idc = SETTINGS_CLOSE_ID;
            text = "A3\ui_f\data\map\groupicons\waypoint.paa";
            style = ST_CENTER + ST_PICTURE;
            x = SETTINGS_MENU_X + SETTINGS_MENU_W - SETTINGS_HEADER_H * 3 / 4;
            y = SETTINGS_MENU_Y;
            w = SETTINGS_HEADER_H * 3 / 4;
            h = SETTINGS_HEADER_H;
        };
        class Buttons: RscControlsGroupNoScrollbars {
            idc = SETTINGS_BUTTONS_GROUP_ID;
            x = SETTINGS_INNER_X;
            y = SETTINGS_BUTTONS_Y;
            w = SETTINGS_INNER_W;
            h = SETTINGS_BUTTON_H;
            class controls {};
        };
        class Search: RscEdit {
            idc = SETTINGS_SEARCH_ID;
            text = "";
            tooltip = "Search";
            x = SETTINGS_INNER_X;
            y = SETTINGS_BUTTONS_Y + SETTINGS_BUTTON_H + SETTINGS_CONTENT_GAP;
            w = SETTINGS_INNER_W;
            h = SETTINGS_SEARCH_H;
            sizeEx = SETTINGS_TEXT_SIZE;
            colorBackground[] = {MENU_RGBA_ROW};
        };
        class Content: RscControlsGroupNoScrollbars {
            idc = SETTINGS_CONTENT_GROUP_ID;
            x = SETTINGS_INNER_X;
            y = SETTINGS_BUTTONS_Y + SETTINGS_BUTTON_H + SETTINGS_CONTENT_GAP + SETTINGS_SEARCH_H + SETTINGS_SEARCH_GAP;
            w = SETTINGS_INNER_W;
            h = SETTINGS_CONTENT_BOTTOM - (SETTINGS_BUTTONS_Y + SETTINGS_BUTTON_H + SETTINGS_CONTENT_GAP + SETTINGS_SEARCH_H + SETTINGS_SEARCH_GAP);
            class controls {};
        };
    };
};