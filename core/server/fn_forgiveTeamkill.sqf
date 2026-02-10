#include "includes.inc"
params ["_teamkiller", "_forgiver", "_forgive", "_victim"];

if !(isServer) exitWith {};
if ((owner _forgiver) != remoteExecutedOwner) exitWith {};

if (!_forgive) then {
	private _teamkillerOwner = owner _teamkiller;
	if (_teamkillerOwner < 3) exitwith {};

	private _teamkillerUid = getPlayerUID _teamkiller;
	private _itemCost = WL_UNIT(_victim, "cost", 100);

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
	[_displayMsgTeamkiller] remoteExec ["WL2_fnc_smoothText", _teamkillerOwner];
	[["a3\dubbing_f_bootcamp\boot_m04\50_friendly\boot_m04_50_friendly_ada_0.ogg"]] remoteExec ["playSoundUI", _teamkillerOwner];

	private _displayMsgForgiver = format ["You have been compensated for teamkill. [+%1]", round (_compensation * 0.5)];
	[_displayMsgForgiver] remoteExec ["WL2_fnc_smoothText", _forgiver];

	private _friendlyFireMap = serverNamespace getVariable ["WL2_friendlyFireMap", createHashMap];
	private _friendlyFireIncidents = _friendlyFireMap getOrDefault [_teamkillerUid, []];
	_friendlyFireIncidents pushBack serverTime;

	// keep only last 20 minutes
	_friendlyFireIncidents = _friendlyFireIncidents select { _x >= (serverTime - WL_DURATION_FFTIMEOUT) };

	private _totalIncidents = count _friendlyFireIncidents;
	if (_totalIncidents >= 3) then {
		private _punishIncident = [serverTime + WL_DURATION_FFTIMEOUT, "teamkilling"];
		private _punishmentMap = missionNamespace getVariable ["WL2_punishmentMap", createHashMap];
		_punishmentMap set [_teamkillerUid, _punishIncident];
		missionNamespace setVariable ["WL2_punishmentMap", _punishmentMap, true];

		private _punishedPlayer = _teamkillerUid call BIS_fnc_getUnitByUID;
		[_punishIncident] remoteExec ["WL2_fnc_punishmentClient", _punishedPlayer];

		_friendlyFireIncidents = [];
	};

	_friendlyFireMap set [_teamkillerUid, _friendlyFireIncidents];
	serverNamespace setVariable ["WL2_friendlyFireMap", _friendlyFireMap];
};