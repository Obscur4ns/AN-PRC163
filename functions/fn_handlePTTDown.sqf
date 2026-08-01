params [
    ["_radioId","",[""]]
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    false
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

    if (_entry isNotEqualTo []) then {
        _radioA = _sourceRadioId;
    } else {
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

    _radioA = toLower _radioA;
    _radioB = toLower (
        _entry param [
            0,
            "",
            [""]
        ]
    );

    private _gearRadios = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (
        !(_radioA in _gearRadios) ||
        {_radioA isEqualTo _radioB} ||
        {_radioB find _prefix != 0}
    ) then {
        _radioA = "";
        _radioB = "";
    };
} else {
    private _radioEntries = (
        ([player] call acre_sys_core_fnc_getGear) select {
            toLower _x find _prefix isEqualTo 0
        }
    ) apply {
        private _id = toLower _x;
        private _number = parseNumber (
            _id select [
                count _prefix
            ]
        );

        [
            _number,
            _id
        ]
    };

    private _sourceIndex = _radioEntries findIf {
        (_x select 1) isEqualTo _sourceRadioId
    };

    if (_sourceIndex >= 0) then {
        private _sourceNumber = (
            _radioEntries select _sourceIndex
        ) select 0;

        if (_sourceNumber >= 1) then {
            private _radioANumber = if (
                (_sourceNumber mod 2) isEqualTo 1
            ) then {
                _sourceNumber
            } else {
                _sourceNumber - 1
            };

            private _radioAIndex = _radioEntries findIf {
                (_x select 0) isEqualTo _radioANumber
            };

            private _radioBIndex = _radioEntries findIf {
                (_x select 0) isEqualTo (
                    _radioANumber + 1
                )
            };

            if (
                _radioAIndex >= 0 &&
                {_radioBIndex >= 0}
            ) then {
                _radioA = (
                    _radioEntries select _radioAIndex
                ) select 1;

                _radioB = (
                    _radioEntries select _radioBIndex
                ) select 1;
            };
        };
    };
};

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""}
) exitWith {
    false
};

private _pairRadios = [
    _radioA,
    _radioB
];

private _selectedLine = [
    _radioA,
    "getState",
    "prc163SelectedLine"
] call acre_sys_data_fnc_dataEvent;

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

private _pttLine = [
    _sourceRadioId,
    "getState",
    "prc163EndpointLine"
] call acre_sys_data_fnc_dataEvent;

if !(_pttLine in [0,1]) then {
    _pttLine = _pairRadios find _sourceRadioId;
};

if !(_pttLine in [0,1]) then {
    _pttLine = _selectedLine;
};

private _targetRadioId = _pairRadios select _pttLine;

private _channelState = [
    "prc163ChannelA",
    "prc163ChannelB"
] select _pttLine;

private _selectedChannel = [
    _radioA,
    "getState",
    _channelState
] call acre_sys_data_fnc_dataEvent;

if (isNil "_selectedChannel") then {
    _selectedChannel = [
        _targetRadioId,
        "getCurrentChannel"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    !(_selectedChannel isEqualType 0) ||
    {_selectedChannel < 0}
) exitWith {
    false
};

[
    _targetRadioId,
    "setCurrentChannel",
    _selectedChannel
] call acre_sys_data_fnc_dataEvent;

private _previousCurrentRadio = [] call acre_api_fnc_getCurrentRadio;

if !(_previousCurrentRadio isEqualType "") then {
    _previousCurrentRadio = "";
};

_previousCurrentRadio = toLower _previousCurrentRadio;

private _previousActiveRadio = missionNamespace getVariable [
    "UKSF_PRC163_activeRadio",
    _previousCurrentRadio
];

if !(_previousActiveRadio isEqualType "") then {
    _previousActiveRadio = _previousCurrentRadio;
};

_previousActiveRadio = toLower _previousActiveRadio;

private _restoreCurrentRadio = {
    if !(_previousCurrentRadio isEqualTo "") then {
        [
            _previousCurrentRadio
        ] call acre_api_fnc_setCurrentRadio;
    };

    if !(_previousActiveRadio isEqualTo "") then {
        missionNamespace setVariable [
            "UKSF_PRC163_activeRadio",
            _previousActiveRadio
        ];
    };
};

private _setCurrentSuccess = [
    _targetRadioId
] call acre_api_fnc_setCurrentRadio;

if (!_setCurrentSuccess) exitWith {
    false
};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _targetRadioId
];

{
    [
        _x,
        "setState",
        [
            "prc163PTTDown",
            1
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163TransmittingA",
            if (_pttLine isEqualTo 0) then {
                1
            } else {
                0
            }
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163TransmittingB",
            if (_pttLine isEqualTo 1) then {
                1
            } else {
                0
            }
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach _pairRadios;

missionNamespace setVariable [
    "UKSF_PRC163_pttRadio",
    _targetRadioId
];

missionNamespace setVariable [
    "UKSF_PRC163_pttLine",
    _pttLine
];

private _result = [
    _targetRadioId
] call acre_sys_prc152_fnc_handlePTTDown;

if (!_result) exitWith {
    missionNamespace setVariable [
        "UKSF_PRC163_pttRadio",
        nil
    ];

    missionNamespace setVariable [
        "UKSF_PRC163_pttLine",
        -1
    ];

    {
        [
            _x,
            "setState",
            [
                "prc163PTTDown",
                0
            ]
        ] call acre_sys_data_fnc_dataEvent;

        [
            _x,
            "setState",
            [
                "prc163TransmittingA",
                0
            ]
        ] call acre_sys_data_fnc_dataEvent;

        [
            _x,
            "setState",
            [
                "prc163TransmittingB",
                0
            ]
        ] call acre_sys_data_fnc_dataEvent;
    } forEach _pairRadios;

    call _restoreCurrentRadio;

    false
};

call _restoreCurrentRadio;

true
