params [
    ["_radioId","",[""]]
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

private _rememberedRadioId = toLower (
    missionNamespace getVariable [
        "UKSF_PRC163_pttRadio",
        ""
    ]
);

private _targetRadioId = _rememberedRadioId;

if (
    _targetRadioId isEqualTo "" ||
    {_targetRadioId find _prefix != 0}
) then {
    _targetRadioId = _sourceRadioId;
};

private _releaseRadios = [];

private _addReleaseRadio = {
    params [
        ["_candidate","",[""]]
    ];

    private _candidateId = toLower _candidate;

    if (
        _candidateId find _prefix isEqualTo 0 &&
        {!(_candidateId in _releaseRadios)}
    ) then {
        _releaseRadios pushBack _candidateId;
    };
};

[
    _targetRadioId
] call _addReleaseRadio;

[
    _sourceRadioId
] call _addReleaseRadio;

private _radioA = "";
private _radioB = "";

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
    private _resolveCandidates = +_releaseRadios;

    {
        private _candidate = _x;
        private _entry = _endpointMap getOrDefault [
            _candidate,
            []
        ];

        if (_entry isNotEqualTo []) exitWith {
            _radioA = _candidate;
            _radioB = toLower (
                _entry param [
                    0,
                    "",
                    [""]
                ]
            );
        };

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
            ) isEqualTo _candidate
        };

        if (_primaryIndex >= 0) exitWith {
            _radioA = toLower (
                _mapKeys select _primaryIndex
            );

            _entry = _endpointMap getOrDefault [
                _radioA,
                []
            ];

            _radioB = toLower (
                _entry param [
                    0,
                    "",
                    [""]
                ]
            );
        };
    } forEach _resolveCandidates;
} else {
    private _pairSource = _targetRadioId;

    if (
        _pairSource isEqualTo "" ||
        {_pairSource find _prefix != 0}
    ) then {
        _pairSource = _sourceRadioId;
    };

    if (_pairSource find _prefix isEqualTo 0) then {
        private _sourceNumber = parseNumber (
            _pairSource select [
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

            _radioA = format [
                "%1%2",
                _prefix,
                _radioANumber
            ];

            _radioB = format [
                "%1%2",
                _prefix,
                _radioANumber + 1
            ];
        };
    };
};

private _released = false;

{
    private _result = [
        _x
    ] call acre_sys_prc152_fnc_handlePTTUp;

    if (_result) then {
        _released = true;
    };
} forEach _releaseRadios;

private _stateRadios = +_releaseRadios;

{
    if (
        _x find _prefix isEqualTo 0 &&
        {!(_x in _stateRadios)}
    ) then {
        _stateRadios pushBack _x;
    };
} forEach [
    _radioA,
    _radioB
];

{
    [
        _x,
        "setState",
        [
            "prc163PTTDown",
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163TransmittingA",
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163TransmittingB",
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach _stateRadios;

missionNamespace setVariable [
    "UKSF_PRC163_pttRadio",
    nil
];

missionNamespace setVariable [
    "UKSF_PRC163_pttLine",
    nil
];

_released || {
    _releaseRadios isNotEqualTo []
}
