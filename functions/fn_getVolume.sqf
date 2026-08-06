params [
    ["_radioId","",[""]]
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    _this call acre_sys_prc152_fnc_getVolume
};

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _radioA = "";
private _radioB = "";
private _line = -1;

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
        _line = 0;
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
                _line = 1;
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
                _line = 1;
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
        {_radioB find _prefix != 0} ||
        {!(_line in [0,1])}
    ) then {
        _radioA = "";
        _radioB = "";
        _line = -1;
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
                _line = if (
                    (_sourceNumber mod 2) isEqualTo 1
                ) then {
                    0
                } else {
                    1
                };
            };
        };
    };
};

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""} ||
    {!(_line in [0,1])} ||
    {!(
        [
            _radioA,
            _radioB,
            player
        ] call UKSF_PRC163_fnc_isPairHealthy
    )}
) exitWith {
    _this call acre_sys_prc152_fnc_getVolume
};

private _stateName = [
    "prc163VolumeA",
    "prc163VolumeB"
] select _line;

private _volume = [
    _radioA,
    "getState",
    _stateName
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_volume" ||
    {!(_volume isEqualType 0)}
) exitWith {
    _this call acre_sys_prc152_fnc_getVolume
};

_volume = (
    (_volume max 0) min 1
);

_volume ^ 3
