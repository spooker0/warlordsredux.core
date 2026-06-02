class WL2_DebriefingWestBase {
	picture = "b_installation";
	pictureBackground = "\A3\Map_Altis\data\ui_Altis_ca.paa";
	pictureColor[] = {0, 0.3, 0.6, 1};
};
class WL2_DebriefingEastBase {
	picture = "o_installation";
	pictureBackground = "\A3\Map_Altis\data\ui_Altis_ca.paa";
	pictureColor[] = {0.5, 0, 0, 1};
};

class CfgDebriefing {
	class WL2_Victory_WEST_Surrender: WL2_DebriefingWestBase {
		title = "Victory - Surrender";
		subtitle = "The enemy team has surrendered.";
	};

	class WL2_Victory_WEST_Normal: WL2_DebriefingWestBase {
		title = "Victory";
		subtitle = "Your team has taken the enemy base.";
	};

	class WL2_Defeat_WEST_Surrender : WL2_DebriefingWestBase {
		title = "Defeat - Surrender";
		subtitle = "Your team has surrendered.";
	};

	class WL2_Defeat_WEST_Normal : WL2_DebriefingWestBase {
		title = "Defeat";
		subtitle = "The enemy team has taken your base.";
	};

	class WL2_Victory_EAST_Surrender : WL2_DebriefingEastBase {
		title = "Victory - Surrender";
		subtitle = "The enemy team has surrendered.";
	};

	class WL2_Victory_EAST_Normal : WL2_DebriefingEastBase {
		title = "Victory";
		subtitle = "Your team has taken the enemy base.";
	};

	class WL2_Defeat_EAST_Surrender : WL2_DebriefingEastBase {
		title = "Defeat - Surrender";
		subtitle = "Your team has surrendered.";
	};

	class WL2_Defeat_EAST_Normal : WL2_DebriefingEastBase {
		title = "Defeat";
		subtitle = "The enemy team has taken your base.";
	};

	class WL2_End_Timeout : WL2_DebriefingEastBase {
		picture = "n_installation";
		pictureBackground = "\A3\Map_Altis\data\ui_Altis_ca.paa";
		pictureColor[] = {0, 0.5, 0, 1};
		title = "Mission Ended";
		subtitle = "Time has expired.";
	};

	class BlockScreen {};
};

class CfgDebriefingSections {
	class CfgWLRoundStats {
		title = "Round Stats";
		variable = "WL_endScreen";
	};
	class CfgWLTotalStats {
		title = "Total Stats";
		variable = "WL_endScreen2";
	};
};

class CfgCommunicationMenu {
	class WLMenu_Attack {
		text = "$STR_WL_commAttack";
		expression = "['Attack'] call WL2_fnc_commMenu";
		enable = "1";
	};

	class WLMenu_FollowMe {
		text = "$STR_WL_commFollowMe";
		expression = "['FollowMe'] call WL2_fnc_commMenu";
		enable = "1";
	};

	class WLMenu_CoverMe {
		text = "$STR_WL_commCoverMe";
		expression = "['CoverMe'] call WL2_fnc_commMenu";
		enable = "1";
	};

	class WLMenu_GetAway {
		text = "$STR_WL_commGetAway";
		expression = "['GetAway'] call WL2_fnc_commMenu";
		enable = "1";
	};

	class WLMenu_Stop {
		text = "$STR_WL_commStop";
		expression = "['Stop'] call WL2_fnc_commMenu";
		enable = "1";
	};

	class WLMenu_WaitForMe {
		text = "$STR_WL_commWaitForMe";
		expression = "['WaitForMe'] call WL2_fnc_commMenu";
		enable = "1";
	};

	class WLMenu_StatusBingo {
		text = "$STR_WL_commStatusBingo";
		expression = "['StatusBingo'] call WL2_fnc_commMenu";
		enable = "1";
	};

	class WLMenu_StatusDamaged {
		text = "$STR_WL_commStatusDamaged";
		expression = "['StatusDamaged'] call WL2_fnc_commMenu";
		enable = "1";
	};

	class WLMenu_ProvideSupply {
		text = "$STR_WL_commProvideSupply";
		expression = "['ProvideSupply'] call WL2_fnc_commMenu";
		enable = "1";
	};
};