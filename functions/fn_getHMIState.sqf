params [
    ["_radioId","",[""]]
];

private _prefix = "acre_prc163_id_";

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    createHashMap
};

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _radioA = "";
private _radioB = "";

if (_pilotEnabled) then {
    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _mapKeys = keys _endpointMap;
    private _entry = _endpointMap getOrDefault [
        _sourceRadioId,
        []
    ];

    if !(_entry isEqualTo []) then {
        _radioA = _sourceRadioId;
    } else {
        private _statePrimary = [
            _sourceRadioId,
            "getState",
            "prc163PrimaryRadio"
        ] call acre_sys_data_fnc_dataEvent;

        if (
            !isNil "_statePrimary" &&
            {_statePrimary isEqualType ""}
        ) then {
            _statePrimary = toLower _statePrimary;

            if (_statePrimary in _mapKeys) then {
                _radioA = _statePrimary;
                _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];
            };
        };

        if (_radioA isEqualTo "") then {
            private _primaryIndex = _mapKeys findIf {
                private _candidateEntry = _endpointMap getOrDefault [
                    _x,
                    []
                ];

                toLower (
                    _candidateEntry param [
                        0,
                        "",
                        [""]
                    ]
                ) isEqualTo _sourceRadioId
            };

            if (_primaryIndex >= 0) then {
                _radioA = _mapKeys select _primaryIndex;
                _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];
            };
        };
    };

    _radioA = toLower _radioA;
    _radioB = toLower (
        _entry param [
            0,
            "",
            [""]
        ]
    );

    private _gear = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (
        !(_radioA in _gear) ||
        {_radioA isEqualTo _radioB} ||
        {_radioB find _prefix != 0}
    ) then {
        _radioA = "";
        _radioB = "";
    };
} else {
    private _radioIds = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (_sourceRadioId in _radioIds) then {
        private _sourceNumber = parseNumber (
            _sourceRadioId select [
                count _prefix
            ]
        );

        if (_sourceNumber >= 1) then {
            private _radioANumber = if (
                (_sourceNumber mod 2) isEqualTo 1
            ) then {
                _sourceNumber
            } else {
                _sourceNumber - 1
            };

            private _candidateA = format [
                "%1%2",
                _prefix,
                _radioANumber
            ];

            private _candidateB = format [
                "%1%2",
                _prefix,
                _radioANumber + 1
            ];

            if (
                _candidateA in _radioIds &&
                {_candidateB in _radioIds}
            ) then {
                _radioA = _candidateA;
                _radioB = _candidateB;
            };
        };
    };
};

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""}
) exitWith {
    createHashMap
};

if !(
    [
        _radioA,
        _radioB,
        player
    ] call UKSF_PRC163_fnc_isPairHealthy
) exitWith {
    createHashMap
};

private _initialized = [
    _radioA,
    "getState",
    "prc163Initialized"
] call acre_sys_data_fnc_dataEvent;

if !(_initialized isEqualTo true) then {
    if !(
        [
            _radioA
        ] call UKSF_PRC163_fnc_initializeState
    ) exitWith {
        createHashMap
    };
};

private _readAnchorState = {
    params [
        "_name",
        "_default"
    ];

    private _value = [
        _radioA,
        "getState",
        _name
    ] call acre_sys_data_fnc_dataEvent;

    if (isNil "_value") then {
        _default
    } else {
        _value
    }
};

private _repairSharedState = {
    params [
        "_name",
        "_value"
    ];

    {
        private _currentValue = [
            _x,
            "getState",
            _name
        ] call acre_sys_data_fnc_dataEvent;

        if (
            isNil "_currentValue" ||
            {!(_currentValue isEqualTo _value)}
        ) then {
            [
                _x,
                "setState",
                [
                    _name,
                    _value
                ]
            ] call acre_sys_data_fnc_dataEvent;
        };
    } forEach [
        _radioA,
        _radioB
    ];
};

private _selectedLine = [
    "prc163SelectedLine",
    0
] call _readAnchorState;

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

private _page = [
    "prc163HMIPage",
    "HOME"
] call _readAnchorState;

if !(_page isEqualType "") then {
    _page = "HOME";
};

_page = toUpper _page;

private _validPages = [
    "HOME",
    "MENU",
    "RTSELECT",
    "PRESET",
    "VOLUME",
    "AUDIO",
    "TXPOWER",
    "STATUS"
];

if !(_page in _validPages) then {
    _page = "HOME";
};

private _cursor = [
    "prc163HMICursor",
    0
] call _readAnchorState;

if !(_cursor isEqualType 0) then {
    _cursor = 0;
};

_cursor = floor (
    (_cursor max 0) min 7
);

private _inputBuffer = [
    "prc163HMIInputBuffer",
    ""
] call _readAnchorState;

if !(_inputBuffer isEqualType "") then {
    _inputBuffer = "";
};

private _inputCharacters = (
    toArray _inputBuffer
) select {
    _x >= 48 &&
    {_x <= 57}
};

_inputBuffer = toString _inputCharacters;

if ((count _inputBuffer) > 2) then {
    _inputBuffer = _inputBuffer select [
        0,
        2
    ];
};

private _editing = [
    "prc163HMIEditing",
    0
] call _readAnchorState;

_editing = if (
    _editing isEqualTo 1 ||
    {_editing isEqualTo true}
) then {
    1
} else {
    0
};

if !(_page isEqualTo "PRESET") then {
    _inputBuffer = "";
    _editing = 0;
};

[
    "prc163SelectedLine",
    _selectedLine
] call _repairSharedState;

[
    "prc163HMIPage",
    _page
] call _repairSharedState;

[
    "prc163HMICursor",
    _cursor
] call _repairSharedState;

[
    "prc163HMIInputBuffer",
    _inputBuffer
] call _repairSharedState;

[
    "prc163HMIEditing",
    _editing
] call _repairSharedState;

private _targetRadio = [
    _radioA,
    _radioB
] select _selectedLine;

private _physicalSlot = [
    _radioA
] call UKSF_PRC163_fnc_getBatterySlot;

private _state = createHashMap;

_state set [
    "radioId",
    _targetRadio
];

_state set [
    "radioA",
    _radioA
];

_state set [
    "radioB",
    _radioB
];

_state set [
    "physicalSlot",
    _physicalSlot
];

_state set [
    "selectedLine",
    _selectedLine
];

_state set [
    "selectedLineName",
    [
        "R/T 1",
        "R/T 2"
    ] select _selectedLine
];

_state set [
    "page",
    _page
];

_state set [
    "cursor",
    _cursor
];

_state set [
    "inputBuffer",
    _inputBuffer
];

_state set [
    "editing",
    _editing
];

_state set [
    "isEditing",
    _editing isEqualTo 1
];

_state
