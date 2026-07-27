params [
    ["_radioId","",[""]],
    ["_elapsedSeconds",0,[0]]
];

private _enabled = missionNamespace getVariable [
    "UKSF_PRC163_BatteriesEnabled",
    true
];

if (!_enabled) exitWith {
    0
};

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0} ||
    {_elapsedSeconds <= 0}
) exitWith {
    0
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
    private _number = parseNumber (
        _sourceRadioId select [
            count _prefix
        ]
    );

    if (
        _number >= 1 &&
        {(_number mod 2) isEqualTo 1}
    ) then {
        private _candidateA = format [
            "%1%2",
            _prefix,
            _number
        ];

        private _candidateB = format [
            "%1%2",
            _prefix,
            _number + 1
        ];

        private _gear = (
            [player] call acre_sys_core_fnc_getGear
        ) apply {
            toLower _x
        };

        if (
            _candidateA in _gear &&
            {_candidateB in _gear}
        ) then {
            _radioA = _candidateA;
            _radioB = _candidateB;
        };
    };
};

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""}
) exitWith {
    0
};

if !(
    [
        _radioA
    ] call UKSF_PRC163_fnc_hasUsableBattery
) exitWith {
    0
};

private _powerA = [
    _radioA,
    "getOnOffState"
] call acre_sys_data_fnc_dataEvent;

private _powerB = [
    _radioB,
    "getOnOffState"
] call acre_sys_data_fnc_dataEvent;

private _poweredOn = (
    _powerA isEqualTo 1 ||
    {_powerA isEqualTo true} ||
    {_powerB isEqualTo 1} ||
    {_powerB isEqualTo true}
);

if (!_poweredOn) exitWith {
    0
};

private _chargeA = [
    _radioA,
    "getState",
    "prc163BatteryCharge"
] call acre_sys_data_fnc_dataEvent;

private _chargeB = [
    _radioB,
    "getState",
    "prc163BatteryCharge"
] call acre_sys_data_fnc_dataEvent;

private _healthA = [
    _radioA,
    "getState",
    "prc163BatteryHealth"
] call acre_sys_data_fnc_dataEvent;

private _healthB = [
    _radioB,
    "getState",
    "prc163BatteryHealth"
] call acre_sys_data_fnc_dataEvent;

if (isNil "_chargeA") then {
    _chargeA = 0;
};

if (isNil "_chargeB") then {
    _chargeB = _chargeA;
};

if (isNil "_healthA") then {
    _healthA = 1;
};

if (isNil "_healthB") then {
    _healthB = _healthA;
};

private _charge = (
    (_chargeA min _chargeB) max 0
) min 1;

private _health = (
    (_healthA min _healthB) max 0.05
) min 1;

private _baseLifeHours = missionNamespace getVariable [
    "UKSF_PRC163_BatteryLifeHours",
    12
];

private _dualWatchExtra = missionNamespace getVariable [
    "UKSF_PRC163_BatteryDualWatchExtra",
    0.25
];

private _receiveExtra = missionNamespace getVariable [
    "UKSF_PRC163_BatteryReceiveExtra",
    0.5
];

private _transmitExtra = missionNamespace getVariable [
    "UKSF_PRC163_BatteryTransmitExtra",
    5
];

private _lowThreshold = missionNamespace getVariable [
    "UKSF_PRC163_BatteryLowThreshold",
    0.1
];

private _criticalThreshold = missionNamespace getVariable [
    "UKSF_PRC163_BatteryCriticalThreshold",
    0.05
];

if (_baseLifeHours <= 0) then {
    _baseLifeHours = 12;
};

_lowThreshold = (
    (_lowThreshold max 0) min 1
);

_criticalThreshold = (
    (_criticalThreshold max 0) min _lowThreshold
);

private _multiplier = 1;

private _dualWatch = [
    _radioA,
    "getState",
    "prc163DualWatch"
] call acre_sys_data_fnc_dataEvent;

if (_dualWatch isEqualTo 1) then {
    _multiplier = _multiplier + _dualWatchExtra;
};

private _receivingA = [
    _radioA,
    "getState",
    "prc163ReceivingA"
] call acre_sys_data_fnc_dataEvent;

