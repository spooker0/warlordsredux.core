#include "includes.inc"

class SQD_Menu_SubtleButton: RscButtonMenu {
    colorBackground[] = {SQD_RGBA_NONE};
    colorBackgroundFocused[] = {SQD_RGBA_NONE};
    colorBackground2[] = {SQD_RGBA_NONE};
    color[] = {SQD_RGBA_TEXT};
    colorFocused[] = {SQD_RGBA_TEXT};
    color2[] = {SQD_RGBA_TEXT};
    colorText[] = {SQD_RGBA_TEXT};
    colorDisabled[] = {SQD_RGBA_DISABLED};

    class Attributes {
        font = "RobotoCondensed";
        color = SQD_COLOR_TEXT;
        align = "left";
    };
};

class SQD_Menu_BarButton: RscButtonMenu {
    colorBackground[] = {SQD_RGBA_DARKER};
    colorBackgroundFocused[] = {SQD_RGBA_LIGHT};
    colorBackground2[] = {SQD_RGBA_LIGHT};
    color[] = {SQD_RGBA_TEXT};
    colorFocused[] = {SQD_RGBA_DARKER};
    color2[] = {SQD_RGBA_DARKER};
    colorText[] = {SQD_RGBA_TEXT};
    colorDisabled[] = {SQD_RGBA_DISABLED};

    class Attributes {
        font = "RobotoCondensed";
        color = SQD_COLOR_TEXT;
        align = "center";
    };
};

