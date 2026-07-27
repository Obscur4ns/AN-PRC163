params [
    ["_radioId","",[""]]
];

private _prefix = "acre_prc163_id_";

private _storedRadioId = toLower (
    uiNamespace getVariable [
        "UKSF_PRC163_guiRadio",
        ""
    ]
);

private _requestedRadioId = toLower _radioId;

private _targetRadioId = if (
    _storedRadioId isNotEqualTo "" &&
    {_storedRadioId find _prefix isEqualTo 0}
) then {
    _storedRadioId
} else {
    _requestedRadioId
};

private _closeRadios = [];

if (
    _targetRadioId isNotEqualTo "" &&
    {_targetRadioId find _prefix isEqualTo 0}
) then {
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
        private _radioA = "";
        private _entry = _endpointMap getOrDefault [
            _targetRadioId,
            []
        ];

        if !(_entry isEqualTo []) then {
            _radioA = _targetRadioId;
        } else {
            private _statePrimary = [
                _targetRadioId,
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
                    ) isEqualTo _targetRadioId
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

        private _radioB = toLower (
            _entry param [
                0,
                "",
                [""]
            ]
        );

        _radioA = toLower _radioA;

        if (
            _radioA isNotEqualTo "" &&
            {_radioA find _prefix isEqualTo 0}
        ) then {
            _closeRadios pushBackUnique _radioA;
        };

        if (
            _radioB isNotEqualTo "" &&
            {_radioB find _prefix isEqualTo 0}
        ) then {
            _closeRadios pushBackUnique _radioB;
        };
    } else {
        private _sourceNumber = parseNumber (
            _targetRadioId select [
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

            _closeRadios pushBackUnique format [
                "%1%2",
                _prefix,
                _radioANumber
            ];

            _closeRadios pushBackUnique format [
                "%1%2",
                _prefix,
                _radioANumber + 1
            ];
        };
    };

    if (_closeRadios isEqualTo []) then {
        _closeRadios pushBack _targetRadioId;
    };

    {
        [
            _x,
            false
        ] call acre_sys_radio_fnc_setRadioOpenState;
    } forEach _closeRadios;
};

uiNamespace setVariable [
    "UKSF_PRC163_guiRadio",
    ""
];

uiNamespace setVariable [
    "UKSF_PRC163_display",
    displayNull
];

missionNamespace setVariable [
    "UKSF_PRC163_lastClosedGuiRadios",
    +_closeRadios
];

true
