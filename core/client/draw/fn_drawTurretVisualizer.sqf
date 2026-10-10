#include "includes.inc"
params [["_render", true]];

disableSerialization;

private _state = uiNamespace getVariable ["WL2_turretVisualizer", createHashMap];
if (count _state == 0) exitWith {};

private _vehicle = _state getOrDefault ["vehicle", objNull];
private _display = _state getOrDefault ["display", displayNull];
private _shouldClose = isNull _display || !alive player || !alive _vehicle || cameraOn != _vehicle || cameraOn == player;
if (_shouldClose) exitWith {
    [true] call WL2_fnc_updateTurretVisualizer;
};

private _lineControls = _state getOrDefault ["lines", []];
private _labelControls = _state getOrDefault ["labels", []];
private _isBlackfish = typeOf _vehicle == "B_T_VTOL_01_armed_F";

if (!_render && _isBlackfish) then {
    private _canSetReference = !visibleMap && !dialog;
    private _headlightsPressed = _canSetReference && inputAction "headlights" > 0;
    private _headlightsWereHeld = _state getOrDefault ["headlightsHeld", false];

    if (_canSetReference && !_headlightsPressed && _headlightsWereHeld) then {
        private _referenceASL = _state getOrDefault ["referenceASL", []];
        if (count _referenceASL == 0) then {
            private _hitPoint = screenToWorld [0.5, 0.5];
            if !(_hitPoint isEqualTo [0, 0, 0]) then {
                private _hitPointASL = AGLToASL _hitPoint;
                _state set ["referenceASL", _hitPointASL];
            };
        } else {
            _state set ["referenceASL", []];
        };
    };

    _state set ["headlightsHeld", _headlightsPressed];
};

if (visibleMap) exitWith {
    {
        _x ctrlShow false;
    } forEach _lineControls;

    {
        _x ctrlShow false;
    } forEach _labelControls;
};
if (!_render) exitWith {};

private _screenLeft = safeZoneX;
private _screenTop = safeZoneY;
private _screenRight = safeZoneX + safeZoneW;
private _screenBottom = safeZoneY + safeZoneH;
private _screenBounds = [_screenLeft, _screenTop, _screenRight, _screenBottom];

private _screenCenterX = safeZoneX + safeZoneW * 0.5;
private _screenCenterY = safeZoneY + safeZoneH * 0.5;
private _screenCenter = [_screenCenterX, _screenCenterY];

private _cameraAGL = positionCameraToWorld [0, 0, 0];
private _cameraASL = AGLToASL _cameraAGL;
private _cameraForward = vectorNormalized (screenToWorldDirection _screenCenter);

// Build the current frustum from native UI rays, including zoom, aspect and roll.
// A half-pixel inset avoids worldToScreen rejecting a rounded boundary point.
private _horizontalInset = pixelW * 0.5;
private _verticalInset = pixelH * 0.5;
private _screenCorners = [
    [_screenLeft + _horizontalInset, _screenTop + _verticalInset],
    [_screenRight - _horizontalInset, _screenTop + _verticalInset],
    [_screenRight - _horizontalInset, _screenBottom - _verticalInset],
    [_screenLeft + _horizontalInset, _screenBottom - _verticalInset]
];
private _cornerRays = _screenCorners apply {
    screenToWorldDirection _x
};

private _frustumPlanes = [[_cameraForward, 1e-5]];
for "_cornerIndex" from 0 to 3 do {
    private _nextCornerIndex = (_cornerIndex + 1) mod 4;
    private _startRay = _cornerRays # _cornerIndex;
    private _endRay = _cornerRays # _nextCornerIndex;
    private _planeNormal = vectorNormalized (_startRay vectorCrossProduct _endRay);
    private _normalFacing = _planeNormal vectorDotProduct _cameraForward;

    if (_normalFacing < 0) then {
        _planeNormal = _planeNormal vectorMultiply -1;
    };

    _frustumPlanes pushBack [_planeNormal, 0];
};

private _projection = [_cameraASL, _frustumPlanes];
private _green = [0, 1, 0, 1];
private _red = [1, 0, 0, 1];
private _lineCount = 0;
private _labelCount = 0;

private _emitLine = {
    params ["_startPoint", "_endPoint", ["_color", [0, 1, 0, 1]]];

    private _linePosition = [_startPoint, _endPoint, _screenBounds] call WL2_fnc_turretVisualizerLine;
    if (count _linePosition == 0) exitWith {};

    if (_lineCount == count _lineControls) then {
        private _control = _display ctrlCreate ["RscLine", -1];
        _control ctrlSetBackgroundColor [0, 0, 0, 0];
        _control ctrlSetPixelPrecision 2;
        _control ctrlEnable false;

        _lineControls pushBack _control;
    };

    private _control = _lineControls # _lineCount;
    _control ctrlSetTextColor _color;
    _control ctrlSetPosition _linePosition;
    _control ctrlCommit 0;
    _control ctrlShow true;

    _lineCount = _lineCount + 1;
};

