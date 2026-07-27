params [
    ["_radioId","",[""]],
    "_event",
    ["_requestedState",0,[0,false]],
    "_radioData"
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

    if !(_entry isEqualTo []) then {
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

    private _radioIds = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (
        !(_radioA in _radioIds) ||
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
    false
};

_requestedState = if (
    _requestedState isEqualTo 1 ||
    {_requestedState isEqualTo true}
) then {
    1
} else {
    0
};

private _guardName = format [
    "UKSF_PRC163_powerSync_%1",
    _radioA
];

if (
    missionNamespace getVariable [
        _guardName,
        false
    ]
) exitWith {
    private _baseArguments = +_this;

    _baseArguments set [
        2,
        _requestedState
    ];

    _baseArguments call acre_sys_prc152_fnc_setOnOffState;

    true
};

private _applyPairPower = {
    params ["_state"];

    missionNamespace setVariable [
        _guardName,
        true
    ];

    private _successA = [
        _radioA,
        "setOnOffState",
        _state
    ] call acre_sys_data_fnc_dataEvent;

    private _successB = [
        _radioB,
        "setOnOffState",
        _state
    ] call acre_sys_data_fnc_dataEvent;

    missionNamespace setVariable [
        _guardName,
        false
    ];

    (
        !(_successA isEqualTo false) &&
        {!(_successB isEqualTo false)}
    )
};

if (
    _requestedState isEqualTo 1 &&
    {
        !(
            [
                _radioA
            ] call UKSF_PRC163_fnc_hasUsableBattery
        )
    }
) exitWith {
    [
        0
    ] call _applyPairPower;

    private _physicalSlot = [
        _radioA
    ] call UKSF_PRC163_fnc_getBatterySlot;

    private _radioName = if (
        _physicalSlot >= 1
    ) then {
        format [
            "AN/PRC-163 %1",
            _physicalSlot
        ]
    } else {
        "AN/PRC-163"
    };

    [
        format [
            "%1 | BATTERY UNAVAILABLE",
            _radioName
        ],
        1.1,
        [
            1,
            0.35,
            0.2,
            1
        ],
        true
    ] call CBA_fnc_notify;

    false
};

[
    _requestedState
] call _applyPairPower
