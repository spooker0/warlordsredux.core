#include "includes.inc"
#include "controls.hpp"

class REP_ReportMenu {
    idd = REP_REPORT_IDD;
    movingEnable = false;
    class controlsBackground {
        class Background: REP_Background {
            x = safeZoneX + safeZoneW * 0.09;
            y = safeZoneY + safeZoneH * 0.09;
            w = safeZoneW * 0.82;
            h = safeZoneH * 0.746;
        };
        class PlayersPanel: REP_Panel {
            x = safeZoneX + safeZoneW * 0.098;
            y = safeZoneY + safeZoneH * 0.15;
            w = safeZoneW * 0.257;
            h = safeZoneH * 0.677;
        };
    };
    class controls {
        class Title: REP_Header {
            text = "$STR_WL_reportTitle";
            x = safeZoneX + safeZoneW * 0.09;
            y = safeZoneY + safeZoneH * 0.09;
            w = safeZoneW * 0.82;
            h = REP_LAYOUT_HEADER_H;
        };
        class Close: REP_CloseButton {
            idc = REP_CLOSE_IDC;
            x = safeZoneX + safeZoneW * 0.91 - REP_LAYOUT_HEADER_H * 3 / 4;
            y = safeZoneY + safeZoneH * 0.09;
        };
        class Search: REP_Edit {
            idc = REP_SEARCH_IDC;
            x = safeZoneX + safeZoneW * 0.106;
            y = safeZoneY + safeZoneH * 0.159;
            w = safeZoneW * 0.241;
            h = REP_LAYOUT_BUTTON_H;
            tooltip = "$STR_WL_reportSearch";
        };
        class Players: REP_ControlsGroup {
            idc = REP_PLAYERS_IDC;
            x = safeZoneX + safeZoneW * 0.106;
            y = safeZoneY + safeZoneH * 0.205;
            w = safeZoneW * 0.241;
            h = safeZoneH * 0.614;
            class controls {};
        };
        class Details: RscControlsGroupNoScrollbars {
            idc = REP_DETAILS_IDC;
            x = safeZoneX + safeZoneW * 0.364;
            y = safeZoneY + safeZoneH * 0.15;
            w = safeZoneW * 0.538;
            h = safeZoneH * 0.37;
            class controls {
                class Panel: REP_Panel {
                    x = 0;
                    y = 0;
                    w = safeZoneW * 0.538;
                    h = safeZoneH * 0.37;
                };
                class PlayerName: REP_Text {
                    idc = REP_PLAYER_NAME_IDC;
                    x = safeZoneW * 0.008;
                    y = safeZoneH * 0.008;
                    w = safeZoneW * 0.522;
                    h = safeZoneH * 0.036;
                    sizeEx = safeZoneH * 0.026;
                };
                class Info: REP_Monospace {
                    idc = REP_INFO_IDC;
                    x = safeZoneW * 0.008;
                    y = safeZoneH * 0.05;
                    w = safeZoneW * 0.522;
                    h = safeZoneH * 0.105;
                };
                class CopyInfo: REP_CopyButton {
                    idc = REP_COPY_INFO_IDC;
                    x = safeZoneW * 0.008;
                    y = safeZoneH * 0.166;
                    w = safeZoneW * 0.168;
                };
                class ReasonLabel: REP_Label {
                    x = safeZoneW * 0.008;
                    y = safeZoneH * 0.216;
                    w = safeZoneW * 0.522;
                    h = safeZoneH * 0.03;
                    text = "$STR_WL_reportReason";
                };
                class Reason: REP_MultilineEdit {
                    idc = REP_REASON_IDC;
                    x = safeZoneW * 0.008;
                    y = safeZoneH * 0.25;
                    w = safeZoneW * 0.522;
                    h = safeZoneH * 0.05;
                    text = "$STR_WL_reportDefaultReason";
                    maxChars = 140;
                    tooltip = "$STR_WL_reportReasonHint";
                };
                class Submit: REP_PrimaryButton {
                    idc = REP_SUBMIT_IDC;
                    x = safeZoneW * 0.318;
                    y = safeZoneH * 0.32;
                    w = safeZoneW * 0.212;
                    text = "$STR_WL_reportSubmit";
                };
            };
        };
    };
};

