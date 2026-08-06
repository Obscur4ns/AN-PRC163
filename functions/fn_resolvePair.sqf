params [
    ["_radioId","",[""]],
    ["_unit",objNull,[objNull]],
    ["_requireAvailable",true,[true]]
];

private _prefix = "acre_prc163_id_";

_radioId = toLower _radioId;

if (isNull _unit) then {
    _unit = player;
};

if (
    isNull _unit ||
    {_radioId find _prefix != 0}
) exitWith {
    [
        "",
        "",
        -1
    ]
};

private _radioA = "";
private _radioB = "";
private _line = -1;

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

if (_pilotEnabled) then {
    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _mapKeys = keys _endpointMap;
    private _entry = _endpointMap getOrDefault [
        _radioId,
        []
    ];

    if (_entry isNotEqualTo []) then {
        _radioA = _radioId;
    } else {
        private _statePrimary = [
            _radioId,
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
                ) isEqualTo _radioId
            };

            if (_primaryIndex >= 0) then {
                _radioA = toLower (
                    _mapKeys select _primaryIndex
                );

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
} else {
    private _radioIds = (
        [_unit] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (_radioId in _radioIds) then {
        private _sourceNumber = parseNumber (
            _radioId select [
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

if !(
    [
        _radioA,
        _radioB,
        _unit,
        _requireAvailable
    ] call UKSF_PRC163_fnc_isPairHealthy
) exitWith {
    [
        "",
        "",
        -1
    ]
};

_line = [
    _radioA,
    _radioB
] find _radioId;

if !(_line in [0,1]) exitWith {
    [
        "",
        "",
        -1
    ]
};

[
    _radioA,
    _radioB,
    _line
]
