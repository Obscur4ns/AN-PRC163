params [
    ["_radioId","",[""]],
    ["_txId","",[""]]
];

if (
    _radioId isEqualTo "" ||
    {_txId isEqualTo ""}
) exitWith {
    []
};

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (_sourceRadioId find _prefix != 0) exitWith {
    []
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
    []
};

private _channelA = [
    _radioA,
    "getState",
    "prc163ChannelA"
] call acre_sys_data_fnc_dataEvent;

private _channelB = [
    _radioA,
    "getState",
    "prc163ChannelB"
] call acre_sys_data_fnc_dataEvent;

private _txData = [
    _txId,
    "getCurrentChannelData"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channelA" ||
    {isNil "_channelB"} ||
    {isNil "_txData"}
) exitWith {
    []
};

private _matches = [];
private _debug = [];
private _lineRadios = [
    _radioA,
    _radioB
];

{
    private _line = _forEachIndex;
    private _rxRadio = _lineRadios select _line;

    private _rxData = [
        _rxRadio,
        "getChannelData",
        _x
    ] call acre_sys_data_fnc_dataEvent;

    if (!isNil "_rxData") then {
        private _rxFrequency = _rxData getVariable [
            "frequencyRX",
            -1
        ];

        private _txFrequency = _txData getVariable [
            "frequencyTX",
            -2
        ];

        private _rxModulation = _rxData getVariable [
            "modulation",
            ""
        ];

        private _txModulation = _txData getVariable [
            "modulation",
            ""
        ];

        private _rxEncryption = _rxData getVariable [
            "encryption",
            -1
        ];

        private _txEncryption = _txData getVariable [
            "encryption",
            -2
        ];

        private _frequencyMatch = abs (
            _rxFrequency - _txFrequency
        ) < 0.0001;

        private _modulationMatch = (
            _rxModulation isEqualTo _txModulation
        );

        private _encryptionMatch = (
            _rxEncryption isEqualTo _txEncryption
        );

        private _modeMatch = false;

        if (
            _frequencyMatch &&
            {_modulationMatch} &&
            {_encryptionMatch}
        ) then {
            if (_rxEncryption isEqualTo 1) then {
                private _tekMatch = (
                    _rxData getVariable [
                        "TEK",
                        -1
                    ]
                ) isEqualTo (
                    _txData getVariable [
                        "TEK",
                        -2
                    ]
                );

                private _rateMatch = (
                    _rxData getVariable [
                        "trafficRate",
                        -1
                    ]
                ) isEqualTo (
                    _txData getVariable [
                        "trafficRate",
                        -2
                    ]
                );

                _modeMatch = (
                    _tekMatch &&
                    _rateMatch
                );
            } else {
                switch (_rxModulation) do {
                    case "FM";
                    case "NB": {
                        private _rxTone = _rxData getVariable [
                            "CTCSSRx",
                            0
                        ];

                        private _txTone = _txData getVariable [
                            "CTCSSTx",
                            -1
                        ];

                        _modeMatch = (
                            _rxTone isEqualTo 0 ||
                            {_rxTone isEqualTo _txTone}
                        );
                    };

                    case "AM": {
                        _modeMatch = true;
                    };

                    default {
                        _modeMatch = false;
                    };
                };
            };
        };

        _debug pushBack [
            _line,
            _x,
            _rxFrequency,
            _txFrequency,
            _frequencyMatch,
            _modulationMatch,
            _encryptionMatch,
            _modeMatch
        ];

        if (_modeMatch) then {
            _matches pushBack _line;
        };
    } else {
        _debug pushBack [
            _line,
            _x,
            "NO_RX_DATA"
        ];
    };
} forEach [
    _channelA,
    _channelB
];

missionNamespace setVariable [
    "UKSF_PRC163_lastMatchDebug",
    _debug
];

_matches
