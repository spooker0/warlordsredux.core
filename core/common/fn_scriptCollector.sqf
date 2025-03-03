params ["_messageTemplate"];

private _fps = diag_fps;
private _fpsMin = diag_fpsMin;
private _entitiesCount = count entities "";

private _consoleScripts = [];

private _getRunningScripts = {
    private _activeScripts = [];
    {
        private _filePath = (_x # 1) splitString "\";
        private _filePathCount = count _filePath;
        if (_filePathCount > 3) then {
            _filePath = format [
                "%1/%2/%3",
                _filePath # (_filePathCount - 3),
                _filePath # (_filePathCount - 2),
                _filePath # (_filePathCount - 1)
            ];
        } else {
            _filePath = "console script";
            private _script = (_x # 0) regexReplace ["\n", ""];
            _consoleScripts pushBack _script;
        };
        private _codeLine = _x # 3;

        private _existingEntries = _activeScripts select {
            _x # 0 == _filePath && _x # 1 == _codeLine
        };
        if (count _existingEntries > 0) then {
            _existingEntries # 0 set [2, (_existingEntries # 0 # 2) + 1];
        } else {
            _activeScripts pushBack [_filePath, _codeLine, 1];
        };
    } forEach diag_activeSQFScripts;

    private _sortedActiveScripts = [_activeScripts, [], { _x # 0 }, "ASCEND"] call BIS_fnc_sortBy;
    _sortedActiveScripts apply {
        format ["(%1x) %2: %3", _x # 2, _x # 0, _x # 1]
    };
};
private _runningScripts1 = call _getRunningScripts;
sleep 1;
private _runningScripts2 = call _getRunningScripts;
sleep 1;
private _runningScripts3 = call _getRunningScripts;
_runningScripts2 = _runningScripts2 select {
    !(_x in _runningScripts1)
};
_runningScripts3 = _runningScripts3 select {
    !(_x in _runningScripts1)
};

private _message = [];
_message pushBack _messageTemplate;

_message append [
    format ["UTC: %1", systemTimeUTC joinString ","],
    format ["FPS: %1", _fps],
    format ["Min FPS: %1", _fpsMin],
    format ["Entities: %1", _entitiesCount]
];

_message pushBack "===== Scripts[0s] =====";
_message append _runningScripts1;
_message pushBack "===== Scripts[1s] =====";
_message append _runningScripts2;
_message pushBack "===== Scripts[2s] =====";
_message append _runningScripts3;
_message pushBack "===== Console Scripts =====";
_message append _consoleScripts;

_message;