params [
    ["_radioId","",[""]],
    ["_line",-1,[0]]
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
    -1
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
    -1
};

if !(
    [
        _radioA,
        _radioB,
        player
    ] call UKSF_PRC163_fnc_isPairHealthy
) exitWith {
    -1
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
        -1
    };
};

if (_line isEqualTo -1) then {
    _line = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;
};

if !(_line in [0,1]) exitWith {
    -1
};

private _targetRadio = [
    _radioA,
    _radioB
] select _line;

private _channelStateName = [
    "prc163ChannelA",
    "prc163ChannelB"
] select _line;

private _channel = [
    _radioA,
    "getState",
    _channelStateName
] call acre_sys_data_fnc_dataEvent;

private _channels = [
    _targetRadio,
    "getState",
    "channels"
] call acre_sys_data_fnc_dataEvent;

if (isNil "_channels") then {
    _channels = [];
};

private _presetCount = (
    count _channels
) min 99;

if (
    !(_channel isEqualType 0) ||
    {_channel < 0} ||
    {_channel >= _presetCount}
) then {
    _channel = [
        _targetRadio,
        "getCurrentChannel"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    isNil "_channel" ||
    {!(_channel isEqualType 0)} ||
    {_channel < 0} ||
    {_channel >= _presetCount}
) exitWith {
    -1
};

_channel = floor _channel;

private _channelData = [
    _targetRadio,
    "getChannelData",
    _channel
] call acre_sys_data_fnc_dataEvent;

if (isNil "_channelData") exitWith {
    -1
};

private _power = _channelData getVariable [
    "power",
    -1
];

if (
    !(_power isEqualType 0) ||
    {_power < 0}
) exitWith {
    -1
};

_power
