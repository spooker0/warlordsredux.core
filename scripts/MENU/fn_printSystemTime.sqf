params ["_systemTime"];

private _systemTimeUtc = _systemTime apply {
    if (_x < 10) then {
        format ["0%1", _x];
    } else {
        str _x;
    };
};
_systemTimeUtc params ["_year", "_month", "_day", "_hour", "_minute", "_second"];

format["%1/%2/%3 %4:%5:%6", _year, _month, _day, _hour, _minute, _second];