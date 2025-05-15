#include "constants.inc"

import RscShortcutButton;

class RscPollOption: RscShortcutButton {
    animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureDisabled = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureOver = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)";
	animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)";
	colorBackground[] = {0,0,0,0.8};
	colorBackgroundFocused[] = {1,1,1,1};
	colorBackground2[] = {0.75,0.75,0.75,1};
	color[] = {1,1,1,1};
	colorFocused[] = {0,0,0,1};
	color2[] = {0,0,0,1};
	colorText[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.25};

    sizeEx = 0.05;
    w = 0.9;
    h = 0.13;
    font = "PuristaMedium";

    class Attributes {
		font = "PuristaLight";
		color = "#E5E5E5";
		align = "left";
		shadow = "false";
	};
};

class RscPollEdit: RscEdit {
    colorBackground[] = {0, 0, 0, 0.8};
	color[] = {1, 1, 1, 1};
	colorText[] = {1, 1, 1, 1};
	colorDisabled[] = {1, 1, 1, 0.25};

    sizeEx = 0.05;
    w = 0.9;
    h = 0.13;
    font = "PuristaMedium";
};

class POLL_MenuUI {
    idd = POLL_DISPLAY;
    movingEnable = true;
    class controls {
        class POLL_Draggable: IGUIBackMRTM {
            idc = 12001;
            x = 0;
            y = -0.05;
            w = 1;
            h = 0.05;
            colorBackground[] = {0, 0, 0, 1};
            moving = 1;
        };
        class POLL_TitleBar: RscText {
            idc = POLL_TITLE;
            x = 0.05;
            y = -0.05;
            w = 0.9;
            h = 0.05;
            text = "OFFICIAL POLL";
            style = ST_LEFT;
        };
        class POLL_Background: IGUIBackMRTM {
            idc = POLL_BG;
            x = 0;
            y = 0;
            w = 1;
            h = 1;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
        class POLL_Frame: RscPicture {
            idc = -1;
            x = 0;
            y = -0.05;
            w = 1;
            h = 1.05;
            style = ST_PICTURE;
            colorText[] = {1, 1, 1, 1};
            text = "a3\ui_f\data\igui\rsctitles\interlacing\interlacing_ca.paa";
        };
        class POLL_CloseButton: RscCheckboxMRTM {
            idc = POLL_CLOSE;
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
        class POLL_Frame_T: RscPicture {
            idc = -1;
            x = 0;
            y = -0.1;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_T_ca.paa";
            moving = 1;
        };
        class POLL_Frame_B: RscPicture {
            idc = -1;
            x = 0;
            y = 0.97;
            w = 1;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_B_ca.paa";
            moving = 1;
        };
        class POLL_Frame_L: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_L_ca.paa";
            moving = 1;
        };
        class POLL_Frame_R: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.05;
            w = 0.08;
            h = 1.05;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_R_ca.paa";
            moving = 1;
        };
        class POLL_Frame_TL: RscPicture {
            idc = -1;
            x = -0.05;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TL_ca.paa";
            moving = 1;
        };
        class POLL_Frame_TR: RscPicture {
            idc = -1;
            x = 0.975;
            y = -0.1;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_TR_ca.paa";
            moving = 1;
        };
        class POLL_Frame_BL: RscPicture {
            idc = -1;
            x = -0.05;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BL_ca.paa";
            moving = 1;
        };
        class POLL_Frame_BR: RscPicture {
            idc = -1;
            x = 0.975;
            y = 0.97;
            w = 0.08;
            h = 0.08;
            style = ST_PICTURE;
            text = "A3\ui_f\data\GUI\Rsc\RscMiniMapSmall\GPS_BR_ca.paa";
            moving = 1;
        };

        class POLL_Question: RscText {
            idc = POLL_QUESTION;
            x = 0.05;
            y = 0.02;
            w = 0.9;
            h = 0.15;
            text = "Question:";
            sizeEx = 0.05;
            style = ST_MULTI;
        };

        class POLL_Option1: RscPollOption {
            idc = POLL_OPTION_1;
            x = 0.05;
            y = 0.20;
            text = "Option 1";
        };
        class POLL_Option2: RscPollOption {
            idc = POLL_OPTION_2;
            x = 0.05;
            y = 0.35;
            text = "Option 2";
        };
        class POLL_Option3: RscPollOption {
            idc = POLL_OPTION_3;
            x = 0.05;
            y = 0.50;
            text = "Option 3";
        };
        class POLL_Option4: RscPollOption {
            idc = POLL_OPTION_4;
            x = 0.05;
            y = 0.65;
            text = "Option 4";
        };

        class POLL_EditQuestion: RscPollEdit {
            idc = POLL_OPTION_EDIT_QUESTION;
            x = 0.05;
            y = 0.02;
            text = "Question";
        };
        class POLL_EditOption1: RscPollEdit {
            idc = POLL_OPTION_EDIT_1;
            x = 0.05;
            y = 0.20;
            text = "Option 1";
        };
        class POLL_EditOption2: RscPollEdit {
            idc = POLL_OPTION_EDIT_2;
            x = 0.05;
            y = 0.35;
            text = "Option 2";
        };
        class POLL_EditOption3: RscPollEdit {
            idc = POLL_OPTION_EDIT_3;
            x = 0.05;
            y = 0.50;
            text = "Option 3";
        };
        class POLL_EditOption4: RscPollEdit {
            idc = POLL_OPTION_EDIT_4;
            x = 0.05;
            y = 0.65;
            text = "Option 4";
        };
        class POLL_EditOptionSubmit: RscButton {
            idc = POLL_OPTION_EDIT_SUBMIT;
            x = 0.3;
            y = 0.80;
            w = 0.4;
            h = 0.08;
            sizeEx = 0.05;
            text = "Create Poll";
        };
    };
};