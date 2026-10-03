#include "includes.inc"

disableSerialization;

private _storedFundsTransferPossible = uiNamespace getVariable ["BIS_WL_fundsTransferPossible", false];
if (!_storedFundsTransferPossible) exitWith {};

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (isNull _display) exitWith {};

private _recipientName = (_display displayCtrl BUY_TRANSFER_UNITS_IDC) lbText lbCurSel (_display displayCtrl BUY_TRANSFER_UNITS_IDC);
private _transferAmount = floor parseNumber ctrlText (_display displayCtrl BUY_TRANSFER_AMOUNT_IDC);
private _targetUid = (_display displayCtrl BUY_TRANSFER_UNITS_IDC) lbData lbCurSel (_display displayCtrl BUY_TRANSFER_UNITS_IDC);
#ifdef WL_BUY_TRANSFER_TEST
private _storedMockTransfers = _display getVariable ["BUY_mockTransfers", false];
if (_storedMockTransfers) exitWith {
    private _senderFunds = _display getVariable ["BUY_mockTransferFunds", 0];
    private _roster = _display getVariable ["BUY_mockTransferRoster", []];
    private _recipientIndex = _roster findIf { (_x # 1) == _targetUid };

    if (_recipientIndex < 0 || _transferAmount <= 0 || _transferAmount + WL_COST_FUNDTRANSFER > _senderFunds) exitWith {
        playSound "AddItemFailed";
    };

    private _recipient = +(_roster # _recipientIndex);
    _recipient set [2, (_recipient # 2) + _transferAmount];
    _roster set [_recipientIndex, _recipient];
    _display setVariable ["BUY_mockTransferRoster", _roster];
    _display setVariable ["BUY_mockTransferFunds", _senderFunds - _transferAmount - WL_COST_FUNDTRANSFER];
    playSound "AddItemOK";
    [format ["TEST: Transferred %1%2 to %3. Remaining: %1%4", WL_MONEY_SIGN, _transferAmount, _recipientName, _senderFunds - _transferAmount - WL_COST_FUNDTRANSFER]] call WL2_fnc_smoothText;
};

#endif
private _recipients = allPlayers select {getPlayerUID _x == _targetUid && side group _x == BIS_WL_playerSide && _x != player};

private _senderFunds = (missionNamespace getVariable ["fundsDatabaseClients", createHashMap]) getOrDefault [getPlayerUID player, 0];
if (count _recipients > 0 && _transferAmount > 0 && _transferAmount + WL_COST_FUNDTRANSFER <= _senderFunds) then {
    playSound "AddItemOK";
    private _recipient = _recipients # 0;

    private _transfers = missionProfileNamespace getVariable ["WL2_playerTransfers", createHashMap];
    private _existingAmount = _transfers getOrDefault [_recipientName, 0];
    _transfers set [_recipientName, _existingAmount + _transferAmount];
    missionProfileNamespace setVariable ["WL2_playerTransfers", _transfers];

    [player, "fundsTransfer", _transferAmount, _recipient] remoteExec ["WL2_fnc_handleClientRequest", 2];

    false call WL2_fnc_purchaseMenuSetTransferMode;
} else {
    playSound "AddItemFailed";
};
