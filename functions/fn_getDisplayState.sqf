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

private _readRadioState = {
    params [
        "_targetRadio",
        "_name",
        "_default"
    ];

    private _value = [
        _targetRadio,
        "getState",
        _name
    ] call acre_sys_data_fnc_dataEvent;

    if (isNil "_value") then {
        _default
    } else {
        _value
    }
};

private _getSpatialText = {
    params ["_spatial"];

    switch (_spatial) do {
        case -1: {
            "LEFT"
        };

        case 1: {
            "RIGHT"
        };

        default {
            "BOTH"
        };
    }
};


private _getTxPowerText = {
    params ["_power"];

    switch (_power) do {
        case 250: {
            "0.25 W"
        };

        case 500: {
            "0.5 W"
        };

        case 1000: {
            "1 W"
        };

        case 2500: {
            "2.5 W"
        };

        case 5000: {
            "5 W"
        };

        default {
            if (_power < 0) then {
                "---"
            } else {
                format [
                    "%1 mW",
                    _power
                ]
            }
        };
    }
};

private _normalisePower = {
    params ["_value"];

    if (
        _value isEqualTo 1 ||
        {_value isEqualTo true}
    ) then {
        1
    } else {
        0
    }
};

private _powerA = [
    _radioA,
    "getOnOffState"
] call acre_sys_data_fnc_dataEvent;

private _powerB = [
    _radioB,
    "getOnOffState"
] call acre_sys_data_fnc_dataEvent;

if (isNil "_powerA") then {
    _powerA = 1;
};

if (isNil "_powerB") then {
    _powerB = _powerA;
};

_powerA = [_powerA] call _normalisePower;
_powerB = [_powerB] call _normalisePower;

private _power = if (
    _powerA isEqualTo 1 ||
    {_powerB isEqualTo 1}
) then {
    1
} else {
    0
};

private _physicalSlot = [
    _radioA,
    player
] call UKSF_PRC163_fnc_getBatterySlot;

private _batteryRecord = [
    _radioA,
    player
] call UKSF_PRC163_fnc_getBatteryRecord;

private _batteryInstalled = 0;
private _batterySerial = "";
private _batteryCharge = 0;
private _batteryHealth = 1;

if ((count _batteryRecord) isEqualTo 5) then {
    _physicalSlot = _batteryRecord param [
        0,
        _physicalSlot,
        [0]
    ];

    _batteryInstalled = _batteryRecord param [
        1,
        0,
        [0]
    ];

    _batterySerial = _batteryRecord param [
        2,
        "",
        [""]
    ];

    _batteryCharge = _batteryRecord param [
        3,
        0,
        [0]
    ];

    _batteryHealth = _batteryRecord param [
        4,
        1,
        [0]
    ];
};

_batteryInstalled = if (
    _batteryInstalled isEqualTo 0
) then {
    0
} else {
    1
};

_batteryCharge = (
    (_batteryCharge max 0) min 1
);

_batteryHealth = (
    (_batteryHealth max 0) min 1
);

if (_batteryInstalled isEqualTo 0) then {
    _batterySerial = "";
    _batteryCharge = 0;
};

private _batteryChargePercent = round (
    _batteryCharge * 100
);

private _batteryHealthPercent = round (
    _batteryHealth * 100
);

private _batteryUsable = (
    _batteryInstalled isEqualTo 1 &&
    {_batteryCharge > 0} &&
    {_batteryHealth > 0}
);

private _lowThreshold = missionNamespace getVariable [
    "UKSF_PRC163_BatteryLowThreshold",
    0.1
];

private _criticalThreshold = missionNamespace getVariable [
    "UKSF_PRC163_BatteryCriticalThreshold",
    0.05
];

_lowThreshold = (
    (_lowThreshold max 0) min 1
);

_criticalThreshold = (
    (_criticalThreshold max 0) min _lowThreshold
);

private _batteryStatus = if (
    _batteryInstalled isEqualTo 0
) then {
    "NO BATTERY"
} else {
    if (_batteryHealth <= 0) then {
        "UNSERVICEABLE"
    } else {
        if (_batteryCharge <= 0) then {
            "EMPTY"
        } else {
            if (_batteryCharge <= _criticalThreshold) then {
                "CRITICAL"
            } else {
                if (_batteryCharge <= _lowThreshold) then {
                    "LOW"
                } else {
                    "NORMAL"
                }
            }
        }
    }
};