class SQD_Menu {
    idd = SQD_MENU_IDD;
    movingEnable = false;
    class controls {
        class SQD_DummyButton: WLDummyButton {
            idc = SQD_DUMMY_IDC;
        };
        class SQD_Menu_CreateSquad_Frame: RscText {
            idc = SQD_UNASSIGNED_TEXT_IDC;
            x = safeZoneX + 0.1;
            y = safeZoneY + 0.1;
            w = 0.6;
            h = 0.1;
            colorBackground[] = {SQD_RGBA_DARK};
            text = " UNASSIGNED PLAYERS: 0";
        };
        class SQD_Menu_CreateSquad_Button: SQD_Menu_BarButton {
            idc = SQD_CREATE_SQUAD_IDC;
            x = safeZoneX + 0.5;
            y = safeZoneY + 0.1;
            w = 0.2;
            h = 0.1;
            size = 0.1;
            text = "CREATE SQUAD";
        };
        class SQD_Menu_SquadList: RscControlsGroup {
            idc = SQD_SQUAD_LIST_IDC;
            x = safeZoneX + 0.1;
            y = safeZoneY + 0.22;
            w = 0.62;
            h = safeZoneH - 0.32;
            class controls {};
            class VScrollbar: ScrollBar {
                color[] = {SQD_RGBA_DARK};
                width = 0.02;
                autoScrollEnabled = 1;
            };
        };
        class SQD_Menu_Status: RscStructuredText {
            idc = SQD_STATUS_IDC;
            x = safeZoneX + 0.8;
            y = safeZoneY + 0.1;
            w = safeZoneW - 1.6;
            h = 0.1;
            colorBackground[] = {SQD_RGBA_BG};
            size = 0.1;
            text = "";
        };
        class SQD_Menu_StatusHelpButton: SQD_Menu_BarButton {
            idc = SQD_STATUS_HELP_IDC;
            x = safeZoneX + 0.8;
            y = safeZoneY + 0.1;
            w = 0.15;
            h = 0.1;
            colorBackground[] = {SQD_RGBA_BG};
            size = 0.1;
            text = "";
        };
        class SQD_Menu_VehicleListText: RscStructuredText {
            idc = SQD_VEHICLE_LIST_TEXT_IDC;
            x = safeZoneX + 0.8;
            y = safeZoneY + SQD_LAYOUT_SECTION_GAP_Y + 0.2;
            w = safeZoneW - 1.75;
            h = 0.1;
            size = 0.1;
            colorBackground[] = {SQD_RGBA_BG};
            text = "";
        };
        class SQD_Menu_VehicleListButton: SQD_Menu_BarButton {
            idc = SQD_VEHICLE_LIST_BUTTON_IDC;
            x = safeZoneX + safeZoneW - 0.95;
            y = safeZoneY + SQD_LAYOUT_SECTION_GAP_Y + 0.2;
            w = 0.15;
            h = 0.1;
            size = 0.1;
            colorBackground[] = {SQD_RGBA_BG};
            text = "";
        };
        class SQD_Menu_VehicleList: RscControlsGroup {
            idc = SQD_VEHICLE_LIST_IDC;
            x = safeZoneX + 0.8;
            y = safeZoneY + SQD_LAYOUT_SECTION_GAP_Y + 0.3;
            w = safeZoneW - 1.595;
            h = safeZoneH - SQD_LAYOUT_SECTION_GAP_Y - 0.4;
            class controls {};
            class VScrollbar: ScrollBar {
                color[] = {SQD_RGBA_DARK};
                width = 0.02;
                autoScrollEnabled = 1;
            };
        };
        class SQD_Menu_SpawnScreenBG: RscText {
            x = safeZoneX + safeZoneW - 0.7;
            y = safeZoneY + 0.1;
            w = 0.6;
            h = 0.6;
            colorBackground[] = {SQD_RGBA_BG};
            text = "FEED DISABLED";
            sizeEx = 0.15;
            style = ST_CENTER;
            shadow = 0;
        };
        class SQD_Menu_SpawnScreen: RscPicture {
            idc = SQD_SPAWN_SCREEN_IDC;
            x = safeZoneX + safeZoneW - 0.7;
            y = safeZoneY + 0.1;
            w = 0.6;
            h = 0.6;
            size = 0.1;
            text = "#(argb,512,512,1)r2t(spawnCam,1.333)";
        };
        class SQD_Menu_SpawnScreenButton: SQD_Menu_BarButton {
            idc = SQD_SPAWN_SCREEN_BUTTON_IDC;
            x = safeZoneX + safeZoneW - 0.7;
            y = safeZoneY + 0.055;
            w = 0.15;
            h = 0.045;
            size = 0.04;
            text = "DISABLE FEED";
        };
        class SQD_Menu_SpawnScreenTI: SQD_Menu_BarButton {
            idc = SQD_SPAWN_SCREEN_TI_BUTTON_IDC;
            x = safeZoneX + safeZoneW - 0.55;
            y = safeZoneY + 0.055;
            w = 0.15;
            h = 0.045;
            size = 0.04;
            text = "ENABLE TI";
        };
        class SQD_Menu_SpawnList: RscControlsGroup {
            idc = SQD_SPAWN_LIST_IDC;
            x = safeZoneX + safeZoneW - 0.7;
            y = safeZoneY + SQD_LAYOUT_SECTION_GAP_Y + 0.7;
            w = 0.61;
            h = safeZoneH - SQD_LAYOUT_SECTION_GAP_Y - 0.8;
            class controls {};
            class VScrollbar: ScrollBar {
                color[] = {SQD_RGBA_DARK};
                width = 0.02;
                autoScrollEnabled = 1;
            };
        };
    };
};

