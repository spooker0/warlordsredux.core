#include "includes.inc"
params ["_display"];

private _squadNameEdit = _display getVariable ["SQD_squadNameEdit", controlNull];
if (!isNull _squadNameEdit) exitWith {};

private _vehicleListTextControl = _display displayCtrl SQD_VEHICLE_LIST_TEXT_IDC;
private _vehicleListTextStructured = [
    "ASSET LIST",
    SQD_LAYOUT_LABEL_TEXT_SIZE,
    SQD_COLOR_TEXT,
    "left"
] call SQD_fnc_renderText;
_vehicleListTextControl ctrlSetStructuredText _vehicleListTextStructured;

private _vehicleListButton = _display displayCtrl SQD_VEHICLE_LIST_BUTTON_IDC;
private _vehicleListButtonTextStructured = [
    "BUY ASSETS",
    SQD_LAYOUT_LABEL_TEXT_SIZE * 0.75,
    SQD_COLOR_TEXT,
    "center"
] call SQD_fnc_renderText;
_vehicleListButton ctrlSetStructuredText _vehicleListButtonTextStructured;
_vehicleListButton ctrlRemoveAllEventHandlers "ButtonClick";
_vehicleListButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control", "_event", "_x", "_y", "_shift", "_ctrl", "_alt"];

    if (WL_ISDOWN(player)) exitWith {
        playSoundUI ["AddItemFailed"];
    };

    private _display = ctrlParent _control;
    _display closeDisplay 0;
    "RequestMenu_open" call WL2_fnc_setupUI;
}];

private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _playerVehicles = missionNamespace getVariable [_ownedVehicleVar, []];

_playerVehicles = _playerVehicles select { alive _x } select { _x != player };

private _vehicles = [_playerVehicles, [], { _x distance cameraOn }, "ASCEND"] call BIS_fnc_sortBy;

private _vehiclesForMenu = _vehicles apply {
    private _vehicle = _x;
    private _type = typeOf _vehicle;

    private _displayName = if (_type isKindOf "Man") then {
        format ["AI: %1", name _vehicle]
    } else {
        [_vehicle] call WL2_fnc_getAssetTypeShortName
    };

    private _key = netId _vehicle;
    if (_key == "") then {
        _key = str _vehicle;
    };

    [_displayName, _key, _vehicle, _type]
};

private _vehicleListGroup = _display displayCtrl SQD_VEHICLE_LIST_IDC;

private _gridBackgroundColor = [SQD_RGBA_DARKER];

private _vehicleGridBorder = SQD_LAYOUT_GRID_BORDER;

private _vehicleOuterX = 0;
private _vehicleOuterY = 0;
private _vehicleOuterW = safeZoneW - 1.6;

private _vehicleInnerX = _vehicleGridBorder;
private _vehicleInnerY = _vehicleGridBorder;
private _vehicleInnerW = _vehicleOuterW - (2 * _vehicleGridBorder);
private _vehicleInnerH = 0.077;

private _vehicleStepY = _vehicleInnerH + _vehicleGridBorder;
private _vehicleGridH = _vehicleGridBorder + ((count _vehiclesForMenu) * _vehicleStepY);

private _vehiclePool = _display getVariable ["SQD_vehiclePool", createHashMap];
_display setVariable ["SQD_vehiclePool", _vehiclePool];

private _vehicleGridBackground = _vehiclePool getOrDefault ["background", controlNull];
private _vehicleTiles = _vehiclePool getOrDefault ["tiles", []];

if (isNull _vehicleGridBackground) then {
    _vehicleGridBackground = _display ctrlCreate [
        "RscText",
        -1,
        _vehicleListGroup
    ];

    _vehicleGridBackground ctrlSetBackgroundColor _gridBackgroundColor;
    _vehicleGridBackground ctrlCommit 0;

    _vehiclePool set ["background", _vehicleGridBackground];
};

if (count _vehiclesForMenu > 0) then {
    _vehicleGridBackground ctrlSetPosition [
        _vehicleOuterX,
        _vehicleOuterY,
        _vehicleOuterW,
        _vehicleGridH
    ];

    _vehicleGridBackground ctrlSetBackgroundColor _gridBackgroundColor;
    _vehicleGridBackground ctrlShow true;
    _vehicleGridBackground ctrlCommit 0;
} else {
    _vehicleGridBackground ctrlShow false;
    _vehicleGridBackground ctrlCommit 0;
};

