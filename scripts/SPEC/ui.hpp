#include "includes.inc"

class SPEC_TargetMenu_Category: RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = SPEC_TARGET_CATEGORY_W;
    h = SPEC_TARGET_CATEGORY_H;
    class controls {
        class Background: RscText {
            idc = SPEC_TARGET_CATEGORY_BACKGROUND_ID;
            x = 0;
            y = 0;
            w = SPEC_TARGET_CATEGORY_W;
            h = SPEC_TARGET_CATEGORY_H;
            colorBackground[] = {SPEC_TARGET_RGBA_HEADER};
        };
        class Text: RscText {
            idc = SPEC_TARGET_CATEGORY_TEXT_ID;
            text = "";
            x = SPEC_TARGET_CARD_TEXT_X;
            y = 0;
            w = SPEC_TARGET_CATEGORY_W - 2 * SPEC_TARGET_CARD_TEXT_X;
            h = SPEC_TARGET_CATEGORY_H;
            sizeEx = SPEC_TARGET_TEXT_SIZE;
        };
    };
};

class SPEC_TargetMenu_Card: RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = SPEC_TARGET_CARD_W;
    h = SPEC_TARGET_CARD_H;
    class controls {
        class Background: RscText {
            idc = SPEC_TARGET_CARD_BACKGROUND_ID;
            x = 0;
            y = 0;
            w = SPEC_TARGET_CARD_W;
            h = SPEC_TARGET_CARD_H;
            colorBackground[] = {SPEC_TARGET_RGBA_ROW};
        };
        class PrimaryText: RscText {
            idc = SPEC_TARGET_CARD_PRIMARY_TEXT_ID;
            text = "";
            x = SPEC_TARGET_CARD_TEXT_X;
            y = SPEC_TARGET_PRIMARY_Y;
            w = SPEC_TARGET_CARD_TEXT_W;
            h = SPEC_TARGET_PRIMARY_H;
            sizeEx = SPEC_TARGET_TEXT_SIZE;
        };
        class SecondaryText: RscText {
            idc = SPEC_TARGET_CARD_SECONDARY_TEXT_ID;
            text = "";
            x = SPEC_TARGET_CARD_TEXT_X;
            y = SPEC_TARGET_SECONDARY_Y;
            w = SPEC_TARGET_CARD_TEXT_W;
            h = SPEC_TARGET_SECONDARY_H;
            sizeEx = SPEC_TARGET_SECONDARY_TEXT_SIZE;
            colorText[] = {SPEC_TARGET_RGBA_MUTED_TEXT};
        };
        class SelectButton: RscButton {
            idc = SPEC_TARGET_CARD_BUTTON_ID;
            text = "";
            x = 0;
            y = 0;
            w = SPEC_TARGET_CARD_W;
            h = SPEC_TARGET_CARD_H;
            colorText[] = {0, 0, 0, 0};
            colorActive[] = {0, 0, 0, 0};
            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {SPEC_TARGET_RGBA_ROW_HOVER};
            colorFocused[] = {SPEC_TARGET_RGBA_ROW_HOVER};
            colorDisabled[] = {0, 0, 0, 0};
            shadow = 0;
            borderSize = 0;
        };
    };
};

class SPEC_TargetMenu {
    idd = SPEC_TARGET_MENU_IDD;
    class controlsBackground {
        class Background: RscText {
            idc = SPEC_TARGET_BACKGROUND_ID;
            x = SPEC_TARGET_MENU_X;
            y = SPEC_TARGET_MENU_Y;
            w = SPEC_TARGET_MENU_W;
            h = SPEC_TARGET_MENU_H;
            colorBackground[] = {SPEC_TARGET_RGBA_BACKGROUND};
        };
    };
    class controls {
        class Title: RscText {
            idc = SPEC_TARGET_TITLE_ID;
            text = "SPECTATOR MENU";
            moving = true;
            x = SPEC_TARGET_MENU_X;
            y = SPEC_TARGET_MENU_Y;
            w = SPEC_TARGET_MENU_W;
            h = SPEC_TARGET_HEADER_H;
            sizeEx = SPEC_TARGET_TITLE_TEXT_SIZE;
            colorBackground[] = {SPEC_TARGET_RGBA_HEADER};
        };
        class Close: RscButton {
            idc = SPEC_TARGET_CLOSE_ID;
            text = "A3\ui_f\data\map\groupicons\waypoint.paa";
            style = ST_CENTER + ST_PICTURE;
            x = SPEC_TARGET_MENU_X + SPEC_TARGET_MENU_W - SPEC_TARGET_HEADER_H * 3 / 4;
            y = SPEC_TARGET_MENU_Y;
            w = SPEC_TARGET_HEADER_H * 3 / 4;
            h = SPEC_TARGET_HEADER_H;
        };
        class Search: RscEdit {
            idc = SPEC_TARGET_SEARCH_ID;
            text = "";
            tooltip = "Search owner, vehicle, or munition type";
            x = SPEC_TARGET_INNER_X;
            y = SPEC_TARGET_SEARCH_Y;
            w = SPEC_TARGET_INNER_W;
            h = SPEC_TARGET_SEARCH_H;
            sizeEx = SPEC_TARGET_TEXT_SIZE;
            colorBackground[] = {SPEC_TARGET_RGBA_ROW};
        };
        class Content: RscControlsGroupNoScrollbars {
            idc = SPEC_TARGET_CONTENT_GROUP_ID;
            x = SPEC_TARGET_CONTENT_X;
            y = SPEC_TARGET_CONTENT_Y;
            w = SPEC_TARGET_CONTENT_W;
            h = SPEC_TARGET_CONTENT_H;
            class controls {};
        };
        class EmptyText: RscText {
            idc = SPEC_TARGET_EMPTY_TEXT_ID;
            text = "No targets.";
            x = SPEC_TARGET_CONTENT_X;
            y = SPEC_TARGET_CONTENT_Y + SPEC_TARGET_CONTENT_H * 0.4;
            w = SPEC_TARGET_CONTENT_W;
            h = safeZoneH * 0.05;
            style = ST_CENTER;
            sizeEx = SPEC_TARGET_TEXT_SIZE;
            colorText[] = {SPEC_TARGET_RGBA_MUTED_TEXT};
        };
    };
};