class SQD_Menu_SquadBar: RscControlsGroupNoScrollbars {
    class controls {
        class SquadBar_Background: RscText {
            x = 0;
            y = 0;
            w = 0.6;
            h = 0.1;
            colorBackground[] = {SQD_RGBA_DARK};
        };
        class SquadBar_Number: RscText {
            idc = SQD_NUMBER_IDC;
            x = 0;
            y = 0;
            w = 0.075;
            h = 0.1;
            colorBackground[] = {SQD_RGBA_DARKER};
            sizeEx = 0.05;
            style = ST_CENTER;
            text = "01";
        };
        class SquadBar_Name: SQD_Menu_SubtleButton {
            idc = SQD_NAME_IDC;
            x = 0.08;
            y = 0;
            w = 0.25;
            h = 0.1;
            size = 0.1;
            text = "SQUAD NAME";
        };
        class SquadBar_Name_Edit: RscEdit {
            idc = SQD_NAME_EDIT_IDC;
            x = 0.08;
            y = 0;
            w = 0.25;
            h = 0.1;
            size = 0.1;
            text = "SQUAD NAME";
        };
        class SquadBar_Count: RscText {
            idc = SQD_COUNT_IDC;
            x = 0.4;
            y = 0;
            w = 0.09;
            h = 0.1;
            sizeEx = 0.04;
            style = ST_RIGHT;
            text = "0/0";
        };
        class SquadBar_Join: SQD_Menu_BarButton {
            idc = SQD_JOIN_IDC;
            x = 0.5;
            y = 0;
            w = 0.1;
            h = 0.1;
            size = 0.1;
            text = "";
        };
        class SquadBar_Locked: RscText {
            idc = SQD_LOCKED_IDC;
            x = 0.5;
            y = 0;
            w = 0.1;
            h = 0.1;
            sizeEx = 0.04;
            style = ST_CENTER;
            text = "LOCKED";
        };
    };
};

class SQD_Menu_SquadBar_Player: RscControlsGroupNoScrollbars {
    class controls {
        class SquadBar_Player_Background: RscText {
            x = 0;
            y = 0;
            w = 0.2955;
            h = 0.077;
            colorBackground[] = {SQD_RGBA_BG};
        };
        class SquadBar_Player_Badge_Background: RscText {
            x = 0;
            y = 0;
            w = 0.057;
            h = 0.077;
            colorBackground[] = {SQD_RGBA_DARK};
        };
        class SquadBar_Player_Badge: RscPicture {
            idc = SQD_BADGE_ICON_IDC;
            x = 0.009;
            y = 0.012;
            w = 0.039;
            h = 0.052;
        };
        class SquadBar_Player_BadgeButton: SQD_Menu_SubtleButton {
            idc = SQD_BADGE_BUTTON_IDC;
            x = 0.009;
            y = 0.012;
            w = 0.039;
            h = 0.052;
            text = "";
        };
        class SquadBar_Player_SquadLeader: RscPicture {
            idc = SQD_SQUAD_LEADER_ICON_IDC;
            x = 0.067;
            y = 0.0225;
            w = 0.024;
            h = 0.032;
            text = "a3\ui_f\data\gui\cfg\ranks\sergeant_pr.paa";
            colorText[] = {SQD_RGBA_GOLD};
        };
        class SquadBar_Player_Name: SQD_Menu_SubtleButton {
            idc = SQD_PLAYER_NAME_IDC;
            x = 0.067;
            y = 0;
            w = 0.22;
            h = 0.077;
            size = 0.077;
            text = "PLAYER NAME";
        };
    };
};

class SQD_Menu_VehicleList_Vehicle: RscControlsGroupNoScrollbars {
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    class controls {
        class VehicleList_Vehicle_Background: RscText {
            x = 0;
            y = 0;
            w = safeZoneW - 1.6;
            h = 0.077;
            colorBackground[] = {SQD_RGBA_BG};
        };
        class VehicleList_Vehicle_Badge_Background: RscText {
            x = 0;
            y = 0;
            w = 0.057;
            h = 0.077;
            colorBackground[] = {SQD_RGBA_DARK};
        };
        class VehicleList_Vehicle_Badge: RscPictureKeepAspect {
            idc = SQD_VEHICLE_BADGE_ICON_IDC;
            x = 0.009;
            y = 0.012;
            w = 0.039;
            h = 0.052;
        };
        class VehicleList_Vehicle_Name: SQD_Menu_SubtleButton {
            idc = SQD_VEHICLE_NAME_IDC;
            x = 0.067;
            y = 0;
            w = safeZoneW - 1.687;
            h = 0.077;
            size = 0.077;
            text = "";
        };
    };
};

