params [
    "_radioId",
    "_event",
    "_spatial",
    "_extra"
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0} ||
    {
        !(
            _spatial isEqualType 0 ||
            {_spatial isEqualType ""}
        )
    }
) exitWith {
    false
};

private _spatialValue = -99;

if (_spatial isEqualType 0) then {
    if (_spatial in [-1,0,1]) then {
        _spatialValue = _spatial;
    };
} else {
    switch (toUpper _spatial) do {
        case "LEFT": {
            _spatialValue = -1;
        };

        case "RIGHT": {
            _spatialValue = 1;
        };

        case "CENTER";
        case "CENTRE";
        case "BOTH": {
            _spatialValue = 0;
        };
    };
};

if !(_spatialValue in [-1,0,1]) exitWith {
    false
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

    private _gearRadios = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (
        !(_radioA in _gearRadios) ||
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
    _this call acre_sys_prc152_fnc_setSpatial
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
        false
    };
};

private _targetRadioId = [
    _radioA,
    _radioB
] select _line;

private _stateName = [
    "prc163SpatialA",
    "prc163SpatialB"
] select _line;

[
    _targetRadioId,
    "",
    _spatialValue,
    _extra
] call acre_sys_prc152_fnc_setSpatial;

private _actualSpatial = [
    _targetRadioId,
    "getState",
    "ACRE_INTERNAL_RADIOSPATIALIZATION"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_actualSpatial" ||
    {!(_actualSpatial isEqualType 0)} ||
    {!(_actualSpatial in [-1,0,1])} ||
    {!(_actualSpatial isEqualTo _spatialValue)}
) exitWith {
    false
};

{
    [
        _x,
        "setState",
        [
            _stateName,
            _spatialValue
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163SelectedLine",
            _line
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

true
