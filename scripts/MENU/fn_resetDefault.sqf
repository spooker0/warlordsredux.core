closeDialog 0;

private _result = ["RESET ALL", "Reset all settings to default?", "Yes", "Cancel"] call WL2_fnc_prompt;
if (!_result) exitWith {};

profileNamespace setVariable ["WL2_settings", createHashMap];
systemChat "All settings have been reset to default. Restart game to apply all changes.";
playSoundUI ["AddItemOK"];