params ["_asset"];

private _targetIcon = getText (configFile >> "CfgVehicles" >> typeOf _asset >> "picture");
if (_targetIcon in [
    "",
    "picturething", "pictureThing",
    "picturelogic", "pictureLogic",
    "picturelasertarget", "pictureLaserTarget"
]) then {
    _targetIcon = "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\Air_ca.paa";
};
_targetIcon;