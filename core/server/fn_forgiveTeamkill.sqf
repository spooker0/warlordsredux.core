params ["_teamkiller", "_forgiver", "_forgive", "_victim"];

if !(isServer) exitWith {};
if ((owner _forgiver) != remoteExecutedOwner) exitWith {};

if (!_forgive) then {
	private _teamkillerOwner = owner _teamkiller;
	if (_teamkillerOwner < 3) exitwith {};
	_timestamps = _teamkiller getVariable ["BIS_WL_friendlyKillTimestamps", []];
	_timestamps pushBack serverTime;
	_teamkiller setVariable ["BIS_WL_friendlyKillTimestamps", _timestamps, [2, _teamkillerOwner]];

	private _victimActualType = _victim getVariable ["WL2_orderedClass", typeof _victim];
	private _costDB = serverNamespace getVariable ["WL2_costs", createHashMap];
	private _itemCost = _costDB getOrDefault [_victimActualType, 100];

	private _fundsDB = serverNamespace getVariable "fundsDatabase";
	private _teamkillerFunds = _fundsDB getOrDefault [getPlayerUID _teamkiller, 0];

	private _compensation = round (_itemCost min _teamkillerFunds);
	private _uid = getPlayerUID _teamkiller;
	(-_compensation) call WL2_fnc_fundsDatabaseWrite;
	_uid = getPlayerUID _forgiver;
	(round (_compensation * 0.5)) call WL2_fnc_fundsDatabaseWrite;

	private _assetType = [_victim] call WL2_fnc_getAssetTypeName;
	private _displayMsgTeamkiller = format ["You have been punished for killing friendly %1. [-%2]", _assetType, _compensation];
	[_displayMsgTeamkiller] remoteExec ["systemChat", _teamkillerOwner];
	[["a3\dubbing_f_bootcamp\boot_m04\50_friendly\boot_m04_50_friendly_ada_0.ogg"]] remoteExec ["playSoundUI", _teamkillerOwner];

	private _displayMsgForgiver = format ["You have been compensated for teamkill. [+%1]", round (_compensation * 0.5)];
	[_displayMsgForgiver] remoteExec ["systemChat", _forgiver];

	if ((count (_teamKiller getVariable ["BIS_WL_friendlyKillTimestamps", []])) >= 3) then {
		_teamKiller setDamage 1;
		_varName = format ["BIS_WL_%1_friendlyKillPenaltyEnd", getPlayerUID _teamKiller];
		serverNamespace setVariable [_varName, serverTime + 1800];
		[(serverNamespace getVariable _varName)] remoteExec ["WL2_fnc_friendlyFireHandleClient", _teamkillerOwner];
	};
};