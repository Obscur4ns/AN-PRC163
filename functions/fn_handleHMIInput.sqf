params [
    ["_input","",[""]],
    ["_value",-1,[0]],
    ["_radioId","",[""]]
];

_input = toUpper _input;

if (_input in [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9"
]) then {
    _value = parseNumber _input;
    _input = "DIGIT";
};

if (
    _input isEqualTo "" ||
    {
        !(
            _input in [
                "UP",
                "DOWN",
                "LEFT",
                "RIGHT",
                "ENT",
                "CLR",
                "DIGIT",
                "P1",
                "P2",
                "P3",
                "MENU",
                "HOME"
            ]
        )
    }
) exitWith {
    false
};

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

if (_radioId isEqualTo "") exitWith {
    false
};

private _state = [
    _radioId
] call UKSF_PRC163_fnc_getHMIState;

if ((count _state) isEqualTo 0) exitWith {
    false
};

private _radioA = _state get "radioA";
private _radioB = _state get "radioB";

private _page = _state getOrDefault [
    "page",
    "HOME"
];

private _cursor = _state getOrDefault [
    "cursor",
    0
];

private _inputBuffer = _state getOrDefault [
    "inputBuffer",
    ""
];

private _editing = _state getOrDefault [
    "editing",
    0
];

private _selectedLine = _state getOrDefault [
    "selectedLine",
    0
];

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

private _targetRadio = [
    _radioA,
    _radioB
] select _selectedLine;

private _powerA = [
    _radioA
] call acre_api_fnc_getRadioOnOffState;

private _powerB = [
    _radioB
] call acre_api_fnc_getRadioOnOffState;

private _isPowered = (
    (_powerA isEqualTo 1) ||
    (_powerA isEqualTo true) ||
    (_powerB isEqualTo 1) ||
    (_powerB isEqualTo true)
);

private _setSharedState = {
    params [
        "_name",
        "_stateValue"
    ];

    {
        [
            _x,
            "setState",
            [
                _name,
                _stateValue
            ]
        ] call acre_sys_data_fnc_dataEvent;
    } forEach [
        _radioA,
        _radioB
    ];
};

private _setHMIState = {
    params [
        "_newPage",
        "_newCursor",
        "_newInputBuffer",
        "_newEditing"
    ];

    [
        "prc163HMIPage",
        _newPage
    ] call _setSharedState;

    [
        "prc163HMICursor",
        _newCursor
    ] call _setSharedState;

    [
        "prc163HMIInputBuffer",
        _newInputBuffer
    ] call _setSharedState;

    [
        "prc163HMIEditing",
        _newEditing
    ] call _setSharedState;
};

private _rejectPoweredOff = {
    [
        "AN/PRC-163 | POWER OFF",
        0.8,
        [
            1,
            0.55,
            0.2,
            1
        ],
        true
    ] call CBA_fnc_notify;

    false
};

private _rejectPresetInput = {
    params [
        ["_message","INVALID PRESET",[""]]
    ];

    [
        format [
            "AN/PRC-163 | %1",
            _message
        ],
        0.8,
        [
            1,
            0.55,
            0.2,
            1
        ],
        true
    ] call CBA_fnc_notify;

    false
};

private _adjustVolume = {
    params ["_direction"];

    if !(_isPowered) exitWith {
        call _rejectPoweredOff
    };

    private _stateName = [
        "prc163VolumeA",
        "prc163VolumeB"
    ] select _selectedLine;

    private _currentVolume = [
        _radioA,
        "getState",
        _stateName
    ] call acre_sys_data_fnc_dataEvent;

    if (
        isNil "_currentVolume" ||
        {!(_currentVolume isEqualType 0)}
    ) then {
        _currentVolume = 1;
    };

    private _newVolume = (
        _currentVolume +
        (_direction * 0.1)
    ) max 0 min 1;

    _newVolume = (
        round (_newVolume * 10)
    ) / 10;

    [
        _targetRadio,
        _newVolume
    ] call acre_api_fnc_setRadioVolume
};

