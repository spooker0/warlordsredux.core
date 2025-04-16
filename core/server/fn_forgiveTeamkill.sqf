params ["_teamkiller", "_forgiver", "_forgive", "_victim"];

if !(isServer) exitWith {};
if ((owner _forgiver) != remoteExecutedOwner) exitWith {};

if (!_forgive) then {
	private _teamkillerOwner = owner _teamkiller;
	if (_teamkillerOwner < 3) exitwith {};

	private _teamkillerUid = getPlayerUID _teamkiller;

	private _victimActualType = _victim getVariable ["WL2_orderedClass", typeof _victim];
	private _costDB = missionNamespace getVariable ["WL2_costs", createHashMap];
	private _itemCost = _costDB getOrDefault [_victimActualType, 100];

	private _fundsDB = serverNamespace getVariable "fundsDatabase";
	private _teamkillerFunds = _fundsDB getOrDefault [_teamkillerUid, 0];

	private _compensation = round (_itemCost min _teamkillerFunds);
	[-_compensation, _teamkillerUid] call WL2_fnc_fundsDatabaseWrite;
	[round (_compensation * 0.5), getPlayerUID _forgiver] call WL2_fnc_fundsDatabaseWrite;

	private _assetType = if (isPlayer [_victim]) then {
		name _victim
	} else {
		[_victim] call WL2_fnc_getAssetTypeName;
	};
	private _displayMsgTeamkiller = format ["You have been punished for killing friendly %1. [-%2]", _assetType, _compensation];
	[_displayMsgTeamkiller] remoteExec ["systemChat", _teamkillerOwner];
	[["a3\dubbing_f_bootcamp\boot_m04\50_friendly\boot_m04_50_friendly_ada_0.ogg"]] remoteExec ["playSoundUI", _teamkillerOwner];

	private _displayMsgForgiver = format ["You have been compensated for teamkill. [+%1]", round (_compensation * 0.5)];
	[_displayMsgForgiver] remoteExec ["systemChat", _forgiver];

	private _friendlyFireVar = format ["WL2_friendlyFire_%1", _teamkillerUid];
	private _friendlyFireIncidents = serverNamespace getVariable [_friendlyFireVar, []];
	_friendlyFireIncidents pushBack serverTime;
	serverNamespace setVariable [_friendlyFireVar, _friendlyFireIncidents];
	[_friendlyFireIncidents] remoteExec ["WL2_fnc_friendlyFireHandleClient", _teamkillerOwner];
};