private _prefix = "acre_prc163_id_";

private _gearRadios = (
    [player] call acre_sys_core_fnc_getGear
) apply {
    toLower _x
};

private _visibleRadios = _gearRadios select {
    _x find _prefix isEqualTo 0
};

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _pairs = [];

if (_pilotEnabled) then {
    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    {
        private _radioA = toLower _x;
        private _entry = _endpointMap getOrDefault [
            _x,
            []
        ];

        private _radioB = toLower (
            _entry param [
                0,
                "",
                [""]
            ]
        );

        if (
            _radioA in _visibleRadios &&
            {!(_radioA isEqualTo _radioB)} &&
            {_radioB find _prefix isEqualTo 0}
        ) then {
            private _number = parseNumber (
                _radioA select [
                    count _prefix
                ]
            );

            _pairs pushBack [
                _number,
                _radioA,
                _radioB
            ];
        };
    } forEach (
        keys _endpointMap
    );
} else {
    private _radioEntries = _visibleRadios apply {
        private _number = parseNumber (
            _x select [
                count _prefix
            ]
        );

        [
            _number,
            _x
        ]
    };

    {
        private _number = _x select 0;
        private _radioA = _x select 1;

        if (
            _number >= 1 &&
            {(_number mod 2) isEqualTo 1}
        ) then {
            private _radioBIndex = _radioEntries findIf {
                (_x select 0) isEqualTo (
                    _number + 1
                )
            };

            if (_radioBIndex >= 0) then {
                _pairs pushBack [
                    _number,
                    _radioA,
                    (
                        _radioEntries select _radioBIndex
                    ) select 1
                ];
            };
        };
    } forEach _radioEntries;
};

_pairs sort true;

if (_pairs isEqualTo []) exitWith {
    missionNamespace setVariable [
        "UKSF_PRC163_activeRadio",
        ""
    ];

    ""
};

private _resolveCandidate = {
    params [
        ["_candidate","",[""]]
    ];

    private _candidateId = toLower _candidate;

    if (
        _candidateId isEqualTo "" ||
        {_candidateId find _prefix != 0}
    ) exitWith {
        ""
    };

    private _pairIndex = _pairs findIf {
        _candidateId in [
            _x select 1,
            _x select 2
        ]
    };

    if (_pairIndex < 0) exitWith {
        ""
    };

    private _pair = _pairs select _pairIndex;
    private _radioA = _pair select 1;
    private _radioB = _pair select 2;

    private _selectedLine = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;

    if !(_selectedLine in [0,1]) then {
        _selectedLine = 0;
    };

    [
        _radioA,
        _radioB
    ] select _selectedLine
};

private _guiRadio = uiNamespace getVariable [
    "UKSF_PRC163_guiRadio",
    ""
];

private _activeRadio = missionNamespace getVariable [
    "UKSF_PRC163_activeRadio",
    ""
];

private _currentRadio = [] call acre_api_fnc_getCurrentRadio;

private _guiTarget = [
    _guiRadio
] call _resolveCandidate;

private _activeTarget = [
    _activeRadio
] call _resolveCandidate;

private _currentTarget = [
    _currentRadio
] call _resolveCandidate;

private _targetRadio = "";

if (_guiTarget != "") then {
    _targetRadio = if (
        _activeTarget != ""
    ) then {
        _activeTarget
    } else {
        _guiTarget
    };
} else {
    if (_currentTarget != "") then {
        _targetRadio = _currentTarget;
    } else {
        if (_activeTarget != "") then {
            _targetRadio = _activeTarget;
        } else {
            private _firstPair = _pairs select 0;
            private _firstRadioA = _firstPair select 1;
            private _firstRadioB = _firstPair select 2;

            private _firstSelectedLine = [
                _firstRadioA,
                "getState",
                "prc163SelectedLine"
            ] call acre_sys_data_fnc_dataEvent;

            if !(_firstSelectedLine in [0,1]) then {
                _firstSelectedLine = 0;
            };

            _targetRadio = [
                _firstRadioA,
                _firstRadioB
            ] select _firstSelectedLine;
        };
    };
};

if (_targetRadio isEqualTo "") exitWith {
    ""
};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _targetRadio
];

if (_guiTarget != "") then {
    uiNamespace setVariable [
        "UKSF_PRC163_guiRadio",
        _targetRadio
    ];
};

_targetRadio
