#include "includes.inc"
params ["_originalText", "_size", "_color", "_align"];
parseText format ["<t size='1'> <t align='%1' valign='middle' size='%2' color='%3'>%4</t> </t>", _align, _size, _color, _originalText];