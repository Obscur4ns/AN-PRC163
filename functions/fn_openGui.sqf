params [
    ["_radioId","",[""]]
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

private _selectedLine = [
    _radioA,
    "getState",
    "prc163SelectedLine"
] call acre_sys_data_fnc_dataEvent;

if !(_selectedLine in [0,1]) then {
    [
        _radioA
    ] call UKSF_PRC163_fnc_initializeState;

    _selectedLine = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;
};

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

private _targetRadioId = [
    _radioA,
    _radioB
] select _selectedLine;

if !(
    [
        _targetRadioId
    ] call acre_sys_radio_fnc_canOpenRadio
) exitWith {
    false
};

{
    [
        _x,
        "setState",
        [
            "prc163SelectedLine",
            _selectedLine
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

if !(
    [
        _targetRadioId
    ] call acre_api_fnc_setCurrentRadio
) exitWith {
    false
};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _targetRadioId
];

uiNamespace setVariable [
    "UKSF_PRC163_guiRadio",
    _targetRadioId
];

private _display = uiNamespace getVariable [
    "UKSF_PRC163_display",
    displayNull
];

if !(isNull _display) exitWith {
    [
        _display
    ] call UKSF_PRC163_fnc_updateDialog;

    [
        _targetRadioId,
        true
    ] call acre_sys_radio_fnc_setRadioOpenState;

    true
};

if !(createDialog "UKSF_PRC163_RadioDialog") exitWith {
    uiNamespace setVariable [
        "UKSF_PRC163_guiRadio",
        ""
    ];

    false
};

private _newDisplay = findDisplay 16300;

if (isNull _newDisplay) exitWith {
    uiNamespace setVariable [
        "UKSF_PRC163_guiRadio",
        ""
    ];

    false
};

private _initDisplayCurator = uiNamespace getVariable [
    "CBA_events_fnc_initDisplayCurator",
    {}
];

_newDisplay call _initDisplayCurator;

[
    _newDisplay
] call acre_api_fnc_addDisplayPassthroughKeys;

[
    _newDisplay
] call UKSF_PRC163_fnc_updateDialog;

[
    _targetRadioId,
    true
] call acre_sys_radio_fnc_setRadioOpenState;

true
