#include "includes.inc"
params ["_button", "_color"];

private _backgroundId = switch (ctrlIDC _button) do {
    case BUY_REQUEST_IDC: { BUY_REQUEST_BACKGROUND_IDC };

    case BUY_TRANSFER_OK_IDC: { BUY_TRANSFER_OK_BACKGROUND_IDC };

    case BUY_TRANSFER_CANCEL_IDC: { BUY_TRANSFER_CANCEL_BACKGROUND_IDC };

    default { -1 };
};

if (_backgroundId < 0) exitWith {};

private _background = (ctrlParent _button) displayCtrl _backgroundId;
_background ctrlEnable false;
_background ctrlSetBackgroundColor _color;
