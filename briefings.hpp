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