class SQD_Menu_SpawnBar: RscControlsGroupNoScrollbars {
    class controls {
        class SpawnBar_Background: RscText {
            x = 0;
            y = 0;
            w = 0.64;
            h = 0.1;
            colorBackground[] = {SQD_RGBA_DARK};
        };
        class SpawnBar_Action: RscText {
            idc = SQD_SPAWN_ACTION_IDC;
            x = 0;
            y = 0;
            w = 0.15;
            h = 0.1;
            colorBackground[] = {SQD_RGBA_DARKER};
            sizeEx = 0.05;
            style = ST_CENTER;
            text = "ATTACK";
        };
        class SpawnBar_Name: RscStructuredText {
            idc = SQD_SPAWN_NAME_IDC;
            x = 0.16;
            y = 0;
            w = 0.48;
            h = 0.1;
            size = 0.1;
            text = "SECTOR";
        };
    };
};

class SQD_Menu_SpawnBar_Location: RscControlsGroupNoScrollbars {
    class controls {
        class SpawnBar_Location_Background: RscText {
            idc = SQD_LOCATION_BG_IDC;
            x = 0;
            y = 0;
            w = 0.195;
            h = 0.26;
            colorBackground[] = {SQD_RGBA_BG};
        };
        class SpawnBar_Location_Header: RscText {
            idc = SQD_LOCATION_HEADER_IDC;
            x = 0;
            y = 0;
            w = 0.195;
            h = 0.05;
            colorBackground[] = {SQD_RGBA_DARK};
        };
        class SpawnBar_Location_Name: RscText {
            idc = SQD_LOCATION_NAME_IDC;
            x = 0;
            y = 0;
            w = 0.195;
            h = 0.05;
            colorText[] = {SQD_RGBA_TEXT};
            text = "HELI PAD";
            style = ST_CENTER;
            sizeEx = 0.03;
        };
        class SpawnBar_Location_Picture: RscPictureKeepAspect {
            idc = SQD_LOCATION_ICON_IDC;
            x = 0.0225;
            y = 0.05;
            w = 0.15;
            h = 0.2;
            text = "a3\ui_f\data\gui\cfg\ranks\sergeant_pr.paa";
        };
        class SpawnBar_Location_Button: SQD_Menu_SubtleButton {
            idc = SQD_LOCATION_BUTTON_IDC;
            x = 0;
            y = 0;
            w = 0.195;
            h = 0.26;
            text = "";
        };
    };
};

class SQD_DeathInfo {
    idd = SQD_DEATHINFO_IDD;
    movingEnable = false;
    class controls {
        class SQD_DeathInfo_Status: RscStructuredText {
            idc = SQD_DEATHINFO_STATUS_IDC;
            x = 0.2;
            y = 0.2;
            w = 0.6;
            h = 0.8;
            size = 0.08;
            text = "";

            class Attributes {
                font = "RobotoCondensed";
                color = SQD_COLOR_TEXT;
                align = "center";
            };
        };
        class SQD_DeathInfo_Tips: RscStructuredText {
            idc = SQD_DEATHINFO_TIPS_IDC;
            x = 0;
            y = 0;
            w = 1;
            h = 0.2;
            size = 0.08;
            text = "";

            class Attributes {
                font = "RobotoCondensed";
                color = SQD_COLOR_TEXT;
                align = "center";
            };
        };
    };
};

class SQD_Menu_ContextualButton: RscButtonMenu {
    x = 0;
    y = 0;
    w = 0.3;
    h = 0.05;

    colorBackground[] = {SQD_RGBA_DARKER};
    colorBackgroundFocused[] = {SQD_RGBA_LIGHT};
    colorBackground2[] = {SQD_RGBA_LIGHT};
    color[] = {SQD_RGBA_TEXT};
    colorFocused[] = {SQD_RGBA_TEXT};
    color2[] = {SQD_RGBA_TEXT};
    colorText[] = {SQD_RGBA_TEXT};
    colorDisabled[] = {SQD_RGBA_DISABLED};

    class Attributes {
        font = "RobotoCondensed";
        color = SQD_COLOR_TEXT;
    };
};

class SQD_Menu_Contextual: RscControlsGroupNoScrollbars {
    class controls {};
};