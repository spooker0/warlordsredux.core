class CfgSounds {
    class altWarning {
        name="altitude warning";
        sound[]={"src\sounds\altSound.ogg", 1, 1};
        titles[] = {};
    };

    class pullUp {
        name="Pull up";
        sound[]={"src\sounds\pullUpSound.ogg", 1, 1};
        titles[] = {};
    };

    class bingoFuel {
        name="Fuel low";
        sound[]={"src\sounds\bingoSound.ogg", 1, 1};
        titles[] = {};
    };

    class radarLock {
        name="Visible on radar";
        sound[]={"src\sounds\onSensorSound.ogg", 1, 1};
        titles[] = {};
    };

    class radarTargetNew {
        name="New radar target";
        sound[]={"src\sounds\newTargetSound.ogg", 1, 1};
        titles[] = {};
    };

    class radarTargetLost {
        name="Lost radar target";
        sound[]={"src\sounds\lostTargetSound.ogg", 1, 1};
        titles[] = {};
    };

    class pullUpRita {
        name="Pull up rita";
        sound[]={"src\sounds\AngleOfAttackOverLimit.ogg", 1, 1};
        titles[] = {};
    };

    class altRita {
        name="Alt rita";
        sound[]={"src\sounds\PullUp.ogg", 1, 1};
        titles[] = {};
    };

    class sensorRita {
        name="sensorWarning rita";
        sound[]={"src\sounds\sensorWarning.ogg", 1, 1};
        titles[] = {};
    };

    class fuelRita {
        name="fuel low rita";
        sound[]={"src\sounds\BingoFuel.ogg", 1, 1};
        titles[] = {};
    };

    class incMissile_0 {
        name="incomming 0";
        sound[]={"src\sounds\critical_missile12.ogg", 1, 1};
        titles[] = {};
    };

    class incMissile_90 {
        name="incomming 90";
        sound[]={"src\sounds\critical_missile03.ogg", 1, 1};
        titles[] = {};
    };

    class incMissile_180 {
        name="incomming 180";
        sound[]={"src\sounds\critical_missile06.ogg", 1, 1};
        titles[] = {};
    };

    class incMissile_270 {
        name="incomming 270";
        sound[]={"src\sounds\critical_missile09.ogg", 1, 1};
        titles[] = {};
    };

    class incMissileRuss_0 {
        name="incomming 0";
        sound[]={"src\sounds\critical_missileRuss12.ogg", 1, 1};
        titles[] = {};
    };

    class incMissileRuss_90 {
        name="incomming 90";
        sound[]={"src\sounds\critical_missileRuss03.ogg", 1, 1};
        titles[] = {};
    };

    class incMissileRuss_180 {
        name="incomming 180";
        sound[]={"src\sounds\critical_missileRuss06.ogg", 1, 1};
        titles[] = {};
    };

    class incMissileRuss_270 {
        name="incomming 270";
        sound[]={"src\sounds\critical_missileRuss09.ogg", 1, 1};
        titles[] = {};
    };

    class hitmarker {
        name = "hitmarker";
        sound[] = {"src\sounds\hitmarker.ogg", 1, 1};
        titles[] = {};
    };

    class vlslaunch01 {
        name = "vlslaunch01";
        sound[] = {"src\sounds\vlslaunch_01.ogg", 1, 1};
        titles[] = {};
    };

    class vlslaunch02 {
        name = "vlslaunch02";
        sound[] = {"src\sounds\vlslaunch_02.ogg", 1, 1};
        titles[] = {};
    };

    class vlslaunch03 {
        name = "vlslaunch03";
        sound[] = {"src\sounds\vlslaunch_03.ogg", 1, 1};
        titles[] = {};
    };
};

class CfgSFX {
	class WLDemolition {
		sounds[] = { "sound0", "sound1", "sound2", "sound3", "sound4", "sound5", "sound6", "sound7" };
        sound0[] = { "@a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_01.wss", 5, 1.0, 200, 0.125, 0, 0.2, 0.4 };
        sound1[] = { "@a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_02.wss", 5, 1.0, 200, 0.125, 0, 0.2, 0.4 };
        sound2[] = { "@a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_03.wss", 5, 1.0, 200, 0.125, 0, 0.2, 0.4 };
        sound3[] = { "@a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_04.wss", 5, 1.0, 200, 0.125, 0, 0.2, 0.4 };
        sound4[] = { "@a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_01.wss", 5, 1.0, 200, 0.125, 0, 0.2, 0.4 };
        sound5[] = { "@a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_02.wss", 5, 1.0, 200, 0.125, 0, 0.2, 0.4 };
        sound6[] = { "@a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_03.wss", 5, 1.0, 200, 0.125, 0, 0.2, 0.4 };
        sound7[] = { "@a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_04.wss", 5, 1.0, 200, 0.125, 0, 0.2, 0.4 };

		empty[] = { "", 0, 0, 0, 0, 0, 0, 0 };
	};

    class WLAlarm {
		sounds[] = { "sound0" };
        sound0[] = { "@a3\sounds_f\sfx\alarmcar.wss", 3, 1.0, 200, 1, 0, 0, 0 };
		empty[] = { "", 0, 0, 0, 0, 0, 0, 0 };
	};

    class WLRopeTravel {
        sounds[] = { "sound0" };
        sound0[] = { "@a3\sounds_f\vehicles\air\noises\wind_open_int.wss", 1, 1.0, 100, 1, 0, 0, 0 };
		empty[] = { "", 0, 0, 0, 0, 0, 0, 0 };
    };

    class WLDowned {
        sounds[] = { "sound0", "sound1", "sound2", "sound3", "sound4", "sound5", "sound6", "sound7" };
        sound0[] = { "@a3\sounds_f\characters\human-sfx\person0\p0_moan_13_words.wss", 5, 1.0, 30, 0.125, 2, 3, 4 };
        sound1[] = { "@a3\sounds_f\characters\human-sfx\person0\p0_moan_14_words.wss", 5, 1.0, 30, 0.125, 2, 3, 4 };
        sound2[] = { "@a3\sounds_f\characters\human-sfx\person0\p0_moan_15_words.wss", 5, 1.0, 30, 0.125, 2, 3, 4 };
        sound3[] = { "@a3\sounds_f\characters\human-sfx\person0\p0_moan_16_words.wss", 5, 1.0, 30, 0.125, 2, 3, 4 };
        sound4[] = { "@a3\sounds_f\characters\human-sfx\person0\p0_moan_17_words.wss", 5, 1.0, 30, 0.125, 2, 3, 4 };
        sound5[] = { "@a3\sounds_f\characters\human-sfx\person0\p0_moan_18_words.wss", 5, 1.0, 30, 0.125, 2, 3, 4 };
        sound6[] = { "@a3\sounds_f\characters\human-sfx\person0\p0_moan_19_words.wss", 5, 1.0, 30, 0.125, 2, 3, 4 };
        sound7[] = { "@a3\sounds_f\characters\human-sfx\person0\p0_moan_20_words.wss", 5, 1.0, 30, 0.125, 2, 3, 4 };
        empty[] = { "", 0, 0, 0, 0, 0, 0, 0 };
    };
};

class CfgVehicles {
	class WLDemolitionSound {
		sound = "WLDemolition";
	};

    class WLAlarmSound {
		sound = "WLAlarm";
	};

    class WLRopeTravelSound {
        sound = "WLRopeTravel";
    };

    class WLDownedSound {
        sound = "WLDowned";
    };
};