private _batteryText = if (
    _batteryInstalled isEqualTo 0
) then {
    "NO BAT"
} else {
    format [
        "BAT %1%2",
        _batteryChargePercent,
        "%"
    ]
};

private _selectedLine = [
    "prc163SelectedLine",
    0
] call _readAnchorState;

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

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

if (isNil "_channelsA") then {
    _channelsA = [];
};

if (isNil "_channelsB") then {
    _channelsB = [];
};

private _presetCountA = (
    count _channelsA
) min 99;

private _presetCountB = (
    count _channelsB
) min 99;

private _channelA = [
    "prc163ChannelA",
    0
] call _readAnchorState;

private _channelB = [
    "prc163ChannelB",
    1
] call _readAnchorState;

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
    _channelB = 0;
};

_channelA = floor _channelA;
_channelB = floor _channelB;

private _channelDataA = [
    _radioA,
    "getChannelData",
    _channelA
] call acre_sys_data_fnc_dataEvent;

private _channelDataB = [
    _radioB,
    "getChannelData",
    _channelB
] call acre_sys_data_fnc_dataEvent;

private _frequencyA = if (
    isNil "_channelDataA"
) then {
    -1
} else {
    _channelDataA getVariable [
        "frequencyRX",
        -1
    ]
};

private _frequencyB = if (
    isNil "_channelDataB"
) then {
    -1
} else {
    _channelDataB getVariable [
        "frequencyRX",
        -1
    ]
};

private _frequencyAText = if (
    _frequencyA < 0
) then {
    "---.---"
} else {
    format [
        "%1",
        _frequencyA toFixed 3
    ]
};

private _frequencyBText = if (
    _frequencyB < 0
) then {
    "---.---"
} else {
    format [
        "%1",
        _frequencyB toFixed 3
    ]
};


private _txPowerA = [
    _radioA,
    0
] call UKSF_PRC163_fnc_getTxPower;

private _txPowerB = [
    _radioB,
    1
] call UKSF_PRC163_fnc_getTxPower;

private _txPowerAText = [
    _txPowerA
] call _getTxPowerText;

private _txPowerBText = [
    _txPowerB
] call _getTxPowerText;

private _spatialA = [
    "prc163SpatialA",
    0
] call _readAnchorState;

private _spatialB = [
    "prc163SpatialB",
    0
] call _readAnchorState;

private _volumeA = [
    "prc163VolumeA",
    1
] call _readAnchorState;

private _volumeB = [
    "prc163VolumeB",
    1
] call _readAnchorState;

_volumeA = (
    (_volumeA max 0) min 1
);

_volumeB = (
    (_volumeB max 0) min 1
);

private _receivingA = [
    "prc163ReceivingA",
    0
] call _readAnchorState;

private _receivingB = [
    "prc163ReceivingB",
    0
] call _readAnchorState;

private _transmittingA = [
    "prc163TransmittingA",
    0
] call _readAnchorState;

private _transmittingB = [
    "prc163TransmittingB",
    0
] call _readAnchorState;

private _dualWatch = [
    "prc163DualWatch",
    1
] call _readAnchorState;

if !(_dualWatch in [0,1]) then {
    _dualWatch = 1;
};

private _pttDownA = [
    _radioA,
    "prc163PTTDown",
    0
] call _readRadioState;

private _pttDownB = [
    _radioB,
    "prc163PTTDown",
    0
] call _readRadioState;

private _pttDown = if (
    _pttDownA isEqualTo 1 ||
    {_pttDownB isEqualTo 1}
) then {
    1
} else {
    0
};

private _selectedChannel = [
    _channelA,
    _channelB
] select _selectedLine;

private _selectedFrequency = [
    _frequencyA,
    _frequencyB
] select _selectedLine;

private _selectedFrequencyText = [
    _frequencyAText,
    _frequencyBText
] select _selectedLine;


private _selectedTxPower = [
    _txPowerA,
    _txPowerB
] select _selectedLine;

