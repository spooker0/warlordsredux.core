#include "includes.inc"
params ["_display", "_maxTransfer"];
disableSerialization;

private _recipientControl = _display displayCtrl BUY_TRANSFER_UNITS_IDC;
private _amountControl = _display displayCtrl BUY_TRANSFER_AMOUNT_IDC;
private _transferButton = _display displayCtrl BUY_TRANSFER_OK_IDC;
private _lastRoster = [];
private _lastState = [];
private _nextRosterRefresh = 0;
while { !isNull _display && ctrlEnabled _transferButton } do {
    private _fundsDatabase = missionNamespace getVariable ["fundsDatabaseClients", createHashMap];
    if (diag_tickTime >= _nextRosterRefresh) then {
        _nextRosterRefresh = diag_tickTime + 1;
        private _roster = (allPlayers select { isPlayer _x && side group _x == BIS_WL_playerSide && _x != player }) apply {
            [name _x, getPlayerUID _x, _fundsDatabase getOrDefault [getPlayerUID _x, 0]]
        };

#ifdef WL_BUY_TRANSFER_TEST
        private _storedMockTransfers = _display getVariable ["BUY_mockTransfers", false];
        if (_storedMockTransfers) then {
            _roster = +(_display getVariable ["BUY_mockTransferRoster", []]);
        };

#endif
        _roster sort true;

        if (_roster isNotEqualTo _lastRoster) then {
            private _selectedUid = _recipientControl lbData lbCurSel _recipientControl;
            lbClear _recipientControl;
            private _selection = 0;
            {
                _x params ["_name", "_playerUid", "_funds"];
                private _row = _recipientControl lbAdd _name;
                _recipientControl lbSetData [_row, _playerUid];
                _recipientControl lbSetTooltip [_row, format ["~%1%2", WL_MONEY_SIGN, _funds]];

                if (_playerUid == _selectedUid) then {
                    _selection = _row;
                };

            } forEach _roster;
            _recipientControl lbSetCurSel _selection;
            _lastRoster = _roster;
        };
    };

    if (lbSize _recipientControl == 0) exitWith {
        false call WL2_fnc_purchaseMenuSetTransferMode;
        playSound "AddItemFailed";
    };

    private _enteredText = ctrlText _amountControl;
    private _amountText = toString ((toArray _enteredText) select { _x >= 48 && _x <= 57 });
    if (_enteredText != _amountText) then {
        _amountControl ctrlSetText _amountText;
    };

    private _transferAmount = parseNumber _amountText;
    private _availableFunds = ((_fundsDatabase getOrDefault [getPlayerUID player, 0]) - WL_COST_FUNDTRANSFER) max 0 min _maxTransfer;

#ifdef WL_BUY_TRANSFER_TEST
    private _storedMockTransfers = _display getVariable ["BUY_mockTransfers", false];
    if (_storedMockTransfers) then {
        _availableFunds = ((_display getVariable ["BUY_mockTransferFunds", 0]) - WL_COST_FUNDTRANSFER) max 0 min _maxTransfer;
    };
#endif

    private _transferPossible = _transferAmount > 0 && _transferAmount <= _availableFunds && lbCurSel _recipientControl >= 0;
    uiNamespace setVariable ["BIS_WL_fundsTransferPossible", _transferPossible];
    private _state = [_transferAmount, _transferPossible];
    if (_state isNotEqualTo _lastState) then {
        private _label = localize "STR_A3_WL_button_transfer";

#ifdef WL_BUY_TRANSFER_TEST
        private _storedMockTransfers = _display getVariable ["BUY_mockTransfers", false];
        if (_storedMockTransfers) then {
            _label = "TEST: " + _label;
        };

#endif

        if (_transferPossible) then {
            _label = format ["%1 (%2%3)", _label, WL_MONEY_SIGN, _transferAmount];
        };

        _transferButton ctrlSetStructuredText parseText format ["<t align='center' size='1.1'>%1</t>", _label];
        private _color = BIS_WL_colorFriendly;
        if (!_transferPossible) then {
            _color = [(_color # 0) * 0.5, (_color # 1) * 0.5, (_color # 2) * 0.5, _color # 3];
        };

        [_transferButton, _color] call WL2_fnc_purchaseMenuSetButtonColor;
        _transferButton ctrlSetTextColor ([ [0.5, 0.5, 0.5, 1], [1, 1, 1, 1] ] select _transferPossible);
        _transferButton ctrlSetTooltip ([localize "STR_A3_WL_low_funds", ""] select _transferPossible);
        _lastState = _state;
    };

    uiSleep 0.1;
};
