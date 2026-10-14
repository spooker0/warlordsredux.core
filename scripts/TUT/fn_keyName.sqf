params ["_action", ["_fallback", localize "STR_WL_tutorialUnbound"]];

private _name = ((actionKeysNames [_action, 1, "Combo"]) splitString (toString [34])) joinString "";
if (_name == "") then {
    _name = _fallback;
};
_name;
