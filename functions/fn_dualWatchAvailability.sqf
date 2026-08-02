params [
    ["_transmittingRadio","",[""]],
    ["_receivingRadio","",[""]]
];

_transmittingRadio = toLower _transmittingRadio;
_receivingRadio = toLower _receivingRadio;

if (
    _transmittingRadio isEqualTo "" ||
    {_receivingRadio isEqualTo ""}
) exitWith {
    false
};

private _nativeFunction = missionNamespace getVariable [
    "acre_sys_modes_fnc_sc_muting",
    {}
];

if !(_nativeFunction isEqualType {}) exitWith {
    false
};

private _prefix = "acre_prc163_id_";

if (_receivingRadio find _prefix != 0) exitWith {
    [
        _transmittingRadio,
        _receivingRadio
    ] call _nativeFunction
};

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _radioA = "";
private _radioB = "";
private _receivingLine = -1;

if (_pilotEnabled) then {
    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _mapKeys = keys _endpointMap;
    private _entry = _endpointMap getOrDefault [
        _receivingRadio,
        []
    ];

    if !(_entry isEqualTo []) then {
        _radioA = _receivingRadio;
        _receivingLine = 0;
    } else {
        private _statePrimary = [
            _receivingRadio,
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
                _receivingLine = 1;
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
                ) isEqualTo _receivingRadio
            };

            if (_primaryIndex >= 0) then {
                _radioA = _mapKeys select _primaryIndex;
                _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];
                _receivingLine = 1;
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

    private _gearRadios = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (
        !(_radioA in _gearRadios) ||
        {_radioA isEqualTo _radioB} ||
        {_radioB find _prefix != 0} ||
        {!(_receivingLine in [0,1])}
    ) then {
        _radioA = "";
        _radioB = "";
        _receivingLine = -1;
    };
} else {
    private _radioIds = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (_receivingRadio in _radioIds) then {
        private _sourceNumber = parseNumber (
            _receivingRadio select [
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
                _receivingLine = if (
                    (_sourceNumber mod 2) isEqualTo 1
                ) then {
                    0
                } else {
                    1
                };
            };
        };
    };
};

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""} ||
    {!(_receivingLine in [0,1])}
) exitWith {
    false
};

private _dualWatch = [
    _radioA,
    "getState",
    "prc163DualWatch"
] call acre_sys_data_fnc_dataEvent;

if !(_dualWatch in [0,1]) then {
    _dualWatch = 0;
};

private _selectedLine = [
    _radioA,
    "getState",
    "prc163SelectedLine"
] call acre_sys_data_fnc_dataEvent;

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

if (
    _dualWatch isEqualTo 0 &&
    {_receivingLine isNotEqualTo _selectedLine}
) exitWith {
    false
};

private _transmitData = [
    _transmittingRadio,
    "getCurrentChannelData"
] call acre_sys_data_fnc_dataEvent;

if !(_transmitData isEqualType locationNull) exitWith {
    false
};

private _channelState = [
    "prc163ChannelA",
    "prc163ChannelB"
] select _receivingLine;

private _receiveChannel = [
    _radioA,
    "getState",
    _channelState
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_receiveChannel" ||
    {!(_receiveChannel isEqualType 0)}
) then {
    _receiveChannel = _receivingLine;
};

private _receiveData = [
    _receivingRadio,
    "getChannelData",
    _receiveChannel
] call acre_sys_data_fnc_dataEvent;

if !(_receiveData isEqualType locationNull) exitWith {
    false
};

private _transmitMode = _transmitData getVariable [
    "mode",
    ""
];

private _receiveMode = _receiveData getVariable [
    "mode",
    ""
];

private _validMode = (
    _transmitMode in [
        "singleChannel",
        "singleChannelPRR"
    ]
) && {
    _transmitMode isEqualTo _receiveMode
};

if (!_validMode) exitWith {
    false
};

private _transmitFrequency = _transmitData getVariable [
    "frequencyTX",
    -1
];

private _receiveFrequency = _receiveData getVariable [
    "frequencyRX",
    -2
];

_transmitFrequency isEqualTo _receiveFrequency
