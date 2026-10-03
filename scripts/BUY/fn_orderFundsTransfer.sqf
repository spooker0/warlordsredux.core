#include "includes.inc"

disableSerialization;

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (isNull _display) exitWith {};

private _existingHandle = _display getVariable ["BUY_transferHandle", scriptNull];
if (!scriptDone _existingHandle) then {
    terminate _existingHandle;
};

#ifdef WL_BUY_TRANSFER_TEST
private _noRecipients = count (allPlayers select { isPlayer _x && side group _x == BIS_WL_playerSide && _x != player }) == 0;
_display setVariable ["BUY_mockTransfers", _noRecipients];

if (_noRecipients) then {
    _display setVariable ["BUY_mockTransferFunds", 100000];
    _display setVariable ["BUY_mockTransferRoster", [
        ["Mock Alpha", "BUY_MOCK_ALPHA", 25000],
        ["Mock Bravo", "BUY_MOCK_BRAVO", 5000],
        ["Mock Charlie", "BUY_MOCK_CHARLIE", 75000]
    ]];
};

#endif
true call WL2_fnc_purchaseMenuSetTransferMode;
private _amountControl = _display displayCtrl BUY_TRANSFER_AMOUNT_IDC;
private _sliderControl = _display displayCtrl BUY_TRANSFER_SLIDER_IDC;
private _playerFunds = (missionNamespace getVariable ["fundsDatabaseClients", createHashMap]) getOrDefault [getPlayerUID player, 0];
#ifdef WL_BUY_TRANSFER_TEST
private _storedMockTransfers = _display getVariable ["BUY_mockTransfers", false];
if (_storedMockTransfers) then {
    _playerFunds = _display getVariable ["BUY_mockTransferFunds", 100000];
};

#endif
private _maxTransfer = (_playerFunds - WL_COST_FUNDTRANSFER) max 0;
_amountControl ctrlSetText str floor _maxTransfer;
_sliderControl sliderSetRange [0, _maxTransfer];
_sliderControl sliderSetPosition _maxTransfer;
_sliderControl sliderSetSpeed [1000, 1000, 1000];
lbClear (_display displayCtrl BUY_TRANSFER_UNITS_IDC);
ctrlSetFocus _amountControl;

private _refreshHandle = [_display, _maxTransfer] spawn WL2_fnc_purchaseMenuRefreshTransfer;
_display setVariable ["BUY_transferHandle", _refreshHandle];
