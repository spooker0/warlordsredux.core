#include "includes.inc"

class BUY_Text: RscStructuredText {
    size = BUY_GRID_H * 0.85;
    colorText[] = {BUY_RGBA_TEXT};
    shadow = 0;

    class Attributes {
        font = "RobotoCondensed";
        color = "#ffffff";
        align = "left";
        shadow = 0;
    };
};

class BUY_List: RscListBox {
    sizeEx = BUY_GRID_H * 0.9;
    rowHeight = BUY_GRID_H * 1.5;
    colorBackground[] = {BUY_RGBA_DARK};
    font = "RobotoCondensed";
    shadow = 0;
};

class BUY_Button: RscButtonMenu {
    shortcuts[] = {};
    size = BUY_GRID_H * 0.85;
    shadow = 0;

    class TextPos {
        left = BUY_GRID_W * 0.25;
        top = 0;
        right = 0;
        bottom = 0;
        forceMiddle = true;
    };
    // The panel beneath each action owns its dynamic availability color.
    colorBackground[] = {0, 0, 0, 0};
    colorBackgroundFocused[] = {0, 0, 0, 0};
    colorBackground2[] = {0, 0, 0, 0};
    color[] = {BUY_RGBA_TEXT};
    colorFocused[] = {BUY_RGBA_TEXT};
    color2[] = {BUY_RGBA_TEXT};
    colorText[] = {BUY_RGBA_TEXT};

    class Attributes {
        font = "RobotoCondensed";
        color = "#ffffff";
        align = "center";
        shadow = 0;
    };
};

class BUY_Menu {
    idd = BUY_MENU_IDD;
    movingEnable = false;
    class controls {
        class Dummy: WLDummyButton {
            idc = BUY_DUMMY_IDC;
            default = 1;
            shortcuts[] = {};
        };
        class Background: RscText {
            idc = -1;
            x = BUY_POS_X(0);
            y = BUY_POS_Y(0);
            w = BUY_PANEL_W * BUY_GRID_W;
            h = BUY_PANEL_H * BUY_GRID_H;
            colorBackground[] = {BUY_RGBA_BG};
        };
        class Search: RscEdit {
            idc = BUY_SEARCH_IDC;
            text = "Search...";
            tooltip = "$STR_WL_buySearchHint";
            x = BUY_POS_X(0.5);
            y = BUY_POS_Y(0.5);
            w = 28.5 * BUY_GRID_W;
            h = 1.5 * BUY_GRID_H;
            sizeEx = BUY_GRID_H * 0.9;
            colorBackground[] = {BUY_RGBA_DARK};
        };
        class Categories: BUY_List {
            idc = BUY_CATEGORY_IDC;
            x = BUY_POS_X(0.5);
            y = BUY_POS_Y(2.5);
            w = 11 * BUY_GRID_W;
            h = 28.5 * BUY_GRID_H;
        };
        class Items: BUY_List {
            idc = BUY_ITEMS_IDC;
            x = BUY_POS_X(12);
            y = BUY_POS_Y(2.5);
            w = 17 * BUY_GRID_W;
            h = 28.5 * BUY_GRID_H;
        };
        class Picture: RscPictureKeepAspect {
            idc = BUY_PICTURE_IDC;
            x = BUY_POS_X(29.5);
            y = BUY_POS_Y(2.5);
            w = 20 * BUY_GRID_W;
            h = 10 * BUY_GRID_H;
        };
        class Details: RscControlsGroup {
            idc = BUY_DETAILS_GROUP_IDC;
            x = BUY_POS_X(29.5);
            y = BUY_POS_Y(13);
            w = 20 * BUY_GRID_W;
            h = 18 * BUY_GRID_H;
            class controls {
                class Text: BUY_Text {
                    idc = BUY_DETAILS_IDC;
                    x = 0;
                    y = 0;
                    w = 20 * BUY_GRID_W;
                    h = 18 * BUY_GRID_H;
                };
            };
        };
        class RequestBackground: RscText {
            idc = BUY_REQUEST_BACKGROUND_IDC;
            x = BUY_POS_X(0.5);
            y = BUY_POS_Y(31.5);
            w = 49 * BUY_GRID_W;
            h = 2 * BUY_GRID_H;

            colorBackground[] = {BUY_RGBA_DARK};
        };
        class Request: BUY_Button {
            idc = BUY_REQUEST_IDC;
            x = BUY_POS_X(0.5);
            y = BUY_POS_Y(31.5);
            w = 49 * BUY_GRID_W;
            h = 2 * BUY_GRID_H;
        };
        class Close: RscButton {
            idc = -1;
            text = "A3\ui_f\data\map\groupicons\waypoint.paa";
            style = ST_CENTER + ST_PICTURE;
            x = BUY_POS_X(BUY_PANEL_W - 2);
            y = BUY_POS_Y(0);
            w = 2 * BUY_GRID_W;
            h = 2 * BUY_GRID_H;
            onButtonClick = "(ctrlParent (_this # 0)) closeDisplay 1";
        };
        class TransferBackground: RscText {
            idc = BUY_TRANSFER_BACKGROUND_IDC;
            x = BUY_POS_X(9);
            y = BUY_POS_Y(9);
            w = 32 * BUY_GRID_W;
            h = 16 * BUY_GRID_H;
            colorBackground[] = {BUY_RGBA_DARK};
        };
        class TransferUnits: BUY_List {
            idc = BUY_TRANSFER_UNITS_IDC;
            x = BUY_POS_X(9.5);
            y = BUY_POS_Y(9.5);
            w = 15 * BUY_GRID_W;
            h = 15 * BUY_GRID_H;
        };
        class TransferAmount: RscEdit {
            idc = BUY_TRANSFER_AMOUNT_IDC;
            x = BUY_POS_X(25);
            y = BUY_POS_Y(13);
            w = 15.5 * BUY_GRID_W;
            h = 2 * BUY_GRID_H;
            sizeEx = BUY_GRID_H * 0.9;
        };
        class TransferSlider: RscXSliderH {
            idc = BUY_TRANSFER_SLIDER_IDC;
            x = BUY_POS_X(25);
            y = BUY_POS_Y(15.5);
            w = 15.5 * BUY_GRID_W;
            h = 1 * BUY_GRID_H;
        };
        class TransferOKBackground: RscText {
            idc = BUY_TRANSFER_OK_BACKGROUND_IDC;
            x = BUY_POS_X(25);
            y = BUY_POS_Y(19);
            w = 15.5 * BUY_GRID_W;
            h = 2 * BUY_GRID_H;
            colorBackground[] = {BUY_RGBA_DARK};
        };
        class TransferOK: BUY_Button {
            idc = BUY_TRANSFER_OK_IDC;
            x = BUY_POS_X(25);
            y = BUY_POS_Y(19);
            w = 15.5 * BUY_GRID_W;
            h = 2 * BUY_GRID_H;
            text = "$STR_A3_WL_button_transfer";
        };
        class TransferCancelBackground: RscText {
            idc = BUY_TRANSFER_CANCEL_BACKGROUND_IDC;
            x = BUY_POS_X(25);
            y = BUY_POS_Y(22);
            w = 15.5 * BUY_GRID_W;
            h = 2 * BUY_GRID_H;
            colorBackground[] = {BUY_RGBA_DARK};
        };
        class TransferCancel: BUY_Button {
            idc = BUY_TRANSFER_CANCEL_IDC;
            x = BUY_POS_X(25);
            y = BUY_POS_Y(22);
            w = 15.5 * BUY_GRID_W;
            h = 2 * BUY_GRID_H;
            text = "$STR_disp_cancel";
        };
    };
};
