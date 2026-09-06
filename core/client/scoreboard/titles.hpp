class RscWLScoreboardMenu {
    idd = -1;
    duration = 1000000000;
    fadein = 0;
    fadeout = 0;
    name = "RscWLScoreboardMenu";
    onLoad = "uiNamespace setVariable ['RscWLScoreboardMenu', _this select 0];";
    class controls {
        class RscWLScoreboardMenu_Background: RscText {
            idc = -1;
            x = safeZoneX;
            y = safeZoneY;
            w = safeZoneW;
            h = safeZoneH;
            colorBackground[] = {0, 0, 0, 0.25};
        };
        class RscWLScoreboardMenu_Body: RscWLScoreboardGroup {
            idc = WL_SCOREBOARD_BODY_ID;
            x = WL_SCOREBOARD_X;
            y = WL_SCOREBOARD_BODY_Y;
            w = WL_SCOREBOARD_W;
            h = WL_SCOREBOARD_BODY_H;
            class controls {
                class Content: RscWLScoreboardGroup {
                    idc = WL_SCOREBOARD_CONTENT_ID;
                    w = WL_SCOREBOARD_W;
                    h = WL_SCOREBOARD_BODY_H;
                };
            };
        };
    };
};
