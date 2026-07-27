private _prefix = "acre_prc163_id_";

private _sourceRadioId = toLower (
    [] call UKSF_PRC163_fnc_getTargetRadio
);

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

    private _primaryIndex = _mapKeys findIf {
        private _candidatePrimary = toLower _x;

        private _candidateEntry = _endpointMap getOrDefault [
            _x,
            []
        ];

        private _candidateCompanion = toLower (
            _candidateEntry param [
                0,
                "",
                [""]
            ]
        );

        _sourceRadioId in [
            _candidatePrimary,
            _candidateCompanion
        ]
    };

    if (_primaryIndex >= 0) then {
        private _mapPrimary = _mapKeys select _primaryIndex;

        private _entry = _endpointMap getOrDefault [
            _mapPrimary,
            []
        ];

        _radioA = toLower _mapPrimary;

        _radioB = toLower (
            _entry param [
                0,
                "",
                [""]
            ]
        );
    };

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
                {_candidateB in _gear}
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

private _enabled = [
    _radioA,
    "getState",
    "prc163DualWatch"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_enabled" ||
    {!(_enabled isEqualType 0)} ||
    {!(_enabled in [0,1])}
) then {
    [
        _radioA
    ] call UKSF_PRC163_fnc_initializeState;

    _enabled = [
        _radioA,
        "getState",
        "prc163DualWatch"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    isNil "_enabled" ||
    {!(_enabled isEqualType 0)} ||
    {!(_enabled in [0,1])}
) then {
    _enabled = 1;
};

private _newEnabled = 1 - _enabled;

{
    [
        _x,
        "setState",
        [
            "prc163DualWatch",
            _newEnabled
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _sourceRadioId
];

uiNamespace setVariable [
    "UKSF_PRC163_guiRadio",
    _sourceRadioId
];

[
    _sourceRadioId
] call UKSF_PRC163_fnc_notifyStatus;

true