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