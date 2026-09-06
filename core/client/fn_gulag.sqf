#include "includes.inc"
params ["_timeout", "_reason"];

disableSerialization;

0 fadeEnvironment 0;
disableUserInput true;

private _dialog = createDialog ["RscWLGulag", true];
_dialog displayAddEventHandler ["KeyDown", {
    params ["_control", "_key"];
    _key == 1
}];

private _backgroundControl = _dialog displayCtrl 100;
private _instructionControl = _dialog displayCtrl 101;
private _feedbackControl = _dialog displayCtrl 102;
private _scoreControl = _dialog displayCtrl 103;

private _cardControls = [110, 120] apply { _dialog displayCtrl _x };
private _pictureControls = [111, 121] apply { _dialog displayCtrl _x };
private _captionControls = [112, 122] apply { _dialog displayCtrl _x };
private _progressControls = [114, 124] apply { _dialog displayCtrl _x };

private _progressWidths = [113, 123] apply {
    private _trackControl = _dialog displayCtrl _x;
    private _trackPosition = ctrlPosition _trackControl;
    _trackPosition # 2;
};

private _natoUnits = [
    "B_Soldier_F", "B_Soldier_GL_F", "B_medic_F",
    "B_MRAP_01_F", "B_Truck_01_medical_F", "B_LSV_01_armed_F",
    "B_T_APC_Wheeled_01_cannon_F", "B_APC_Tracked_01_rcws_F", "B_AFV_Wheeled_01_cannon_F", "B_APC_Tracked_01_AA_F",
    "B_MBT_01_TUSK_F", "B_T_MBT_01_mlrs_F", "B_MBT_01_arty_F",
    "B_Heli_Attack_01_pylons_dynamicLoadout_F", "B_Heli_Transport_03_F", "B_CTRG_Heli_Transport_01_tropic_F",
    "B_Plane_CAS_01_dynamicLoadout_F", "B_Plane_Fighter_01_Stealth_F"
];
private _csatUnits = [
    "O_Soldier_F", "O_Soldier_GL_F", "O_medic_F",
    "O_T_MRAP_02_ghex_F", "O_Truck_03_medical_F", "O_LSV_02_armed_F",
    "O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_v2_F", "O_APC_Wheeled_02_rcws_v2_F", "O_APC_Tracked_02_AA_F",
    "O_T_MBT_04_command_F", "O_MBT_02_cannon_F", "O_MBT_02_arty_F",
    "O_Heli_Attack_02_dynamicLoadout_F", "O_Heli_Transport_04_F", "O_Heli_Light_02_dynamicLoadout_F",
    "O_Plane_CAS_02_dynamicLoadout_F", "O_Plane_Fighter_02_Stealth_F"
];
private _aafUnits = [
    "I_soldier_F", "I_Soldier_GL_F", "I_medic_F",
    "I_MRAP_03_F", "I_MRAP_03_hmg_F", "I_MRAP_03_gmg_F",
    "I_APC_Wheeled_03_cannon_F", "I_APC_tracked_03_cannon_F", "I_APC_tracked_03_cannon_F", "I_LT_01_AA_F",
    "I_MBT_03_cannon_F", "I_APC_tracked_03_cannon_F", "I_LT_01_AT_F",
    "I_Heli_light_03_dynamicLoadout_F", "I_Heli_light_03_dynamicLoadout_F", "I_Heli_light_03_dynamicLoadout_F",
    "I_Plane_Fighter_03_dynamicLoadout_F", "I_Plane_Fighter_04_F"
];

private _factions = [
    [west, "NATO", _natoUnits],
    [east, "CSAT", _csatUnits],
    [independent, "AAF", _aafUnits]
];

private _holdDuration = 0.5;
private _feedbackDuration = 2;
private _hoverInstructionText = "Hover over an identification card to select it.";

private _textColor = [1, 1, 1, 1];
private _neutralColor = [0.11, 0.13, 0.16, 1];
private _hoverColor = [0.25, 0.23, 0.16, 1];
private _progressColor = [0.9, 0.75, 0.35, 1];
private _correctColor = [0.35, 0.9, 0.45, 1];
private _wrongColor = [1, 0.4, 0.35, 1];
private _enemyCardColor = [0.08, 0.24, 0.12, 1];
private _friendlyCardColor = [0.25, 0.1, 0.1, 1];

