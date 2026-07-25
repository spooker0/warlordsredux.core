#include "includes.inc"

class WL2_BadgeMenu_Badge: RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = BADGE_CARD_W;
    h = BADGE_CARD_H;
    class controls {
        class Background: RscText {
            idc = BADGE_CARD_BACKGROUND_ID;
            x = 0;
            y = 0;
            w = BADGE_CARD_W;
            h = BADGE_CARD_H;
            colorBackground[] = {BADGE_RGBA_CARD_BG};
        };
        class SelectedIndicator: RscText {
            idc = BADGE_CARD_SELECTED_ID;
            x = 0;
            y = 0;
            w = BADGE_SELECTED_W;
            h = BADGE_CARD_H;
            colorBackground[] = {BADGE_RGBA_SELECTED};
        };
        class Icon: RscPictureKeepAspect {
            idc = BADGE_CARD_ICON_ID;
            text = "";
            x = BADGE_ICON_X;
            y = BADGE_ICON_Y;
            w = BADGE_ICON_SIZE;
            h = BADGE_ICON_SIZE;
        };
        class Name: RscText {
            idc = BADGE_CARD_NAME_ID;
            text = "";
            x = BADGE_TEXT_X;
            y = BADGE_NAME_Y;
            w = BADGE_TEXT_W;
            h = BADGE_NAME_H;
            sizeEx = BADGE_NAME_TEXT_SIZE;
        };
        class Description: RscStructuredText {
            idc = BADGE_CARD_DESCRIPTION_ID;
            text = "";
            x = BADGE_TEXT_X;
            y = BADGE_DESCRIPTION_Y;
            w = BADGE_TEXT_W;
            h = BADGE_DESCRIPTION_H;
            size = BADGE_DESCRIPTION_TEXT_SIZE;
            class Attributes {
                font = "RobotoCondensed";
                color = "#C7C7C7";
                align = "left";
                valign = "top";
                shadow = 0;
            };
        };
        class Count: RscText {
            idc = BADGE_CARD_COUNT_ID;
            text = "";
            x = BADGE_TEXT_X;
            y = BADGE_COUNT_Y;
            w = BADGE_TEXT_W;
            h = BADGE_COUNT_H;
            sizeEx = BADGE_COUNT_TEXT_SIZE;
            colorText[] = {MENU_RGBA_MUTED_TEXT};
        };
        class SelectButton: RscButton {
            idc = BADGE_CARD_BUTTON_ID;
            text = "";
            x = 0;
            y = 0;
            w = BADGE_CARD_W;
            h = BADGE_CARD_H;
            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {0, 0, 0, 0};
            colorFocused[] = {0, 0, 0, 0};
            colorDisabled[] = {0, 0, 0, 0};
            colorText[] = {0, 0, 0, 0};
            colorActive[] = {0, 0, 0, 0};
            shadow = 0;
            borderSize = 0;
        };
    };
};

class WL2_BadgeMenu {
    idd = BADGE_IDD;
    class controlsBackground {
        class Background: RscText {
            idc = BADGE_BACKGROUND_ID;
            x = BADGE_MENU_X;
            y = BADGE_MENU_Y;
            w = BADGE_MENU_W;
            h = BADGE_MENU_H;
            colorBackground[] = {MENU_RGBA_BG};
        };
    };
    class controls {
        class Title: RscText {
            idc = BADGE_TITLE_ID;
            text = "Badges";
            moving = true;
            x = BADGE_MENU_X;
            y = BADGE_MENU_Y;
            w = BADGE_MENU_W;
            h = BADGE_HEADER_H;
            sizeEx = SETTINGS_TITLE_SIZE;
            colorBackground[] = {MENU_RGBA_HEADER};
        };
        class Close: RscButton {
            idc = BADGE_CLOSE_ID;
            text = "A3\ui_f\data\map\groupicons\waypoint.paa";
            style = ST_CENTER + ST_PICTURE;
            x = BADGE_MENU_X + BADGE_MENU_W - BADGE_HEADER_H * 3 / 4;
            y = BADGE_MENU_Y;
            w = BADGE_HEADER_H * 3 / 4;
            h = BADGE_HEADER_H;
        };
        class Content: RscControlsGroupNoScrollbars {
            idc = BADGE_CONTENT_GROUP_ID;
            x = BADGE_CONTENT_X;
            y = BADGE_CONTENT_Y;
            w = BADGE_CONTENT_W;
            h = BADGE_CONTENT_H;
            class controls {};
        };
        class EmptyText: RscText {
            idc = BADGE_EMPTY_TEXT_ID;
            text = "No badges earned yet.";
            x = BADGE_CONTENT_X;
            y = BADGE_CONTENT_Y + BADGE_CONTENT_H * 0.4;
            w = BADGE_CONTENT_W;
            h = safeZoneH * 0.05;
            style = ST_CENTER;
            sizeEx = BADGE_TEXT_SIZE;
            colorText[] = {MENU_RGBA_MUTED_TEXT};
        };
    };
};