private _emitLabel = {
    params ["_screenPoint", "_text"];

    if (_text == "" || count _screenPoint != 2) exitWith {};

    private _labelX = (_screenPoint # 0) + 10 * pixelW;
    private _labelY = _screenPoint # 1;
    private _outsideScreen = _labelX >= _screenRight || _labelX < _screenLeft || _labelY < _screenTop || _labelY >= _screenBottom;
    if (_outsideScreen) exitWith {};

    if (_labelCount == count _labelControls) then {
        private _control = _display ctrlCreate ["RscText", -1];
        _control ctrlSetBackgroundColor [0, 0, 0, 0];
        _control ctrlSetTextColor _green;
        _control ctrlSetFont "RobotoCondensedBold";
        _control ctrlSetShadow 2;
        _control ctrlSetPixelPrecision 2;
        _control ctrlEnable false;

        _labelControls pushBack _control;
    };

    private _control = _labelControls # _labelCount;
    private _fontHeight = 16 * pixelH;
    _control ctrlSetFontHeight _fontHeight;
    _control ctrlSetText _text;

    private _textWidth = ctrlTextWidth _control + 12 * pixelW;
    private _labelWidth = _textWidth min (_screenRight - _labelX);
    private _labelHeight = (24 * pixelH) min (_screenBottom - _labelY);
    private _labelPosition = [_labelX, _labelY, _labelWidth, _labelHeight];
    _control ctrlSetPosition _labelPosition;
    _control ctrlCommit 0;
    _control ctrlShow true;

    _labelCount = _labelCount + 1;
};

private _emitCrosshair = {
    params ["_screenPoint"];

    if (count _screenPoint != 2) exitWith {};
    _screenPoint params ["_screenX", "_screenY"];

    private _halfWidth = 15 * pixelW;
    private _halfHeight = 15 * pixelH;
    private _leftPoint = [_screenX - _halfWidth, _screenY];
    private _rightPoint = [_screenX + _halfWidth, _screenY];
    private _topPoint = [_screenX, _screenY - _halfHeight];
    private _bottomPoint = [_screenX, _screenY + _halfHeight];

    [_leftPoint, _rightPoint] call _emitLine;
    [_topPoint, _bottomPoint] call _emitLine;
};

private _geometryCache = _state getOrDefault ["geometry", createHashMap];
private _turrets = allTurrets [_vehicle, false];
{
    private _turretUnit = _vehicle turretUnit _x;
    if (!isNull _turretUnit) then {
        private _turretData = [_vehicle, _x, _projection, _geometryCache] call WL2_fnc_turretLimits;
        _turretData params ["_segments", "_weaponPoint"];

        {
            _x call _emitLine;
        } forEach _segments;

        [_weaponPoint] call _emitCrosshair;
    };
} forEach _turrets;

private _referenceASL = _state getOrDefault ["referenceASL", []];
if (_isBlackfish && count _referenceASL == 3) then {
    private _referenceDirection = _referenceASL vectorDiff _cameraASL;
    private _referenceScreenPoint = [_projection, _referenceDirection] call WL2_fnc_turretVisualizerProject;
    [_referenceScreenPoint] call _emitCrosshair;
    [_referenceScreenPoint, "REF"] call _emitLabel;

    private _referenceAGL = ASLToAGL _referenceASL;
    private _referenceModelPosition = _vehicle worldToModelVisual _referenceAGL;
    private _directionToReference = vectorNormalized _referenceModelPosition;
    _directionToReference params ["_referenceRight", "_referenceForward", "_referenceUp"];

    private _referenceHorizontalDistance = sqrt (_referenceRight * _referenceRight + _referenceForward * _referenceForward);
    private _referenceTurn = (-_referenceRight) atan2 _referenceForward;
    private _referenceElevation = _referenceUp atan2 _referenceHorizontalDistance;
    private _noseTurn = _referenceTurn - 90;
    private _noseElevation = _referenceElevation + 7.5;

    private _noseDirection = _vehicle vectorModelToWorldVisual [0, 1, 0];
    private _noseScreenPoint = [_projection, _noseDirection] call WL2_fnc_turretVisualizerProject;

    // The nose bars and label remain visible independently of the desired point.
    if (count _noseScreenPoint == 2) then {
        _noseScreenPoint params ["_noseX", "_noseY"];

        private _cosElevation = cos _noseElevation;
        if (abs _cosElevation < 1e-6) then {
            _cosElevation = if (_cosElevation < 0) then { -1e-6 } else { 1e-6 };
        };

        private _pixelAspect = pixelW / pixelH;
        private _tiltSlope = ((sin _noseElevation) / _cosElevation) * _pixelAspect;
        _tiltSlope = _tiltSlope max -1e6 min 1e6;

        private _barHalfHeight = safeZoneH * 0.1;
        private _barTop = _noseY - _barHalfHeight;
        private _barBottom = _noseY + _barHalfHeight;
        private _barCenterX = _noseX + (_noseY - _screenCenterY) * _tiltSlope;
        private _slantedTopX = _noseX + (_barTop - _screenCenterY) * _tiltSlope;
        private _slantedBottomX = _noseX + (_barBottom - _screenCenterY) * _tiltSlope;

        private _isTurnGood = _referenceTurn > 74 && _referenceTurn < 102;
        private _isElevationGood = _referenceElevation > -28 && _referenceElevation < 13;
        private _turnColor = if (_isTurnGood) then { _green } else { _red };
        private _elevationColor = if (_isElevationGood) then { _green } else { _red };

        private _slantedTopPoint = [_slantedTopX, _barTop];
        private _slantedBottomPoint = [_slantedBottomX, _barBottom];
        private _verticalTopPoint = [_barCenterX, _barTop];
        private _verticalBottomPoint = [_barCenterX, _barBottom];

        [_slantedTopPoint, _slantedBottomPoint, _elevationColor] call _emitLine;
        [_verticalTopPoint, _verticalBottomPoint, _elevationColor] call _emitLine;
        [_noseScreenPoint, "PYLON TURN"] call _emitLabel;

        // Calibrate an unbounded projection from screen rays. worldToScreen may
        // return [] outside the view, but the turn line still needs its endpoint.
        private _rightSampleOffset = safeZoneW * 0.25;
        private _upSampleOffset = safeZoneH * 0.25;
        private _rightSamplePoint = [_screenCenterX + _rightSampleOffset, _screenCenterY];
        private _upSamplePoint = [_screenCenterX, _screenCenterY - _upSampleOffset];
        private _rightSampleRay = screenToWorldDirection _rightSamplePoint;
        private _upSampleRay = screenToWorldDirection _upSamplePoint;

        private _rightForwardDistance = _rightSampleRay vectorDotProduct _cameraForward;
        private _upForwardDistance = _upSampleRay vectorDotProduct _cameraForward;
        private _rightForwardComponent = _cameraForward vectorMultiply _rightForwardDistance;
        private _upForwardComponent = _cameraForward vectorMultiply _upForwardDistance;
        private _cameraRight = vectorNormalized (_rightSampleRay vectorDiff _rightForwardComponent);
        private _cameraUp = vectorNormalized (_upSampleRay vectorDiff _upForwardComponent);

        private _rightSampleDistance = _rightSampleRay vectorDotProduct _cameraRight;
        private _upSampleDistance = _upSampleRay vectorDotProduct _cameraUp;
        if (_rightSampleDistance > 1e-8 && _upSampleDistance > 1e-8) then {
            private _horizontalScale = _rightSampleOffset * _rightForwardDistance / _rightSampleDistance;
            private _verticalScale = _upSampleOffset * _upForwardDistance / _upSampleDistance;
            private _projectionScale = [_horizontalScale, _verticalScale];
            private _cameraProjection = [_cameraRight, _cameraUp, _cameraForward, _screenCenter, _projectionScale];
            private _guidanceProjection = [_cameraASL, _frustumPlanes, _cameraProjection];

            private _desiredModelDirection = [-sin _noseTurn, cos _noseTurn, 0];
            private _desiredDirection = _vehicle vectorModelToWorldVisual _desiredModelDirection;
            private _desiredScreenPoint = [_guidanceProjection, _desiredDirection, [], true] call WL2_fnc_turretVisualizerProject;

            // Only the horizontal line depends on the desired direction being
            // in front of the camera. _emitLine clips any offscreen endpoint.
            if (count _desiredScreenPoint == 2) then {
                private _turnStartPoint = [_desiredScreenPoint # 0, _noseY];
                private _turnEndPoint = [_barCenterX, _noseY];

                [_turnStartPoint, _turnEndPoint, _turnColor] call _emitLine;
            };
        };
    };
};

// Reuse controls, hiding any left over after visibility or occupancy changes.
for "_controlIndex" from _lineCount to (count _lineControls - 1) do {
    private _control = _lineControls # _controlIndex;
    _control ctrlShow false;
};

for "_controlIndex" from _labelCount to (count _labelControls - 1) do {
    private _control = _labelControls # _controlIndex;
    _control ctrlShow false;
};

_state set ["lines", _lineControls];
_state set ["labels", _labelControls];
_state set ["geometry", _geometryCache];
