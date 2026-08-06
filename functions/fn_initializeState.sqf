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
private _companionRack = "";

if (_pilotEnabled) then {
    private _gearRadios = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

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

    _companionRack = toLower (
        _entry param [
            1,
            "",
            [""]
        ]
    );

    if (
        !(_radioA in _gearRadios) ||
        {_radioA isEqualTo _radioB} ||
        {_radioB find _prefix != 0} ||
        {_companionRack isEqualTo ""}
    ) then {
        _radioA = "";
        _radioB = "";
        _companionRack = "";
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

            private _radioBNumber = _radioANumber + 1;

            private _radioAIndex = _radioEntries findIf {
                (_x select 0) isEqualTo _radioANumber
            };

            private _radioBIndex = _radioEntries findIf {
                (_x select 0) isEqualTo _radioBNumber
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

if !(
    [
        _radioA,
        _radioB,
        player
    ] call UKSF_PRC163_fnc_isPairHealthy
) exitWith {
    false
};

private _pairRadios = [
    _radioA,
    _radioB
];

private _channelsA = [
    _radioA,
    "getState",
    "channels"
] call acre_sys_data_fnc_dataEvent;

private _channelsB = [
    _radioB,
    "getState",
    "channels"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channelsA" ||
    {isNil "_channelsB"} ||
    {_channelsA isEqualTo []} ||
    {_channelsB isEqualTo []}
) exitWith {
    false
};

private _presetCountA = (
    count _channelsA
) min 99;

private _presetCountB = (
    count _channelsB
) min 99;

if (
    _presetCountA < 1 ||
    {_presetCountB < 1}
) exitWith {
    false
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

private _initialised = [
    "prc163Initialized",
    false
] call _readAnchorState;

private _defaultChannelB = if (
    _presetCountB > 1
) then {
    1
} else {
    0
};

private _channelA = if (_initialised) then {
    [
        "prc163ChannelA",
        0
    ] call _readAnchorState
} else {
    0
};

private _channelB = if (_initialised) then {
    [
        "prc163ChannelB",
        _defaultChannelB
    ] call _readAnchorState
} else {
    _defaultChannelB
};

if (
    !(_channelA isEqualType 0) ||
    {_channelA < 0} ||
    {_channelA >= _presetCountA}
) then {
    _channelA = [
        _radioA,
        "getCurrentChannel"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    !(_channelB isEqualType 0) ||
    {_channelB < 0} ||
    {_channelB >= _presetCountB}
) then {
    _channelB = [
        _radioB,
        "getCurrentChannel"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    isNil "_channelA" ||
    {!(_channelA isEqualType 0)} ||
    {_channelA < 0} ||
    {_channelA >= _presetCountA}
) then {
    _channelA = 0;
};

if (
    isNil "_channelB" ||
    {!(_channelB isEqualType 0)} ||
    {_channelB < 0} ||
    {_channelB >= _presetCountB}
) then {
    _channelB = _defaultChannelB;
};

_channelA = floor _channelA;
_channelB = floor _channelB;

private _selectedLine = if (_initialised) then {
    [
        "prc163SelectedLine",
        0
    ] call _readAnchorState
} else {
    0
};

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

private _dualWatch = if (_initialised) then {
    [
        "prc163DualWatch",
        1
    ] call _readAnchorState
} else {
    1
};

if !(_dualWatch in [0,1]) then {
    _dualWatch = 1;
};

private _spatialA = if (_initialised) then {
    [
        "prc163SpatialA",
        0
    ] call _readAnchorState
} else {
    0
};

private _spatialB = if (_initialised) then {
    [
        "prc163SpatialB",
        0
    ] call _readAnchorState
} else {
    0
};

if !(_spatialA in [-1,0,1]) then {
    _spatialA = 0;
};

if !(_spatialB in [-1,0,1]) then {
    _spatialB = 0;
};

private _volumeA = if (_initialised) then {
    [
        "prc163VolumeA",
        1
    ] call _readAnchorState
} else {
    1
};

private _volumeB = if (_initialised) then {
    [
        "prc163VolumeB",
        1
    ] call _readAnchorState
} else {
    1
};

if !(_volumeA isEqualType 0) then {
    _volumeA = 1;
};

if !(_volumeB isEqualType 0) then {
    _volumeB = 1;
};

_volumeA = (
    (_volumeA max 0) min 1
);

_volumeB = (
    (_volumeB max 0) min 1
);

private _receivingA = if (_initialised) then {
    [
        "prc163ReceivingA",
        0
    ] call _readAnchorState
} else {
    0
};

private _receivingB = if (_initialised) then {
    [
        "prc163ReceivingB",
        0
    ] call _readAnchorState
} else {
    0
};

private _transmittingA = if (_initialised) then {
    [
        "prc163TransmittingA",
        0
    ] call _readAnchorState
} else {
    0
};

private _transmittingB = if (_initialised) then {
    [
        "prc163TransmittingB",
        0
    ] call _readAnchorState
} else {
    0
};

_receivingA = if (_receivingA isEqualTo 1) then {
    1
} else {
    0
};

_receivingB = if (_receivingB isEqualTo 1) then {
    1
} else {
    0
};

_transmittingA = if (_transmittingA isEqualTo 1) then {
    1
} else {
    0
};

_transmittingB = if (_transmittingB isEqualTo 1) then {
    1
} else {
    0
};

private _hmiPage = if (_initialised) then {
    [
        "prc163HMIPage",
        "HOME"
    ] call _readAnchorState
} else {
    "HOME"
};

if (
    !(_hmiPage isEqualType "") ||
    {_hmiPage isEqualTo ""}
) then {
    _hmiPage = "HOME";
};

private _hmiCursor = if (_initialised) then {
    [
        "prc163HMICursor",
        0
    ] call _readAnchorState
} else {
    0
};

if !(_hmiCursor isEqualType 0) then {
    _hmiCursor = 0;
};

_hmiCursor = floor (
    _hmiCursor max 0
);

private _hmiInputBuffer = if (_initialised) then {
    [
        "prc163HMIInputBuffer",
        ""
    ] call _readAnchorState
} else {
    ""
};

if !(_hmiInputBuffer isEqualType "") then {
    _hmiInputBuffer = "";
};

private _hmiEditing = if (_initialised) then {
    [
        "prc163HMIEditing",
        0
    ] call _readAnchorState
} else {
    0
};

_hmiEditing = if (_hmiEditing isEqualTo 1) then {
    1
} else {
    0
};

private _sharedState = [
    ["prc163ChannelA",_channelA],
    ["prc163ChannelB",_channelB],
    ["prc163SelectedLine",_selectedLine],
    ["prc163DualWatch",_dualWatch],
    ["prc163SpatialA",_spatialA],
    ["prc163SpatialB",_spatialB],
    ["prc163VolumeA",_volumeA],
    ["prc163VolumeB",_volumeB],
    ["prc163ReceivingA",_receivingA],
    ["prc163ReceivingB",_receivingB],
    ["prc163TransmittingA",_transmittingA],
    ["prc163TransmittingB",_transmittingB],
    ["prc163HMIPage",_hmiPage],
    ["prc163HMICursor",_hmiCursor],
    ["prc163HMIInputBuffer",_hmiInputBuffer],
    ["prc163HMIEditing",_hmiEditing],
    ["prc163Initialized",true]
];

{
    private _targetRadio = _x;

    {
        [
            _targetRadio,
            "setState",
            _x
        ] call acre_sys_data_fnc_dataEvent;
    } forEach _sharedState;

    private _pttDown = [
        _targetRadio,
        "getState",
        "prc163PTTDown"
    ] call acre_sys_data_fnc_dataEvent;

    if !(_pttDown in [0,1]) then {
        [
            _targetRadio,
            "setState",
            [
                "prc163PTTDown",
                0
            ]
        ] call acre_sys_data_fnc_dataEvent;
    };
} forEach _pairRadios;

if (_pilotEnabled) then {
    [
        _radioA,
        "setState",
        [
            "prc163PrimaryRadio",
            _radioA
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioA,
        "setState",
        [
            "prc163CompanionRadio",
            _radioB
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioA,
        "setState",
        [
            "prc163CompanionRack",
            _companionRack
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioA,
        "setState",
        [
            "prc163EndpointLine",
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioB,
        "setState",
        [
            "prc163PrimaryRadio",
            _radioA
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioB,
        "setState",
        [
            "prc163CompanionRadio",
            _radioB
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioB,
        "setState",
        [
            "prc163CompanionRack",
            _companionRack
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioB,
        "setState",
        [
            "prc163EndpointLine",
            1
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioB,
        "setState",
        [
            "powerSource",
            "BAT"
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioA,
        "setState",
        [
            "volume",
            _volumeA
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioB,
        "setState",
        [
            "volume",
            _volumeB
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioA,
        "setState",
        [
            "ACRE_INTERNAL_RADIOSPATIALIZATION",
            _spatialA
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _radioB,
        "setState",
        [
            "ACRE_INTERNAL_RADIOSPATIALIZATION",
            _spatialB
        ]
    ] call acre_sys_data_fnc_dataEvent;
};

[
    _radioA,
    "setCurrentChannel",
    _channelA
] call acre_sys_data_fnc_dataEvent;

[
    _radioB,
    "setCurrentChannel",
    _channelB
] call acre_sys_data_fnc_dataEvent;

true
