params [
    ["_radioId","",[""]],
    "_event",
    ["_radios",[],[[]]]
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    []
};

private _result = [
    _sourceRadioId,
    _event,
    _radios
] call acre_sys_prc152_fnc_handleMultipleTransmissions;

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _radioA = "";
private _radioB = "";
private _line = -1;

private _radioExists = {
    params [["_radioId","",[""]]];

    _radioId = toLower _radioId;

    if (
        _radioId isEqualTo "" ||
        {isNil "acre_sys_radio_fnc_radioExists"}
    ) exitWith {
        false
    };

    [_radioId] call acre_sys_radio_fnc_radioExists
};

if (_pilotEnabled) then {
    /*
        Receive processing is another ACRE hot path. Resolve the pair directly
        from the monitor-owned endpoint map instead of doing getGear plus
        isPairHealthy and its additional availability reconciliation.
    */
    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _entry = _endpointMap getOrDefault [
        _sourceRadioId,
        []
    ];

    if !(_entry isEqualTo []) then {
        _radioA = _sourceRadioId;
        _line = 0;
    } else {
        private _mapKeys = keys _endpointMap;

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

    _radioA = toLower _radioA;
    _radioB = toLower (
        _entry param [
            0,
            "",
            [""]
        ]
    );

    if (
        _radioA find _prefix != 0 ||
        {_radioB find _prefix != 0} ||
        {_radioA isEqualTo _radioB} ||
        {!(_line in [0,1])} ||
        {!([_radioA] call _radioExists)} ||
        {!([_radioB] call _radioExists)}
    ) then {
        _radioA = "";
        _radioB = "";
        _line = -1;
    };
} else {
    private _gear = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (_sourceRadioId in _gear) then {
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
                _candidateA in _gear &&
                {_candidateB in _gear} &&
                {[_candidateA] call _radioExists} &&
                {[_candidateB] call _radioExists}
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
    _radioA isNotEqualTo "" &&
    {_radioB isNotEqualTo ""} &&
    {_line in [0,1]}
) then {
    private _receiving = if (
        _result isEqualType [] &&
        {_result isNotEqualTo []}
    ) then {
        1
    } else {
        0
    };

    private _stateName = [
        "prc163ReceivingA",
        "prc163ReceivingB"
    ] select _line;

    /*
        ACRE can poll this callback repeatedly while the receive condition has
        not changed. Avoid broadcasting two identical setState writes on every
        poll; only mirror the state when the logical receive state transitions.
    */
    private _currentReceiving = [
        _radioA,
        "getState",
        _stateName
    ] call acre_sys_data_fnc_dataEvent;

    if !(_currentReceiving in [0,1]) then {
        _currentReceiving = -1;
    };

    if (_currentReceiving isNotEqualTo _receiving) then {
        {
            [
                _x,
                "setState",
                [
                    _stateName,
                    _receiving
                ]
            ] call acre_sys_data_fnc_dataEvent;
        } forEach [
            _radioA,
            _radioB
        ];
    };
};

_result
