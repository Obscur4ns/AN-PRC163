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

private _nativeMatch = [
    _transmittingRadio,
    _receivingRadio
] call _nativeFunction;

if (_nativeMatch isEqualTo true) exitWith {
    true
};

private _prefix = "acre_prc163_id_";

if (_receivingRadio find _prefix != 0) exitWith {
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
        _receivingRadio,
        []
    ];

    if (_entry isNotEqualTo []) then {
        _radioA = _receivingRadio;
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
            ) isEqualTo _receivingRadio
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

private _dualWatch = [
    _radioA,
    "getState",
    "prc163DualWatch"
] call acre_sys_data_fnc_dataEvent;

if !(_dualWatch isEqualTo 1) exitWith {
    false
};

private _transmitData = [
    _transmittingRadio,
    "getCurrentChannelData"
] call acre_sys_data_fnc_dataEvent;

if !(_transmitData isEqualType locationNull) exitWith {
    false
};

private _transmitMode = _transmitData getVariable [
    "mode",
    ""
];

private _transmitFrequency = _transmitData getVariable [
    "frequencyTX",
    -1
];

if (
    !(_transmitMode in [
        "singleChannel",
        "singleChannelPRR"
    ]) ||
    {_transmitFrequency < 0}
) exitWith {
    false
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

if (isNil "_channelA") then {
    _channelA = 0;
};

if (isNil "_channelB") then {
    _channelB = 1;
};

private _lineData = [
    [
        _radioA,
        _channelA
    ],
    [
        _radioB,
        _channelB
    ]
];

private _matchingIndex = _lineData findIf {
    _x params [
        "_receiveRadio",
        "_receiveChannel"
    ];

    private _receiveData = [
        _receiveRadio,
        "getChannelData",
        _receiveChannel
    ] call acre_sys_data_fnc_dataEvent;

    if !(_receiveData isEqualType locationNull) exitWith {
        false
    };

    private _receiveMode = _receiveData getVariable [
        "mode",
        ""
    ];

    private _receiveFrequency = _receiveData getVariable [
        "frequencyRX",
        -1
    ];

    _transmitMode isEqualTo _receiveMode &&
    {
        abs (
            _transmitFrequency - _receiveFrequency
        ) < 0.0001
    }
};

_matchingIndex >= 0
