params [
    ["_radioId","",[""]]
];

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

if (_radioId isEqualTo "") exitWith {
    false
};

private _state = [
    _radioId
] call UKSF_PRC163_fnc_getDisplayState;

if ((count _state) isEqualTo 0) exitWith {
    false
};

private _physicalSlot = _state getOrDefault [
    "physicalSlot",
    -1
];

private _selectedLineName = _state getOrDefault [
    "selectedLineName",
    "R/T 1"
];

private _preset = _state getOrDefault [
    "selectedChannelDisplay",
    1
];

private _modeText = _state getOrDefault [
    "modeText",
    "SINGLE"
];

private _radioName = if (
    _physicalSlot >= 1
) then {
    format [
        "AN/PRC-163 %1",
        _physicalSlot
    ]
} else {
    "AN/PRC-163"
};

private _presetText = if (
    !(_preset isEqualType 0) ||
    {_preset < 1} ||
    {_preset > 99}
) then {
    "P --"
} else {
    if (_preset < 10) then {
        format [
            "P 0%1",
            _preset
        ]
    } else {
        format [
            "P %1",
            _preset
        ]
    }
};

private _message = format [
    "%1 | %2 | %3 | %4",
    _radioName,
    _selectedLineName,
    _presetText,
    _modeText
];

[
    _message,
    1.1,
    [
        0.78,
        0.92,
        0.72,
        1
    ],
    true
] call CBA_fnc_notify;

true