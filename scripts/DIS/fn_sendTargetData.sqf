#include "includes.inc"
params ["_texture", "_targetList"];

private _targetsText = toJSON _targetList;
_targetsText = _texture ctrlWebBrowserAction ["ToBase64", _targetsText];

private _script = format [
    "const targetsEl = document.getElementById('targets'); targetsEl.innerHTML = atob(""%1""); updateData();",
    _targetsText
];
_texture ctrlWebBrowserAction ["ExecJS", _script];