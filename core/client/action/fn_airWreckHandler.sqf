#include "includes.inc"
params ["_asset"];
removeFromRemainsCollector [_asset];

while { alive _asset } do {
    uiSleep 1;
};

_asset setVariable ["WL2_timeOfDeath", serverTime, true];