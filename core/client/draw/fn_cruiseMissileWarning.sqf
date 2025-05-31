private _instructionDisplay = uiNamespace getVariable ["RscWLCruiseMissileDisplay", displayNull];
if (isNull _instructionDisplay) then {
    "cruiseMissileWarning" cutRsc ["RscWLCruiseMissileDisplay", "PLAIN", -1, true, true];
    _instructionDisplay = uiNamespace getVariable ["RscWLCruiseMissileDisplay", displayNull];
};
private _enemyText = _instructionDisplay displayCtrl 31001;
private _instructionText = _instructionDisplay displayCtrl 31002;

_enemyText ctrlShow true;
_instructionText ctrlShow false;

playSound "air_raid";

sleep 10;

"cruiseMissileWarning" cutText ["", "PLAIN"];