private _adjustSpatial = {
    params ["_direction"];

    if !(_isPowered) exitWith {
        call _rejectPoweredOff
    };

    private _stateName = [
        "prc163SpatialA",
        "prc163SpatialB"
    ] select _selectedLine;

    private _currentSpatial = [
        _radioA,
        "getState",
        _stateName
    ] call acre_sys_data_fnc_dataEvent;

    if !(_currentSpatial in [-1,0,1]) then {
        _currentSpatial = 0;
    };

    private _spatialValues = [
        -1,
        0,
        1
    ];

    private _currentIndex = _spatialValues find _currentSpatial;

    if (_currentIndex < 0) then {
        _currentIndex = 1;
    };

    private _newIndex = (
        _currentIndex +
        _direction +
        count _spatialValues
    ) % count _spatialValues;

    private _newSpatial = _spatialValues select _newIndex;

    private _spatialName = switch (_newSpatial) do {
        case -1: {
            "LEFT"
        };

        case 1: {
            "RIGHT"
        };

        default {
            "CENTER"
        };
    };

    [
        _targetRadio,
        _spatialName
    ] call acre_api_fnc_setRadioSpatial
};

private _adjustTxPower = {
    params ["_direction"];

    if !(_isPowered) exitWith {
        call _rejectPoweredOff
    };

    private _powerValues = [
        250,
        500,
        1000,
        2500,
        5000
    ];

    private _currentPower = [
        _radioA,
        _selectedLine
    ] call UKSF_PRC163_fnc_getTxPower;

    private _currentIndex = _powerValues find _currentPower;

    if (_currentIndex < 0) then {
        _currentIndex = (
            count _powerValues
        ) - 1;
    };

    private _newIndex = (
        _currentIndex +
        _direction +
        count _powerValues
    ) % count _powerValues;

    [
        _radioA,
        _selectedLine,
        _powerValues select _newIndex
    ] call UKSF_PRC163_fnc_setTxPower
};

private _selectRTLine = {
    params [
        ["_line",0,[0]]
    ];

    if !(_isPowered) exitWith {
        call _rejectPoweredOff
    };

    _line = (round _line) max 0 min 1;

    [
        _radioA,
        _line
    ] call UKSF_PRC163_fnc_selectLine
};

private _powerOff = {
    if !(_isPowered) exitWith {
        false
    };

    private _success = [
        _radioA,
        "setOnOffState",
        0
    ] call acre_sys_data_fnc_dataEvent;

    if (_success isEqualTo false) exitWith {
        false
    };

    [
        "HOME",
        0,
        "",
        0
    ] call _setHMIState;

    closeDialog 0;
    true
};

private _handled = false;