class REP_ModMenu {
    idd = REP_MOD_IDD;
    movingEnable = false;
    class controlsBackground {
        class Background: REP_Background {
            x = safeZoneX + safeZoneW * 0.02;
            y = safeZoneY + safeZoneH * 0.04;
            w = safeZoneW * 0.96;
            h = safeZoneH * 0.92;
        };
        class PlayersPanel: REP_Panel {
            x = safeZoneX + safeZoneW * 0.03;
            y = safeZoneY + safeZoneH * 0.10;
            w = safeZoneW * 0.235;
            h = safeZoneH * 0.846;
        };
        class ChatPanel: PlayersPanel {
            x = safeZoneX + safeZoneW * 0.614;
            w = safeZoneW * 0.356;
        };
    };
    class controls {
        class Title: REP_Header {
            text = "Moderator";
            x = safeZoneX + safeZoneW * 0.02;
            y = safeZoneY + safeZoneH * 0.04;
            w = safeZoneW * 0.96;
            h = REP_LAYOUT_HEADER_H;
        };
        class Close: REP_CloseButton {
            idc = REP_CLOSE_IDC;
            x = safeZoneX + safeZoneW * 0.98 - REP_LAYOUT_HEADER_H * 3 / 4;
            y = safeZoneY + safeZoneH * 0.04;
        };
        class Search: REP_Edit {
            idc = REP_SEARCH_IDC;
            x = safeZoneX + safeZoneW * 0.038;
            y = safeZoneY + safeZoneH * 0.111;
            w = safeZoneW * 0.219;
            h = REP_LAYOUT_BUTTON_H;
            tooltip = "Search players by name, alias or Steam ID";
        };
        class Players: REP_ControlsGroup {
            idc = REP_PLAYERS_IDC;
            x = safeZoneX + safeZoneW * 0.038;
            y = safeZoneY + safeZoneH * 0.159;
            w = safeZoneW * 0.219;
            h = safeZoneH * 0.448;
            class controls {};
        };
        class TimeoutsLabel: REP_Label {
            x = safeZoneX + safeZoneW * 0.038;
            y = safeZoneY + safeZoneH * 0.62;
            w = safeZoneW * 0.219;
            h = safeZoneH * 0.03;
            text = "ACTIVE TIMEOUTS";
        };
        class Timeouts: REP_ListBox {
            idc = REP_TIMEOUTS_IDC;
            x = safeZoneX + safeZoneW * 0.038;
            y = safeZoneY + safeZoneH * 0.66;
            w = safeZoneW * 0.219;
            h = safeZoneH * 0.218;
            sizeEx = REP_LAYOUT_SMALL_TEXT_SIZE;
            tooltip = "Select a timeout to clear it. Hover a row to read its reason.";
        };
        class ClearTimeout: REP_Button {
            idc = REP_CLEAR_TIMEOUT_IDC;
            x = safeZoneX + safeZoneW * 0.038;
            y = safeZoneY + safeZoneH * 0.895;
            w = safeZoneW * 0.219;
            text = "CLEAR SELECTED TIMEOUT";
        };
        class Details: RscControlsGroupNoScrollbars {
            idc = REP_DETAILS_IDC;
            x = safeZoneX + safeZoneW * 0.277;
            y = safeZoneY + safeZoneH * 0.10;
            w = safeZoneW * 0.325;
            h = safeZoneH * 0.846;
            class controls {
                class Panel: REP_Panel {
                    x = 0;
                    y = 0;
                    w = safeZoneW * 0.325;
                    h = safeZoneH * 0.846;
                };
                class Content: REP_ControlsGroup {
                    x = safeZoneW * 0.008;
                    y = safeZoneH * 0.011;
                    w = safeZoneW * 0.31;
                    h = safeZoneH * 0.823;
                    class controls {
                        class PlayerName: REP_Text {
                            idc = REP_PLAYER_NAME_IDC;
                            x = 0;
                            y = 0;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.036;
                            sizeEx = safeZoneH * 0.026;
                        };
                        class Info: REP_Monospace {
                            idc = REP_INFO_IDC;
                            x = 0;
                            y = safeZoneH * 0.045;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.105;
                        };
                        class CopyInfo: REP_CopyButton {
                            idc = REP_COPY_INFO_IDC;
                            x = 0;
                            y = safeZoneH * 0.159;
                            w = safeZoneW * 0.299;
                        };
                        class ReasonLabel: REP_Label {
                            x = 0;
                            y = safeZoneH * 0.209;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.03;
                            text = "TIMEOUT REASON";
                        };
                        class Reason: REP_MultilineEdit {
                            idc = REP_REASON_IDC;
                            x = 0;
                            y = safeZoneH * 0.246;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.05;
                            text = REP_DEFAULT_REASON;
                            tooltip = "Reason shown to the timed out player. Add 'kick' or 'cheat' to kick the player from the server.";
                        };
                        class DurationLabel: REP_Label {
                            x = 0;
                            y = safeZoneH * 0.308;
                            w = safeZoneW * 0.195;
                            h = safeZoneH * 0.032;
                            text = "DURATION (MINUTES)";
                        };
                        class Duration: REP_Edit {
                            idc = REP_DURATION_IDC;
                            x = safeZoneW * 0.225;
                            y = safeZoneH * 0.308;
                            w = safeZoneW * 0.074;
                            h = safeZoneH * 0.032;
                            text = "15";
                            tooltip = "Timeout duration in minutes";
                        };
                        class Slider: REP_Slider {
                            idc = REP_SLIDER_IDC;
                            x = 0;
                            y = safeZoneH * 0.349;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.028;
                        };
                        class Submit: REP_PrimaryButton {
                            idc = REP_SUBMIT_IDC;
                            x = 0;
                            y = safeZoneH * 0.389;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.035;
                            text = "TIMEOUT PLAYER";
                            class TextPos: TextPos {
                                right = safeZoneW * 0.004;
                            };
                        };
                        class ActionsLabel: REP_Label {
                            x = 0;
                            y = safeZoneH * 0.476;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.028;
                            text = "PLAYER ACTIONS";
                        };
                        class Rebalance: REP_Button {
                            idc = REP_REBALANCE_IDC;
                            x = 0;
                            y = safeZoneH * 0.514;
                            w = safeZoneW * 0.145;
                            text = "REBALANCE";
                        };
                        class Goto: Rebalance {
                            idc = REP_GOTO_IDC;
                            x = safeZoneW * 0.154;
                            text = "GO TO PLAYER";
                        };
                        class Mute: Rebalance {
                            idc = REP_MUTE_IDC;
                            y = safeZoneH * 0.561;
                            text = "MUTE";
                        };
                        class Transfers: Goto {
                            idc = REP_TRANSFERS_IDC;
                            y = safeZoneH * 0.561;
                            text = "TRANSFER LOG";
                        };
                        class Afk: Rebalance {
                            idc = REP_AFK_IDC;
                            y = safeZoneH * 0.608;
                            text = "AFK LOG";
                        };
                        class Rewards: Goto {
                            idc = REP_REWARDS_IDC;
                            y = safeZoneH * 0.608;
                            text = "REWARDS";
                        };
                        class Scripts: Rebalance {
                            idc = REP_SCRIPTS_IDC;
                            y = safeZoneH * 0.655;
                            text = "ACTIVE SCRIPTS";
                        };
                        class Deputize: Goto {
                            idc = REP_DEPUTIZE_IDC;
                            y = safeZoneH * 0.655;
                            text = "DEPUTIZE";
                        };
                        class ReportsLabel: REP_Label {
                            x = 0;
                            y = safeZoneH * 0.705;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.028;
                            text = "PLAYER REPORTS";
                        };
                        class Reports: REP_ReadOnly {
                            idc = REP_REPORTS_IDC;
                            x = 0;
                            y = safeZoneH * 0.741;
                            w = safeZoneW * 0.299;
                            h = safeZoneH * 0.145;
                        };
                        class ClearReports: REP_Button {
                            idc = REP_CLEAR_REPORTS_IDC;
                            x = 0;
                            y = safeZoneH * 0.895;
                            w = safeZoneW * 0.299;
                            text = "CLEAR REPORTS AND LOGS";
                            tooltip = "Clear this player's reports, transfer log and AFK log";
                        };
                        class Log: RscControlsGroupNoScrollbars {
                            idc = REP_LOG_GROUP_IDC;
                            x = 0;
                            y = safeZoneH * 0.949;
                            w = safeZoneW * 0.299;
                            h = 0;
                            class controls {
                                class Title: REP_Label {
                                    idc = REP_LOG_TITLE_IDC;
                                    x = 0;
                                    y = 0;
                                    w = safeZoneW * 0.19;
                                    h = safeZoneH * 0.03;
                                };
                                class Copy: REP_CopyButton {
                                    idc = REP_COPY_LOG_IDC;
                                    x = safeZoneW * 0.199;
                                    y = 0;
                                    w = safeZoneW * 0.1;
                                    h = safeZoneH * 0.03;
                                };
                                class Text: REP_Monospace {
                                    idc = REP_LOG_IDC;
                                    x = 0;
                                    y = safeZoneH * 0.041;
                                    w = safeZoneW * 0.299;
                                    h = safeZoneH * 0.309;
                                };
                            };
                        };
                    };
                };
            };
        };
        class ChatLabel: REP_Label {
            x = safeZoneX + safeZoneW * 0.622;
            y = safeZoneY + safeZoneH * 0.111;
            w = safeZoneW * 0.34;
            h = safeZoneH * 0.03;
            text = "CHAT LOG";
        };
        class ChatChannel: REP_Combo {
            idc = REP_CHAT_CHANNEL_IDC;
            x = safeZoneX + safeZoneW * 0.622;
            y = safeZoneY + safeZoneH * 0.151;
            w = safeZoneW * 0.145;
            h = safeZoneH * 0.025;
            tooltip = "Filter chat by channel";
        };
        class ChatPlayer: REP_Combo {
            idc = REP_CHAT_PLAYER_IDC;
            x = safeZoneX + safeZoneW * 0.776;
            y = safeZoneY + safeZoneH * 0.151;
            w = safeZoneW * 0.186;
            h = safeZoneH * 0.025;
            tooltip = "Filter chat by player";
        };
        class ChatReset: REP_Button {
            idc = REP_CHAT_RESET_IDC;
            x = safeZoneX + safeZoneW * 0.622;
            y = safeZoneY + safeZoneH * 0.184;
            w = safeZoneW * 0.34;
            h = safeZoneH * 0.027;
            text = "RESET CHAT FILTERS";
            size = REP_LAYOUT_SMALL_TEXT_SIZE;
        };
        class Chat: REP_ListBox {
            idc = REP_CHAT_IDC;
            x = safeZoneX + safeZoneW * 0.622;
            y = safeZoneY + safeZoneH * 0.221;
            w = safeZoneW * 0.34;
            h = safeZoneH * 0.412;
            sizeEx = REP_LAYOUT_SMALL_TEXT_SIZE;
            style = LB_TEXTURES + LB_MULTI;
            tooltip = "Ctrl-click or Shift-click to select messages. Full text appears below.";
        };
        class ChatPreview: REP_ReadOnly {
            idc = REP_CHAT_PREVIEW_IDC;
            x = safeZoneX + safeZoneW * 0.622;
            y = safeZoneY + safeZoneH * 0.644;
            w = safeZoneW * 0.34;
            h = safeZoneH * 0.237;
            tooltip = "Full text of selected messages";
        };
        class CopyChat: REP_CopyButton {
            idc = REP_COPY_CHAT_IDC;
            x = safeZoneX + safeZoneW * 0.622;
            y = safeZoneY + safeZoneH * 0.895;
            w = safeZoneW * 0.219;
        };
        class Receipts: REP_CopyButton {
            idc = REP_RECEIPTS_IDC;
            x = safeZoneX + safeZoneW * 0.85;
            y = safeZoneY + safeZoneH * 0.895;
            w = safeZoneW * 0.112;
        };
    };
};
