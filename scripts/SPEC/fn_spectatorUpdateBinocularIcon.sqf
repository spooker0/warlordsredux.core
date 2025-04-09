params ["_show"];

private _projectileDisplay = uiNamespace getVariable ["RscWLSpectatorProjectileDisplay", displayNull];
if (isNull _projectileDisplay) then {
    "WLSpectatorProjectile" cutRsc ["RscWLSpectatorProjectileDisplay", "PLAIN"];
    _projectileDisplay = uiNamespace getVariable ["RscWLSpectatorProjectileDisplay", displayNull];
};
private _binocularControl = _projectileDisplay displayCtrl 8600;
_binocularControl ctrlShow _show;