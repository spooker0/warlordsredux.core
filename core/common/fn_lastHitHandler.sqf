params ["_asset"];

_asset addEventHandler ["Hit", {
	params ["_unit", "_source", "_damage", "_instigator"];

	private _responsiblePlayer = [_source, _instigator] call WL2_fnc_handleInstigator;
	private _ownerSide = [_unit] call WL2_fnc_getAssetSide;
	private _responsibleSide = side group _responsiblePlayer;

	if (_ownerSide == _responsibleSide) exitWith {};
	if (!alive _unit || !isDamageAllowed _unit) exitWith {};
	if (isNull _responsiblePlayer) exitWith {};

	_unit setVariable ["WL_lastHitter", _responsiblePlayer, 2];

	private _children = _unit getVariable ["WL2_children", []];
	{
		_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
	} forEach _children;

	private _crew = crew _unit;
	if (count _crew == 0) exitWith {};
	if (count _crew == 1 && _crew # 0 == _unit) exitWith {};
	{
		_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
	} forEach _crew;
}];

if (isPlayer _asset) exitWith {};

_asset addEventHandler ["HandleDamage", {
	params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit", "_context"];
	if (_projectile == "FuelExplosion") then {
		private _unitApsType = _unit call APS_fnc_getMaxAmmo;
		private _sourceApsType = _source call APS_fnc_getMaxAmmo;
		if (_unitApsType > _sourceApsType) then {
			0;
		} else {
			_damage;
		};
	} else {
		_damage;
	};
}];