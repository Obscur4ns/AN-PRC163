params [
    ["_radioId","",[""]],
    ["_record",[],[[]]]
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
    false
};

private _slot = [
    _radioA
] call UKSF_PRC163_fnc_getBatterySlot;

if (_slot < 1) exitWith {
    false
};

private _installed = _record param [
    0,
    1,
    [0]
];

private _serial = _record param [
    1,
    "",
    [""]
];

private _charge = _record param [
    2,
    1,
    [0]
];

private _health = _record param [
    3,
    1,
    [0]
];

_installed = if (_installed isEqualTo 0) then {
    0
} else {
    1
};

_charge = (
    (_charge max 0) min 1
);

_health = (
    (_health max 0) min 1
);

if (_installed isEqualTo 0) then {
    _serial = "";
    _charge = 0;
};

if (
    _serial isEqualTo "" &&
    {_installed isEqualTo 1}
) then {
    private _uid = getPlayerUID player;

    if (_uid isEqualTo "") then {
        _uid = profileName;
    };

    private _slotText = str _slot;

    while {
        count _slotText < 3
    } do {
        _slotText = "0" + _slotText;
    };

    _serial = format [
        "BAT-%1-%2",
        _uid,
        _slotText
    ];
};

{
    [
        _x,
        "setState",
        [
            "prc163BatterySlot",
            _slot
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryInstalled",
            _installed
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatterySerial",
            _serial
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryCharge",
            _charge
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
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryCriticalWarned",
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryInitialized",
            true
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

true