{
    _x params ["_displayName", "_key", "_vehicle", "_type"];

    private _vehicleCtrl = controlNull;

    if (_forEachIndex < count _vehicleTiles) then {
        _vehicleCtrl = _vehicleTiles # _forEachIndex;
    };

    if (isNull _vehicleCtrl) then {
        _vehicleCtrl = _display ctrlCreate [
            "SQD_Menu_VehicleList_Vehicle",
            -1,
            _vehicleListGroup
        ];

        _vehicleTiles pushBack _vehicleCtrl;
    };

    _vehicleCtrl ctrlSetPosition [
        _vehicleInnerX,
        _vehicleInnerY + (_forEachIndex * _vehicleStepY),
        _vehicleInnerW,
        _vehicleInnerH
    ];

    _vehicleCtrl ctrlShow true;

    private _vehicleIcon = getText (configFile >> "CfgVehicles" >> _type >> "picture");
    if (_vehicleIcon in ["pictureThing", "pictureStaticObject"]) then {
        _vehicleIcon = "a3\ui_f\data\map\vehicleicons\iconcratesupp_ca.paa";
    };
    if (_type isKindOf "Man") then {
        _vehicleIcon = "a3\ui_f\data\gui\rsc\rscdisplaymain\profile_player_ca.paa";
    };

    private _vehicleBadgeIcon = _vehicleCtrl controlsGroupCtrl SQD_VEHICLE_BADGE_ICON_IDC;
    _vehicleBadgeIcon ctrlSetText _vehicleIcon;

    private _vehicleNameButton = _vehicleCtrl controlsGroupCtrl SQD_VEHICLE_NAME_IDC;

    private _vehicleDistance = _vehicle distance cameraOn;
    private _distanceText = if (_vehicleDistance > 1000) then {
        format ["%1 KM", (_vehicleDistance / 1000) toFixed 1]
    } else {
        format ["%1 M", _vehicleDistance toFixed 0]
    };

    private _vehicleAps = _vehicle getVariable ["apsAmmo", 0];
    private _vehicleMaxAps = [_vehicle] call APS_fnc_getMaxAmmo;
    private _apsText = if (_vehicleMaxAps > 0) then {
        format [" (APS: %1/%2)", _vehicleAps, _vehicleMaxAps]
    } else {
        ""
    };
    private _vehicleNameText = [
        format ["%1%2<t align='right'>%3</t>", toUpper _displayName, _apsText, _distanceText],
        SQD_LAYOUT_LABEL_TEXT_SIZE,
        SQD_COLOR_TEXT,
        "left"
    ] call SQD_fnc_renderText;

    _vehicleNameButton ctrlSetStructuredText _vehicleNameText;
    _vehicleNameButton setVariable ["SQD_vehicle", _vehicle];

    private _previousKey = _vehicleCtrl getVariable ["SQD_vehicleKey", ""];

    if !(_previousKey isEqualTo _key) then {
        _vehicleNameButton ctrlRemoveAllEventHandlers "ButtonClick";
        _vehicleNameButton ctrlAddEventHandler ["ButtonClick", SQD_fnc_contextVehicle];

        _vehicleCtrl setVariable ["SQD_vehicleKey", _key];
    };

    _vehicleCtrl ctrlCommit 0;
} forEach _vehiclesForMenu;

for "_i" from count _vehiclesForMenu to ((count _vehicleTiles) - 1) do {
    private _staleCtrl = _vehicleTiles # _i;

    if (!isNull _staleCtrl) then {
        private _vehicleNameButton = _staleCtrl controlsGroupCtrl SQD_VEHICLE_NAME_IDC;

        _vehicleNameButton setVariable ["SQD_vehicle", objNull];

        _staleCtrl setVariable ["SQD_vehicleKey", ""];
        _staleCtrl ctrlShow false;
        _staleCtrl ctrlSetPosition [0, 0, 0, 0];
        _staleCtrl ctrlCommit 0;
    };
};

_vehiclePool set ["background", _vehicleGridBackground];
_vehiclePool set ["tiles", _vehicleTiles];

_display setVariable ["SQD_vehiclePool", _vehiclePool];