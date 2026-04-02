#include "includes.inc"
private _rewardHistory = uiNamespace getVariable ["WL2_rewardHistory", createHashMap];
player setVariable ["WL2_rewardHistory", _rewardHistory, true];