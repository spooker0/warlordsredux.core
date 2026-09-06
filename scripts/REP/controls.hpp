class REP_Text: RscText {
    idc = -1;
    font = "RobotoCondensed";
    sizeEx = REP_LAYOUT_TEXT_SIZE;
    shadow = 0;
    colorText[] = {REP_RGBA_TEXT};
    colorBackground[] = {REP_RGBA_NONE};
};

class REP_Background: REP_Text {
    colorBackground[] = {REP_RGBA_DARKER};
};

class REP_Panel: REP_Text {
    colorBackground[] = {REP_RGBA_BG};
};

class REP_Header: REP_Text {
    sizeEx = REP_LAYOUT_TEXT_SIZE;
    colorBackground[] = {REP_RGBA_HEADER};
};

class REP_CloseButton: RscButton {
    text = "A3\ui_f\data\map\groupicons\waypoint.paa";
    style = ST_CENTER + ST_PICTURE;
    w = REP_LAYOUT_HEADER_H * 3 / 4;
    h = REP_LAYOUT_HEADER_H;
};

class REP_Label: REP_Text {
    sizeEx = REP_LAYOUT_SMALL_TEXT_SIZE;
    colorText[] = {REP_RGBA_MUTED};
};

class REP_Button: RscButtonMenu {
    idc = -1;
    h = REP_LAYOUT_BUTTON_H;
    size = REP_LAYOUT_TEXT_SIZE;
    font = "RobotoCondensed";
    shadow = 0;
    colorBackground[] = {REP_RGBA_DARK};
    colorBackgroundFocused[] = {REP_RGBA_LIGHT};
    colorBackground2[] = {REP_RGBA_LIGHT};
    color[] = {REP_RGBA_TEXT};
    colorFocused[] = {REP_RGBA_TEXT};
    color2[] = {REP_RGBA_TEXT};
    colorText[] = {REP_RGBA_TEXT};
    colorDisabled[] = {REP_RGBA_DISABLED};
    animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)";
    animTextureDisabled = "#(argb,8,8,3)color(1,1,1,1)";
    animTextureOver = "#(argb,8,8,3)color(1,1,1,1)";
    animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)";
    animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
    animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)";

    class Attributes {
        font = "RobotoCondensed";
        color = REP_COLOR_TEXT;
        align = "center";
        shadow = "false";
    };
    class TextPos {
        left = safeZoneW * 0.004;
        top = safeZoneH * 0.005;
        right = 0;
        bottom = 0;
    };
};

class REP_PrimaryButton: REP_Button {
    colorBackground[] = {REP_RGBA_GOLD};
    colorBackgroundFocused[] = {1, 0.85, 0.2, 1};
    colorBackground2[] = {1, 0.85, 0.2, 1};
    color[] = {REP_RGBA_DARKER};
    colorFocused[] = {REP_RGBA_DARKER};
    color2[] = {REP_RGBA_DARKER};
    colorText[] = {REP_RGBA_DARKER};

    class Attributes: Attributes {
        color = "#080809";
        align = "left";
    };
};

class REP_PlayerButton: REP_Button {
    h = REP_LAYOUT_PLAYER_H;
    class Attributes: Attributes {
        align = "left";
    };
    class TextPos: TextPos {
        right = safeZoneW * 0.004;
    };
};

class REP_AliasText: REP_Text {
    style = ST_MULTI;
    sizeEx = safeZoneH * 0.017;
    colorText[] = {REP_RGBA_MUTED};
    colorDisabled[] = {REP_RGBA_MUTED};
    colorBackground[] = {REP_RGBA_NONE};
};

class REP_CopyButton: RscText {
    type = 106;
    h = REP_LAYOUT_BUTTON_H;
};

class REP_Edit: RscEdit {
    idc = -1;
    font = "RobotoCondensed";
    sizeEx = REP_LAYOUT_TEXT_SIZE;
    style = ST_LEFT + ST_NO_RECT;
    shadow = 0;
    autocomplete = "";
    colorText[] = {REP_RGBA_TEXT};
    colorBackground[] = {REP_RGBA_DARK};
    colorDisabled[] = {REP_RGBA_DISABLED};
    colorSelection[] = {0.94, 0.75, 0.02, 0.4};
};

class REP_MultilineEdit: REP_Edit {
    style = ST_MULTI + ST_NO_RECT;
};

class REP_ReadOnly: REP_MultilineEdit {
    canModify = 0;
    sizeEx = REP_LAYOUT_SMALL_TEXT_SIZE;
};

class REP_Monospace: REP_ReadOnly {
    font = "EtelkaMonospacePro";
};

class REP_ListBox: RscListBox {
    idc = -1;
    font = "RobotoCondensed";
    sizeEx = REP_LAYOUT_TEXT_SIZE;
    rowHeight = safeZoneH * 0.032;
    shadow = 0;
    style = LB_TEXTURES;
    colorText[] = {REP_RGBA_TEXT};
    colorBackground[] = {REP_RGBA_DARK};
    colorSelect[] = {REP_RGBA_GOLD};
    colorSelect2[] = {REP_RGBA_GOLD};
    colorSelectBackground[] = {REP_RGBA_LIGHT};
    colorSelectBackground2[] = {REP_RGBA_LIGHT};
    colorDisabled[] = {REP_RGBA_DISABLED};
    period = 0;

    class ListScrollBar: ScrollBar {
        color[] = {REP_RGBA_LIGHT};
        colorActive[] = {REP_RGBA_GOLD};
        colorDisabled[] = {REP_RGBA_DISABLED};
        autoScrollEnabled = 0;
    };
};

class REP_Combo: RscCombo {
    idc = -1;
    font = "RobotoCondensed";
    sizeEx = REP_LAYOUT_SMALL_TEXT_SIZE;
    shadow = 0;
    colorText[] = {REP_RGBA_TEXT};
    colorBackground[] = {REP_RGBA_DARK};
    colorSelect[] = {REP_RGBA_GOLD};
    colorSelect2[] = {REP_RGBA_GOLD};
    colorSelectBackground[] = {REP_RGBA_LIGHT};
    colorSelectBackground2[] = {REP_RGBA_LIGHT};
    colorDisabled[] = {REP_RGBA_DISABLED};
    wholeHeight = safeZoneH * 0.35;

    class ComboScrollBar: ScrollBar {
        color[] = {REP_RGBA_LIGHT};
        colorActive[] = {REP_RGBA_GOLD};
        colorDisabled[] = {REP_RGBA_DISABLED};
    };
};

class REP_Slider: RscXSliderH {
    color[] = {REP_RGBA_LIGHT};
    colorActive[] = {REP_RGBA_GOLD};
    colorDisabled[] = {REP_RGBA_DISABLED};
};

class REP_ControlsGroup: RscControlsGroup {
    idc = -1;
    class VScrollbar: ScrollBar {
        color[] = {REP_RGBA_LIGHT};
        colorActive[] = {REP_RGBA_GOLD};
        width = safeZoneW * 0.006;
        autoScrollEnabled = 0;
    };
    class HScrollbar: ScrollBar {
        height = 0;
    };
};
