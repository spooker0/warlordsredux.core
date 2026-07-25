#include "includes.inc"
/*
________________	Author : GEORGE FLOROS [GR]	___________	29.03.19
________________	GF Earplugs Script - Mod	________________
https://forums.bohemia.net/forums/topic/215844-gf-earplugs-script-mod/
*/

private _creditsRecord = player createDiaryRecord ["Warlords Redux", "", taskNull, "", false];
player setDiaryRecordText [["Warlords Redux", _creditsRecord], ["Credits", "
    <font size='20'>Credits</font><br/>
    <font size='18' color='#ff0000'>External Assets</font><br/>
    GF Earplugs: George Floros's earplug script.<br/>
    A3 Aegis Mod: Texture for the Blufor Kuma (heavily compressed).<br/>
    <br/>
    <font size='18' color='#ff0000'>Developers</font><br/>
    Special Thanks to: Dwarden (Bohemia Interactive)<br/>
    GamerDad<br/>
    Witch Doctor<br/>
    JWalker08<br/>
    Weasley Wells<br/>
    Rook<br/>
    MONGCHAW<br/>
    MrThomasM<br/>
    TenPenny<br/>
    Coffee Maker<br/>
    Korbelz<br/>
    Bo<br/>
    "
]];