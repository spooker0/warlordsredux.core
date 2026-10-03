// Screen-height grid. Horizontal coordinates compensate for Arma's 4:3 GUI units.
// pixelW / pixelH keeps physical spacing square on every aspect ratio.
#define BUY_GRID_H (safeZoneH / 40)
#define BUY_GRID_W (BUY_GRID_H * pixelW / pixelH)
#define BUY_PANEL_W 50
#define BUY_PANEL_H 34
#define BUY_X (safeZoneX + (safeZoneW - BUY_PANEL_W * BUY_GRID_W) / 2)
#define BUY_Y (safeZoneY + (safeZoneH - BUY_PANEL_H * BUY_GRID_H) / 2)
#define BUY_POS_X(N) (BUY_X + (N) * BUY_GRID_W)
#define BUY_POS_Y(N) (BUY_Y + (N) * BUY_GRID_H)
#define BUY_RGBA_BG 0.09, 0.09, 0.095, 1
#define BUY_RGBA_DARK 0.06, 0.06, 0.065, 1
#define BUY_RGBA_TEXT 1, 1, 1, 1
#define BUY_MENU_IDD 11000
#define BUY_CATEGORY_IDC 100
#define BUY_ITEMS_IDC 101
#define BUY_PICTURE_IDC 102
#define BUY_DETAILS_IDC 105
#define BUY_DETAILS_GROUP_IDC 106
#define BUY_REQUEST_IDC 107
#define BUY_TRANSFER_IDCS [115, 116, 117, 118, 119, 120, 122, 123]
#define BUY_REFRESH_INTERVAL 0.5
#define BUY_TRANSFER_BACKGROUND_IDC 115
#define BUY_TRANSFER_UNITS_IDC 116
#define BUY_TRANSFER_AMOUNT_IDC 117
#define BUY_TRANSFER_SLIDER_IDC 118
#define BUY_TRANSFER_OK_IDC 119
#define BUY_TRANSFER_CANCEL_IDC 120
#define BUY_REQUEST_BACKGROUND_IDC 121
#define BUY_TRANSFER_OK_BACKGROUND_IDC 122
#define BUY_TRANSFER_CANCEL_BACKGROUND_IDC 123

#define BUY_SEARCH_IDC 124
#define BUY_DUMMY_IDC 125
