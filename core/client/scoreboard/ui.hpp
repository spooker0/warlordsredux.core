#include "constants.inc"

class RscWLScoreboardGroup: RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = 0;
    h = 0;

    class VScrollbar: ScrollBar {
        width = 0;
        scrollSpeed = 0;
        autoScrollEnabled = 0;
        autoScrollSpeed = -1;
    };

    class HScrollbar: ScrollBar {
        height = 0;
    };

    class controls {};
};

class RscWLScoreboardCell: RscText {
    idc = -1;
    text = "";
    style = ST_RIGHT;
    font = "EtelkaMonospaceProBold";
    sizeEx = WL_SCOREBOARD_TEXT_SIZE;
    shadow = 2;
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0};
};

class RscWLScoreboardName: RscWLScoreboardCell {
    style = ST_LEFT;
};