private _setProgress = {
    params ["_cardIndex", "_progress"];

    private _progressControl = _progressControls # _cardIndex;
    private _fullWidth = _progressWidths # _cardIndex;
    private _filledWidth = _fullWidth * _progress;

    private _progressPosition = ctrlPosition _progressControl;
    _progressPosition set [2, _filledWidth];

    _progressControl ctrlSetPosition _progressPosition;
    _progressControl ctrlCommit 0;
};

private _correctAnswers = 0;
private _answers = 0;

private _enemyIndex = -1;
private _roundFactions = [];

private _hoveredCard = -1;
private _hoverStarted = 0;
private _waitingForExit = false;

private _newRound = true;
private _feedbackUntil = 0;
private _nextCountdownUpdate = 0;

_scoreControl ctrlSetText "Correct: 0 / 0";

while { serverTime < _timeout && !(isNull _dialog) } do {
    private _now = diag_tickTime;

    if (_now >= _nextCountdownUpdate) then {
        private _secondsLeft = (_timeout - serverTime) max 0;
        private _timeLeft = [_secondsLeft, "HH:MM:SS"] call BIS_fnc_secondsToString;
        private _timeoutText = format ["You have been timed out.\nReason: %1\nTimeout: %2", _reason, _timeLeft];

        _backgroundControl ctrlSetText _timeoutText;
        _nextCountdownUpdate = _now + 0.2;
    };

    if (_newRound && _now >= _feedbackUntil) then {
        private _groupSide = side group player;
        private _playerSide = missionNamespace getVariable ["BIS_WL_playerSide", _groupSide];
        private _friendlyFactionIndex = _factions findIf {
            private _factionSide = _x # 0;
            _factionSide == _playerSide;
        };

        // A reconnect can reach this screen before team selection has completed.
        private _teamLabel = if (_friendlyFactionIndex < 0) then {
            "Training team";
        } else {
            "Your team";
        };
        _friendlyFactionIndex = _friendlyFactionIndex max 0;

        private _friendlyFaction = _factions # _friendlyFactionIndex;
        private _friendlySide = _friendlyFaction # 0;

        private _enemyFactions = _factions select {
            private _factionSide = _x # 0;
            _factionSide != _friendlySide;
        };
        private _enemyFaction = selectRandom _enemyFactions;

        private _friendlyUnits = _friendlyFaction # 2;
        private _enemyUnits = _enemyFaction # 2;
        private _friendlyUnitCount = count _friendlyUnits;
        private _enemyUnitCount = count _enemyUnits;

        private _sharedUnitCount = _friendlyUnitCount min _enemyUnitCount;
        private _unitIndex = floor (random _sharedUnitCount);

        _enemyIndex = selectRandom [0, 1];
        _roundFactions = [_friendlyFaction, _friendlyFaction];
        _roundFactions set [_enemyIndex, _enemyFaction];

        {
            private _cardControl = _x;
            private _cardIndex = _forEachIndex;
            private _pictureControl = _pictureControls # _cardIndex;
            private _captionControl = _captionControls # _cardIndex;
            private _progressControl = _progressControls # _cardIndex;

            private _faction = _roundFactions # _cardIndex;
            private _unitClasses = _faction # 2;
            private _className = _unitClasses # _unitIndex;
            private _unitConfig = configFile >> "CfgVehicles" >> _className;

            private _picturePath = getText (_unitConfig >> "editorPreview");
            if (_picturePath == "") then {
                _picturePath = format ["\a3\editorpreviews_f\data\CfgVehicles\%1.jpg", _className];
            };

            _pictureControl ctrlSetText _picturePath;
            _captionControl ctrlSetText "Hold to select";
            _captionControl ctrlSetTextColor _textColor;

            _cardControl ctrlSetBackgroundColor _neutralColor;
            _progressControl ctrlSetBackgroundColor _progressColor;
            [_cardIndex, 0] call _setProgress;
        } forEach _cardControls;

        private _friendlyName = _friendlyFaction # 1;
        private _instructionText = format ["%1: %2. Identify the enemy.", _teamLabel, _friendlyName];
        _instructionControl ctrlSetText _instructionText;

        private _feedbackText = if (_waitingForExit) then {
            "Move your cursor off the cards to start the next round.";
        } else {
            _hoverInstructionText;
        };

        _feedbackControl ctrlSetTextColor _textColor;
        _feedbackControl ctrlSetText _feedbackText;

        _hoveredCard = -1;
        _newRound = false;
    };

    if (!_newRound) then {
        getMousePosition params ["_mouseX", "_mouseY"];

        private _underMouse = _cardControls findIf {
            private _cardPosition = ctrlPosition _x;
            _cardPosition params ["_xPos", "_yPos", "_width", "_height"];

            private _rightEdge = _xPos + _width;
            private _bottomEdge = _yPos + _height;
            private _withinWidth = _mouseX >= _xPos && _mouseX <= _rightEdge;
            private _withinHeight = _mouseY >= _yPos && _mouseY <= _bottomEdge;

            _withinWidth && _withinHeight;
        };

        // Require a fresh approach after feedback so a stationary cursor cannot answer successive rounds.
        if (_waitingForExit && _underMouse == -1) then {
            _waitingForExit = false;
            _feedbackControl ctrlSetText _hoverInstructionText;
        };

        if (!_waitingForExit) then {
            if (_underMouse != _hoveredCard) then {
                _hoveredCard = _underMouse;
                _hoverStarted = _now;

                {
                    private _cardControl = _x;
                    private _cardIndex = _forEachIndex;

                    private _cardColor = if (_cardIndex == _hoveredCard) then {
                        _hoverColor;
                    } else {
                        _neutralColor;
                    };

                    _cardControl ctrlSetBackgroundColor _cardColor;
                    [_cardIndex, 0] call _setProgress;
                } forEach _cardControls;
            };

            if (_hoveredCard != -1) then {
                private _hoverDuration = _now - _hoverStarted;
                private _progress = (_hoverDuration / _holdDuration) min 1;
                [_hoveredCard, _progress] call _setProgress;

                if (_progress >= 1) then {
                    private _correct = _hoveredCard == _enemyIndex;

                    _answers = _answers + 1;
                    if (_correct) then {
                        playSoundUI ["hitmarker", 2];
                        _correctAnswers = _correctAnswers + 1;
                    } else {
                        playSoundUI ["AddItemFailed", 2];
                    };

                    private _scoreText = format ["Correct: %1 / %2", _correctAnswers, _answers];
                    _scoreControl ctrlSetText _scoreText;

                    private _feedbackText = if (_correct) then {
                        "Correct! You picked the enemy.";
                    } else {
                        "Wrong! You picked a friendly.";
                    };

                    private _feedbackColor = if (_correct) then {
                        _correctColor;
                    } else {
                        _wrongColor;
                    };

                    _feedbackControl ctrlSetText _feedbackText;
                    _feedbackControl ctrlSetTextColor _feedbackColor;

                    private _selectedProgressControl = _progressControls # _hoveredCard;
                    _selectedProgressControl ctrlSetBackgroundColor _feedbackColor;

                    {
                        private _captionControl = _x;
                        private _cardIndex = _forEachIndex;
                        private _cardControl = _cardControls # _cardIndex;

                        private _faction = _roundFactions # _cardIndex;
                        private _factionName = _faction # 1;
                        private _isEnemy = _cardIndex == _enemyIndex;

                        private _relationshipText = if (_isEnemy) then {
                            "ENEMY";
                        } else {
                            "FRIENDLY";
                        };

                        private _captionColor = if (_isEnemy) then {
                            _correctColor;
                        } else {
                            _wrongColor;
                        };

                        private _cardColor = if (_isEnemy) then {
                            _enemyCardColor;
                        } else {
                            _friendlyCardColor;
                        };

                        private _captionText = format ["%1 - %2", _relationshipText, _factionName];
                        _captionControl ctrlSetText _captionText;
                        _captionControl ctrlSetTextColor _captionColor;
                        _cardControl ctrlSetBackgroundColor _cardColor;
                    } forEach _captionControls;

                    _feedbackUntil = _now + _feedbackDuration;
                    _waitingForExit = true;
                    _newRound = true;
                };
            };
        };
    };

    uiSleep 0.02;
};

if (!isNull _dialog) then {
    _dialog closeDisplay 0;
};

disableUserInput false;
0 fadeEnvironment 1;