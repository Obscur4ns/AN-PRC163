if (isNull player) exitWith {
    ""
};

private _prefix = "acre_prc163_id_";
private _pairs = [];

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

if (_pilotEnabled) then {
    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    {
        private _radioA = toLower _x;
        private _entry = _endpointMap getOrDefault [
            _x,
            []
        ];

        private _radioB = toLower (
            _entry param [
                0,
                "",
                [""]
            ]
        );

        if (
            [
                _radioA,
                _radioB,
                player
            ] call UKSF_PRC163_fnc_isPairHealthy
        ) then {
            private _number = parseNumber (
                _radioA select [
                    count _prefix
                ]
            );

            _pairs pushBack [
                _number,
                _radioA,
                _radioB
            ];
        };
    } forEach (keys _endpointMap);
} else {
    private _gear = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    private _radioEntries = (_gear select {
        _x find _prefix isEqualTo 0
    }) apply {
        [
            parseNumber (
                _x select [
                    count _prefix
                ]
            ),
            _x
        ]
    };

    {
        private _number = _x select 0;
        private _radioA = _x select 1;

        if (
            _number >= 1 &&
            {(_number mod 2) isEqualTo 1}
        ) then {
            private _radioBIndex = _radioEntries findIf {
                (_x select 0) isEqualTo (_number + 1)
            };

            if (_radioBIndex >= 0) then {
                private _radioB = (
                    _radioEntries select _radioBIndex
                ) select 1;

                if (
                    [
                        _radioA,
                        _radioB,
                        player
                    ] call UKSF_PRC163_fnc_isPairHealthy
                ) then {
                    _pairs pushBack [
                        _number,
                        _radioA,
                        _radioB
                    ];
                };
            };
        };
    } forEach _radioEntries;
};

_pairs sort true;

if (_pairs isEqualTo []) exitWith {
    missionNamespace setVariable [
        "UKSF_PRC163_activeRadio",
        ""
    ];

    ""
};

private _resolveCandidate = {
    params [
        ["_candidate","",[""]]
    ];

    _candidate = toLower _candidate;

    if (_candidate find _prefix != 0) exitWith {
        ""
    };

    private _pairIndex = _pairs findIf {
        _candidate in [
            _x select 1,
            _x select 2
        ]
    };

    if (_pairIndex < 0) exitWith {
        ""
    };

    private _pair = _pairs select _pairIndex;
    private _radioA = _pair select 1;
    private _radioB = _pair select 2;

    private _selectedLine = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;

    if !(_selectedLine in [0,1]) then {
        _selectedLine = 0;
    };

    [
        _radioA,
        _radioB
    ] select _selectedLine
};

private _guiRadioValue = uiNamespace getVariable [
    "UKSF_PRC163_guiRadio",
    ""
];

private _activeRadioValue = missionNamespace getVariable [
    "UKSF_PRC163_activeRadio",
    ""
];

private _currentRadioValue = [] call acre_api_fnc_getCurrentRadio;

private _guiRadio = if (_guiRadioValue isEqualType "") then {
    _guiRadioValue
} else {
    ""
};

private _activeRadio = if (_activeRadioValue isEqualType "") then {
    _activeRadioValue
} else {
    ""
};

private _currentRadio = if (_currentRadioValue isEqualType "") then {
    _currentRadioValue
} else {
    ""
};

private _guiTarget = [
    _guiRadio
] call _resolveCandidate;

private _activeTarget = [
    _activeRadio
] call _resolveCandidate;

private _currentTarget = [
    _currentRadio
] call _resolveCandidate;

private _targetRadio = "";

if !(_guiTarget isEqualTo "") then {
    _targetRadio = if !(_activeTarget isEqualTo "") then {
        _activeTarget
    } else {
        _guiTarget
    };
} else {
    if !(_currentTarget isEqualTo "") then {
        _targetRadio = _currentTarget;
    } else {
        if !(_activeTarget isEqualTo "") then {
            _targetRadio = _activeTarget;
        } else {
            private _firstPair = _pairs select 0;
            private _radioA = _firstPair select 1;
            private _radioB = _firstPair select 2;

            private _selectedLine = [
                _radioA,
                "getState",
                "prc163SelectedLine"
            ] call acre_sys_data_fnc_dataEvent;

            if !(_selectedLine in [0,1]) then {
                _selectedLine = 0;
            };

            _targetRadio = [
                _radioA,
                _radioB
            ] select _selectedLine;
        };
    };
};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _targetRadio
];

if !(_guiTarget isEqualTo "") then {
    uiNamespace setVariable [
        "UKSF_PRC163_guiRadio",
        _targetRadio
    ];
};

_targetRadio
