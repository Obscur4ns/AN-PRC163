params [
    ["_radioId","",[""]],
    ["_unit",objNull,[objNull]],
    ["_showNotification",true,[false]]
];

if (isNull _unit) then {
    _unit = player;
};

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    isNull _unit ||
    {_sourceRadioId isEqualTo ""} ||
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

    private _carriedRadios = (
        [_unit] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (
        !(_radioA in _carriedRadios) ||
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

    if (_number >= 1) then {
        private _radioANumber = if (
            (_number mod 2) isEqualTo 1
        ) then {
            _number
        } else {
            _number - 1
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

        private _carriedRadios = (
            [_unit] call acre_sys_core_fnc_getGear
        ) apply {
            toLower _x
        };

        if (
            _candidateA in _carriedRadios &&
            {_candidateB in _carriedRadios}
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
    false
};

private _pairRadios = [
    _radioA,
    _radioB
];

private _slot = [
    _radioA,
    _unit
] call UKSF_PRC163_fnc_getBatterySlot;

if (_slot < 1) exitWith {
    false
};

private _batteryClass = "UKSF_PRC163_Battery";

if !(_batteryClass in items _unit) exitWith {
    if (_showNotification) then {
        [
            format [
                "<t align='center'>AN/PRC-163 %1<br/>NO SPARE BATTERY</t>",
                _slot
            ],
            1.5,
            player,
            10
        ] call UKSF_PRC163_fnc_notifyStatus;
    };

    false
};

private _rememberedPTT = toLower (
    missionNamespace getVariable [
        "UKSF_PRC163_pttRadio",
        ""
    ]
);

private _pairPTTDown = _pairRadios findIf {
    private _pttDown = [
        _x,
        "getState",
        "prc163PTTDown"
    ] call acre_sys_data_fnc_dataEvent;

    _pttDown isEqualTo 1
};

if (
    _rememberedPTT in _pairRadios ||
    {_pairPTTDown >= 0}
) then {
    private _releaseRadio = if (
        _rememberedPTT in _pairRadios
    ) then {
        _rememberedPTT
    } else {
        _pairRadios select _pairPTTDown
    };

    [
        _releaseRadio
    ] call UKSF_PRC163_fnc_handlePTTUp;
};

missionNamespace setVariable [
    "UKSF_PRC163_pttHeld",
    false
];

missionNamespace setVariable [
    "UKSF_PRC163_pttLine",
    -1
];

{
    private _pairRadio = _x;

    [
        _pairRadio,
        "setOnOffState",
        0
    ] call acre_sys_data_fnc_dataEvent;

    {
        [
            _pairRadio,
            "setState",
            [
                _x,
                0
            ]
        ] call acre_sys_data_fnc_dataEvent;
    } forEach [
        "prc163PTTDown",
        "prc163ReceivingA",
        "prc163ReceivingB",
        "prc163TransmittingA",
        "prc163TransmittingB"
    ];
} forEach _pairRadios;

private _batteryCountBefore = {
    _x isEqualTo _batteryClass
} count items _unit;

_unit removeItem _batteryClass;

private _batteryCountAfter = {
    _x isEqualTo _batteryClass
} count items _unit;

if (_batteryCountAfter >= _batteryCountBefore) exitWith {
    if (_showNotification) then {
        [
            format [
                "<t align='center'>AN/PRC-163 %1<br/>BATTERY REPLACEMENT FAILED</t>",
                _slot
            ],
            1.5,
            player,
            10
        ] call UKSF_PRC163_fnc_notifyStatus;
    };

    false
};

private _uid = getPlayerUID _unit;

if (_uid isEqualTo "") then {
    _uid = profileName;
};

private _counter = (
    missionNamespace getVariable [
        "UKSF_PRC163_batterySerialCounter",
        0
    ]
) + 1;

missionNamespace setVariable [
    "UKSF_PRC163_batterySerialCounter",
    _counter
];

private _slotText = str _slot;

while {
    count _slotText < 3
} do {
    _slotText = "0" + _slotText;
};

private _timeWidths = [
    4,
    2,
    2,
    2,
    2,
    2,
    3
];

private _timeText = "";

{
    private _valueText = str floor _x;
    private _width = _timeWidths select _forEachIndex;

    while {
        count _valueText < _width
    } do {
        _valueText = "0" + _valueText;
    };

    _timeText = _timeText + _valueText;
} forEach systemTime;

private _serial = format [
    "BAT-%1-%2-%3-%4",
    _uid,
    _slotText,
    _timeText,
    _counter
];

private _initialized = [
    _radioA,
    [
        1,
        _serial,
        1,
        1
    ]
] call UKSF_PRC163_fnc_initializeBatteryState;

if (!_initialized) exitWith {
    _unit addItem _batteryClass;

    if (_showNotification) then {
        [
            format [
                "<t align='center'>AN/PRC-163 %1<br/>BATTERY REPLACEMENT FAILED</t>",
                _slot
            ],
            1.5,
            player,
            10
        ] call UKSF_PRC163_fnc_notifyStatus;
    };

    false
};

{
    [
        _x,
        "setState",
        [
            "prc163BatteryShutdownWarned",
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach _pairRadios;

[
    true
] call UKSF_PRC163_fnc_saveBatteryRecords;

if (_showNotification) then {
    [
        format [
            "<t align='center'>AN/PRC-163 %1<br/>BATTERY REPLACED: 100%2</t>",
            _slot,
            "%"
        ],
        1.5,
        player,
        10
    ] call UKSF_PRC163_fnc_notifyStatus;
};

true
