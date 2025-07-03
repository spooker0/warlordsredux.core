params ["_texture"];

private _seadTargetList = call DIS_fnc_getSeadList;

private _targetsText = toJSON _seadTargetList;
_targetsText = _texture ctrlWebBrowserAction ["ToBase64", _targetsText];

private _script = format [
    "const targetsEl = document.getElementById('targets'); targetsEl.innerHTML = atob(""%1""); updateData();",
    _targetsText
];
_texture ctrlWebBrowserAction ["ExecJS", _script];