switch (_input) do {
    case "HOME";
    case "P1": {
        [
            "HOME",
            0,
            "",
            0
        ] call _setHMIState;

        _handled = true;
    };

    case "MENU";
    case "P2": {
        [
            "MENU",
            0,
            "",
            0
        ] call _setHMIState;

        _handled = true;
    };

    case "P3": {
        if (_isPowered) then {
            _handled = [] call UKSF_PRC163_fnc_toggleDualWatch;
        } else {
            _handled = call _rejectPoweredOff;
        };
    };

    case "CLR": {
        switch (_page) do {
            case "HOME": {
                closeDialog 0;
                _handled = true;
            };

            case "MENU": {
                [
                    "HOME",
                    0,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };

            case "RTSELECT": {
                [
                    "MENU",
                    0,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };

            case "PRESET": {
                if (_inputBuffer != "") then {
                    private _newLength = (
                        count _inputBuffer
                    ) - 1;

                    private _newBuffer = if (
                        _newLength > 0
                    ) then {
                        _inputBuffer select [
                            0,
                            _newLength
                        ]
                    } else {
                        ""
                    };

                    [
                        "prc163HMIInputBuffer",
                        _newBuffer
                    ] call _setSharedState;

                    _handled = true;
                } else {
                    [
                        "MENU",
                        1,
                        "",
                        0
                    ] call _setHMIState;

                    _handled = true;
                };
            };

            case "VOLUME": {
                [
                    "MENU",
                    2,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };

            case "AUDIO": {
                [
                    "MENU",
                    3,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };

            case "STATUS": {
                [
                    "MENU",
                    5,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };

            case "TXPOWER": {
                [
                    "MENU",
                    7,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };

            default {
                [
                    "HOME",
                    0,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };
        };
    };

    case "ENT": {
        switch (_page) do {
            case "HOME": {
                [
                    "MENU",
                    0,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };

            case "MENU": {
                switch (_cursor) do {
                    case 0: {
                        if !(_isPowered) exitWith {
                            _handled = call _rejectPoweredOff;
                        };

                        [
                            "RTSELECT",
                            0,
                            "",
                            0
                        ] call _setHMIState;

                        _handled = true;
                    };

                    case 1: {
                        if !(_isPowered) exitWith {
                            _handled = call _rejectPoweredOff;
                        };

                        [
                            "PRESET",
                            0,
                            "",
                            1
                        ] call _setHMIState;

                        _handled = true;
                    };

                    case 2: {
                        if !(_isPowered) exitWith {
                            _handled = call _rejectPoweredOff;
                        };

                        [
                            "VOLUME",
                            0,
                            "",
                            0
                        ] call _setHMIState;

                        _handled = true;
                    };

                    case 3: {
                        if !(_isPowered) exitWith {
                            _handled = call _rejectPoweredOff;
                        };

                        [
                            "AUDIO",
                            0,
                            "",
                            0
                        ] call _setHMIState;

                        _handled = true;
                    };

                    case 4: {
                        if !(_isPowered) exitWith {
                            _handled = call _rejectPoweredOff;
                        };

                        _handled = [] call UKSF_PRC163_fnc_toggleDualWatch;

                        if (_handled) then {
                            [
                                "HOME",
                                0,
                                "",
                                0
                            ] call _setHMIState;
                        };
                    };

                    case 5: {
                        [
                            "STATUS",
                            0,
                            "",
                            0
                        ] call _setHMIState;

                        _handled = true;
                    };

                    case 6: {
                        _handled = call _powerOff;
                    };

                    case 7: {
                        if !(_isPowered) exitWith {
                            _handled = call _rejectPoweredOff;
                        };

                        [
                            "TXPOWER",
                            0,
                            "",
                            0
                        ] call _setHMIState;

                        _handled = true;
                    };
                };
            };

            case "PRESET": {
                if !(_isPowered) exitWith {
                    _handled = call _rejectPoweredOff;
                };

                if (_inputBuffer isEqualTo "") exitWith {
                    _handled = [
                        "ENTER PRESET 01-99"
                    ] call _rejectPresetInput;
                };

                private _preset = parseNumber _inputBuffer;

                if (
                    _preset < 1 ||
                    {_preset > 99}
                ) exitWith {
                    _handled = [
                        "INVALID PRESET 01-99"
                    ] call _rejectPresetInput;
                };

                _handled = [
                    _radioA,
                    _selectedLine,
                    _preset - 1
                ] call UKSF_PRC163_fnc_setLineChannel;

                if (_handled) then {
                    [
                        "HOME",
                        0,
                        "",
                        0
                    ] call _setHMIState;

                    [
                        _targetRadio
                    ] call UKSF_PRC163_fnc_notifyStatus;
                };
            };

            case "RTSELECT";
            case "VOLUME";
            case "AUDIO";
            case "STATUS";
            case "TXPOWER": {
                [
                    "HOME",
                    0,
                    "",
                    0
                ] call _setHMIState;

                _handled = true;
            };
        };
    };

    case "UP": {
        switch (_page) do {
            case "HOME": {
                if (_isPowered) then {
                    _handled = [
                        _radioA,
                        0
                    ] call UKSF_PRC163_fnc_selectLine;
                } else {
                    _handled = call _rejectPoweredOff;
                };
            };

            case "RTSELECT": {
                _handled = [
                    0
                ] call _selectRTLine;
            };

            case "MENU": {
                private _newCursor = (
                    _cursor - 1 + 8
                ) % 8;

                [
                    "prc163HMICursor",
                    _newCursor
                ] call _setSharedState;

                _handled = true;
            };

            case "PRESET": {
                if !(_isPowered) then {
                    _handled = call _rejectPoweredOff;
                } else {
                    if (
                        _editing isEqualTo 1 ||
                        {!(_inputBuffer isEqualTo "")}
                    ) then {
                        _handled = [
                            "CLR ENTRY OR PRESS ENT"
                        ] call _rejectPresetInput;
                    } else {
                        _handled = [
                            1
                        ] call UKSF_PRC163_fnc_cycleChannel;
                    };
                };
            };

            case "VOLUME": {
                _handled = [
                    1
                ] call _adjustVolume;
            };

            case "AUDIO": {
                _handled = [
                    1
                ] call _adjustSpatial;
            };

            case "TXPOWER": {
                _handled = [
                    1
                ] call _adjustTxPower;
            };
        };
    };

    case "DOWN": {
        switch (_page) do {
            case "HOME": {
                if (_isPowered) then {
                    _handled = [
                        _radioA,
                        1
                    ] call UKSF_PRC163_fnc_selectLine;
                } else {
                    _handled = call _rejectPoweredOff;
                };
            };

            case "RTSELECT": {
                _handled = [
                    1
                ] call _selectRTLine;
            };

            case "MENU": {
                private _newCursor = (
                    _cursor + 1
                ) % 8;

                [
                    "prc163HMICursor",
                    _newCursor
                ] call _setSharedState;

                _handled = true;
            };

            case "PRESET": {
                if !(_isPowered) then {
                    _handled = call _rejectPoweredOff;
                } else {
                    if (
                        _editing isEqualTo 1 ||
                        {!(_inputBuffer isEqualTo "")}
                    ) then {
                        _handled = [
                            "CLR ENTRY OR PRESS ENT"
                        ] call _rejectPresetInput;
                    } else {
                        _handled = [
                            -1
                        ] call UKSF_PRC163_fnc_cycleChannel;
                    };
                };
            };

            case "VOLUME": {
                _handled = [
                    -1
                ] call _adjustVolume;
            };

            case "AUDIO": {
                _handled = [
                    -1
                ] call _adjustSpatial;
            };

            case "TXPOWER": {
                _handled = [
                    -1
                ] call _adjustTxPower;
            };
        };
    };

    case "LEFT": {
        switch (_page) do {
            case "HOME": {
                if (_isPowered) then {
                    _handled = [
                        -1
                    ] call UKSF_PRC163_fnc_cycleChannel;
                } else {
                    _handled = call _rejectPoweredOff;
                };
            };

            case "RTSELECT": {
                _handled = [
                    0
                ] call _selectRTLine;
            };

            case "PRESET": {
                if !(_isPowered) then {
                    _handled = call _rejectPoweredOff;
                } else {
                    if (
                        _editing isEqualTo 1 ||
                        {!(_inputBuffer isEqualTo "")}
                    ) then {
                        _handled = [
                            "CLR ENTRY OR PRESS ENT"
                        ] call _rejectPresetInput;
                    } else {
                        _handled = [
                            -1
                        ] call UKSF_PRC163_fnc_cycleChannel;
                    };
                };
            };

            case "VOLUME": {
                _handled = [
                    -1
                ] call _adjustVolume;
            };

            case "AUDIO": {
                _handled = [
                    -1
                ] call _adjustSpatial;
            };

            case "TXPOWER": {
                _handled = [
                    -1
                ] call _adjustTxPower;
            };
        };
    };

    case "RIGHT": {
        switch (_page) do {
            case "HOME": {
                if (_isPowered) then {
                    _handled = [
                        1
                    ] call UKSF_PRC163_fnc_cycleChannel;
                } else {
                    _handled = call _rejectPoweredOff;
                };
            };

            case "RTSELECT": {
                _handled = [
                    1
                ] call _selectRTLine;
            };

            case "PRESET": {
                if !(_isPowered) then {
                    _handled = call _rejectPoweredOff;
                } else {
                    if (
                        _editing isEqualTo 1 ||
                        {!(_inputBuffer isEqualTo "")}
                    ) then {
                        _handled = [
                            "CLR ENTRY OR PRESS ENT"
                        ] call _rejectPresetInput;
                    } else {
                        _handled = [
                            1
                        ] call UKSF_PRC163_fnc_cycleChannel;
                    };
                };
            };

            case "VOLUME": {
                _handled = [
                    1
                ] call _adjustVolume;
            };

            case "AUDIO": {
                _handled = [
                    1
                ] call _adjustSpatial;
            };

            case "TXPOWER": {
                _handled = [
                    1
                ] call _adjustTxPower;
            };
        };
    };

    case "DIGIT": {
        if !(_isPowered) exitWith {
            _handled = call _rejectPoweredOff;
        };

        if !(_page isEqualTo "PRESET") exitWith {
            _handled = false;
        };

        if (
            _value < 0 ||
            {_value > 9}
        ) exitWith {
            _handled = false;
        };

        if ((count _inputBuffer) >= 2) exitWith {
            _handled = [
                "MAXIMUM 2 DIGITS"
            ] call _rejectPresetInput;
        };

        private _newBuffer = format [
            "%1%2",
            _inputBuffer,
            floor _value
        ];

        [
            "prc163HMIInputBuffer",
            _newBuffer
        ] call _setSharedState;

        [
            "prc163HMIEditing",
            1
        ] call _setSharedState;

        _handled = true;
    };
};

_handled