private _selectedTxPowerText = [
    _txPowerAText,
    _txPowerBText
] select _selectedLine;

private _selectedSpatial = [
    _spatialA,
    _spatialB
] select _selectedLine;

private _selectedVolume = [
    _volumeA,
    _volumeB
] select _selectedLine;

private _selectedReceiving = [
    _receivingA,
    _receivingB
] select _selectedLine;

private _selectedTransmitting = [
    _transmittingA,
    _transmittingB
] select _selectedLine;

private _state = createHashMap;

_state set [
    "radioId",
    _sourceRadioId
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
    "power",
    _power
];

_state set [
    "powerA",
    _powerA
];

_state set [
    "powerB",
    _powerB
];

_state set [
    "powerText",
    if (_power isEqualTo 1) then {
        "ON"
    } else {
        "OFF"
    }
];

_state set [
    "batteryInstalled",
    _batteryInstalled
];

_state set [
    "batterySerial",
    _batterySerial
];

_state set [
    "batteryCharge",
    _batteryCharge
];

_state set [
    "batteryChargePercent",
    _batteryChargePercent
];

_state set [
    "batteryHealth",
    _batteryHealth
];

_state set [
    "batteryHealthPercent",
    _batteryHealthPercent
];

_state set [
    "batteryUsable",
    _batteryUsable
];

_state set [
    "batteryStatus",
    _batteryStatus
];

_state set [
    "batteryText",
    _batteryText
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
    "channelA",
    _channelA
];

_state set [
    "channelB",
    _channelB
];

_state set [
    "channelADisplay",
    _channelA + 1
];

_state set [
    "channelBDisplay",
    _channelB + 1
];

_state set [
    "presetCountA",
    _presetCountA
];

_state set [
    "presetCountB",
    _presetCountB
];

_state set [
    "frequencyA",
    _frequencyA
];

_state set [
    "frequencyB",
    _frequencyB
];

_state set [
    "frequencyAText",
    _frequencyAText
];

_state set [
    "frequencyBText",
    _frequencyBText
];


_state set [
    "txPowerA",
    _txPowerA
];

_state set [
    "txPowerB",
    _txPowerB
];

_state set [
    "txPowerAText",
    _txPowerAText
];

_state set [
    "txPowerBText",
    _txPowerBText
];

_state set [
    "spatialA",
    _spatialA
];

_state set [
    "spatialB",
    _spatialB
];

_state set [
    "spatialAText",
    [_spatialA] call _getSpatialText
];

_state set [
    "spatialBText",
    [_spatialB] call _getSpatialText
];

_state set [
    "volumeA",
    _volumeA
];

_state set [
    "volumeB",
    _volumeB
];

_state set [
    "volumeAPercent",
    round (_volumeA * 100)
];

_state set [
    "volumeBPercent",
    round (_volumeB * 100)
];

_state set [
    "dualWatch",
    _dualWatch
];

_state set [
    "modeText",
    if (_dualWatch isEqualTo 1) then {
        "DUAL"
    } else {
        "SINGLE"
    }
];

_state set [
    "pttDown",
    _pttDown
];

_state set [
    "receivingA",
    _receivingA
];

_state set [
    "receivingB",
    _receivingB
];

_state set [
    "transmittingA",
    _transmittingA
];

_state set [
    "transmittingB",
    _transmittingB
];

_state set [
    "selectedChannel",
    _selectedChannel
];

_state set [
    "selectedChannelDisplay",
    _selectedChannel + 1
];

_state set [
    "selectedFrequency",
    _selectedFrequency
];

_state set [
    "selectedFrequencyText",
    _selectedFrequencyText
];


_state set [
    "selectedTxPower",
    _selectedTxPower
];

_state set [
    "selectedTxPowerText",
    _selectedTxPowerText
];

_state set [
    "selectedSpatial",
    _selectedSpatial
];

_state set [
    "selectedSpatialText",
    [_selectedSpatial] call _getSpatialText
];

_state set [
    "selectedVolume",
    _selectedVolume
];

_state set [
    "selectedVolumePercent",
    round (_selectedVolume * 100)
];

_state set [
    "selectedReceiving",
    _selectedReceiving
];

_state set [
    "selectedTransmitting",
    _selectedTransmitting
];

_state