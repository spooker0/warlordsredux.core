waituntil {!isnull (findDisplay 46)};

_blockW = safeZoneW / 1000;
_blockH = safeZoneH / (1000 / (getResolution # 4));

_displayW = _blockW * 180;
_displayH = _blockH * 54;
_displayX = safeZoneW + safeZoneX - _displayW - (_blockW * 10);
_displayY = safeZoneH + safeZoneY - _displayH - (_blockH * 50);

_cpBalanceCtrl = findDisplay 46 ctrlCreate ["RscStructuredText", 9876];
_cpBalanceCtrl ctrlSetPosition [_displayX + (_blockW * 88), _displayY - (_blockH * 6), _blockW * 60, _blockH * 16];

_side = [west, east] find BIS_WL_playerSide;
_var = ["blanceMultilplierBlu", "blanceMultilplierOpf"] select _side;

while {!BIS_WL_missionEnd} do {
	_balanceMultiplier = (missionNamespace getVariable _var) - 1;
	_sidePercentage = if (isNil "_balanceMultiplier") then [{0}, {_balanceMultiplier * 100}];
	_sidePercentageFinal = if (BIS_WL_playerSide == independent) then {
		0;
	} else {
		(round _sidePercentage) min 100;
	};
	_cpBalanceCtrl ctrlSetStructuredText parseText format ["<t size = '%4' >%1%2%3</t>", (if (_sidePercentageFinal >0) then [{"+"},{""}]), _sidePercentageFinal, "%", (0.65 call WL2_fnc_purchaseMenuGetUIScale)];
	_cpBalanceCtrl ctrlSetTextColor (if(_sidePercentageFinal > 0) then {[0,1,0,1]} else {if (_sidePercentageFinal < 0) then [{[1,0,0,1]}, {[1,1,1,1]}]});
	_cpBalanceCtrl ctrlCommit 0;
	sleep 5;
};