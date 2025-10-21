#include "includes.inc"
params ["_asset"];
systemChat "Enemy long-range air defenses detected.";

while { alive _asset } do {

    uiSleep 5;
};