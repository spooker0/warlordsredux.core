#include "constants.inc"

params [["_unit", player], ["_lastLoadout", BIS_WL_lastLoadout], ["_paidFor", false], ["_collaborator", false]];

private _side = BIS_WL_playerSide;

private _data = createHashMap;
{
    private _type = _x;
    private _customizationData = profileNamespace getVariable [format ["WLC_%1_%2", _type, _side], ""];
    _data set [_type, _customizationData];
} forEach ["Uniform", "Vest", "Helmet", "Primary", "Secondary", "Launcher"];

{
    private _type = _x;
    private _attachmentData = profileNamespace getVariable [format ["WLC_%1_%2_Attach", _type, _side], ""];
    private _ammoData = profileNamespace getVariable [format ["WLC_%1_%2_Ammo", _type, _side], ""];
    _data set [_type + "Attachment", _attachmentData];
    _data set [_type + "Ammo", _ammoData];
} forEach ["Primary", "Secondary", "Launcher"];

[_data, _side, _lastLoadout, _unit, _paidFor, _collaborator] call WLC_fnc_processSelection;