private _receivingB = [
    _radioA,
    "getState",
    "prc163ReceivingB"
] call acre_sys_data_fnc_dataEvent;

if (_receivingA isEqualTo 1) then {
    _multiplier = _multiplier + _receiveExtra;
};

if (_receivingB isEqualTo 1) then {
    _multiplier = _multiplier + _receiveExtra;
};

private _transmittingA = [
    _radioA,
    "getState",
    "prc163TransmittingA"
] call acre_sys_data_fnc_dataEvent;

private _transmittingB = [
    _radioA,
    "getState",
    "prc163TransmittingB"
] call acre_sys_data_fnc_dataEvent;

if (
    _transmittingA isEqualTo 1 ||
    {_transmittingB isEqualTo 1}
) then {
    _multiplier = _multiplier + _transmitExtra;
};

private _effectiveLifeSeconds = (
    _baseLifeHours *
    3600 *
    _health
);

private _drain = (
    _elapsedSeconds /
    _effectiveLifeSeconds
) * _multiplier;

private _newCharge = (
    _charge - _drain
) max 0;

private _lowWarnedA = [
    _radioA,
    "getState",
    "prc163BatteryLowWarned"
] call acre_sys_data_fnc_dataEvent;

private _lowWarnedB = [
    _radioB,
    "getState",
    "prc163BatteryLowWarned"
] call acre_sys_data_fnc_dataEvent;

private _criticalWarnedA = [
    _radioA,
    "getState",
    "prc163BatteryCriticalWarned"
] call acre_sys_data_fnc_dataEvent;

private _criticalWarnedB = [
    _radioB,
    "getState",
    "prc163BatteryCriticalWarned"
] call acre_sys_data_fnc_dataEvent;

if (isNil "_lowWarnedA") then {
    _lowWarnedA = 0;
};

if (isNil "_lowWarnedB") then {
    _lowWarnedB = 0;
};

if (isNil "_criticalWarnedA") then {
    _criticalWarnedA = 0;
};

if (isNil "_criticalWarnedB") then {
    _criticalWarnedB = 0;
};

private _lowWarned = (
    _lowWarnedA max _lowWarnedB
);

private _criticalWarned = (
    _criticalWarnedA max _criticalWarnedB
);

if (_newCharge > _lowThreshold) then {
    _lowWarned = 0;
    _criticalWarned = 0;
};

if (
    _newCharge <= _lowThreshold &&
    {_newCharge > _criticalThreshold} &&
    {_lowWarned isEqualTo 0}
) then {
    [
        "Acre_GenericBeepLow",
        [0,0,0],
        [0,0,0],
        0.7,
        false
    ] call acre_sys_sounds_fnc_playSound;

    _lowWarned = 1;
};

if (
    _newCharge <= _criticalThreshold &&
    {_newCharge > 0} &&
    {_criticalWarned isEqualTo 0}
) then {
    [
        "Acre_GenericBeepLow",
        [0,0,0],
        [0,0,0],
        0.7,
        false
    ] call acre_sys_sounds_fnc_playSound;

    [{
        [
            "Acre_GenericBeepLow",
            [0,0,0],
            [0,0,0],
            0.7,
            false
        ] call acre_sys_sounds_fnc_playSound;
    },[],0.3] call CBA_fnc_waitAndExecute;

    [{
        [
            "Acre_GenericBeepLow",
            [0,0,0],
            [0,0,0],
            0.7,
            false
        ] call acre_sys_sounds_fnc_playSound;
    },[],0.6] call CBA_fnc_waitAndExecute;

    _lowWarned = 1;
    _criticalWarned = 1;
};

{
    [
        _x,
        "setState",
        [
            "prc163BatteryCharge",
            _newCharge
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryHealth",
            _health
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryLowWarned",
            _lowWarned
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryCriticalWarned",
            _criticalWarned
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

missionNamespace setVariable [
    "UKSF_PRC163_lastBatteryDrain",
    [
        _radioA,
        _radioB,
        _elapsedSeconds,
        _multiplier,
        _drain,
        _charge,
        _newCharge
    ]
];

_drain
