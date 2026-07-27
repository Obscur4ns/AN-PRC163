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

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _radioA = "";
private _radioB = "";
private _targetRadioId = _rememberedRadioId;

private _resolvePilotEndpoint = {
    params [
        ["_candidate","",[""]]
    ];

    private _candidateId = toLower _candidate;

    if (
        _candidateId isEqualTo "" ||
        {_candidateId find _prefix != 0}
    ) exitWith {
        []
    };

    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _mapKeys = keys _endpointMap;
    private _entry = _endpointMap getOrDefault [
        _candidateId,
        []
    ];

    private _primary = "";

    if (_entry isNotEqualTo []) then {
        _primary = _candidateId;
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
            ) isEqualTo _candidateId
        };

        if (_primaryIndex >= 0) then {
            _primary = _mapKeys select _primaryIndex;
            _entry = _endpointMap getOrDefault [
                _primary,
                []
            ];
        };
    };

    _primary = toLower _primary;

    private _companion = toLower (
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
        !(_primary in _gearRadios) ||
        {_primary isEqualTo _companion} ||
        {_companion find _prefix != 0}
    ) exitWith {
        []
    };

    [
        _primary,
        _companion
    ]
};

if (_pilotEnabled) then {
    private _resolvedPair = [
        _targetRadioId
    ] call _resolvePilotEndpoint;

    if (_resolvedPair isEqualTo []) then {
        _targetRadioId = _sourceRadioId;

        _resolvedPair = [
            _targetRadioId
        ] call _resolvePilotEndpoint;
    };

    if (_resolvedPair isNotEqualTo []) then {
        _radioA = _resolvedPair select 0;
        _radioB = _resolvedPair select 1;
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

    private _targetEntryIndex = _radioEntries findIf {
        (_x select 1) isEqualTo _targetRadioId
    };

    if (_targetEntryIndex < 0) then {
        _targetRadioId = _sourceRadioId;

        _targetEntryIndex = _radioEntries findIf {
            (_x select 1) isEqualTo _targetRadioId
        };
    };

    if (_targetEntryIndex >= 0) then {
        private _targetNumber = (
            _radioEntries select _targetEntryIndex
        ) select 0;

        private _radioANumber = if (
            (_targetNumber mod 2) isEqualTo 1
        ) then {
            _targetNumber
        } else {
            _targetNumber - 1
        };

        private _radioAIndex = _radioEntries findIf {
            (_x select 0) isEqualTo _radioANumber
        };

        private _radioBIndex = _radioEntries findIf {
            (_x select 0) isEqualTo (
                _radioANumber + 1
            )
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

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""}
) exitWith {
    missionNamespace setVariable [
        "UKSF_PRC163_pttRadio",
        nil
    ];

    false
};

private _pairRadios = [
    _radioA,
    _radioB
];

if !(_targetRadioId in _pairRadios) then {
    private _selectedLine = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;

    if !(_selectedLine in [0,1]) then {
        _selectedLine = 0;
    };

    _targetRadioId = _pairRadios select _selectedLine;
};

private _result = [
    _targetRadioId
] call acre_sys_prc152_fnc_handlePTTUp;

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
} forEach _pairRadios;

missionNamespace setVariable [
    "UKSF_PRC163_pttRadio",
    nil
];

_result
