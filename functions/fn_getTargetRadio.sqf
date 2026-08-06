if (isNull player) exitWith {
    ""
};

private _prefix = "acre_prc163_id_";
private _candidates = [];

private _addCandidate = {
    params [
        ["_candidate","",[""]]
    ];

    _candidate = toLower _candidate;

    if (
        _candidate find _prefix isEqualTo 0 &&
        {!(_candidate in _candidates)}
    ) then {
        _candidates pushBack _candidate;
    };
};

private _guiValue = uiNamespace getVariable [
    "UKSF_PRC163_guiRadio",
    ""
];

if (_guiValue isEqualType "") then {
    [
        _guiValue
    ] call _addCandidate;
};

private _activeValue = missionNamespace getVariable [
    "UKSF_PRC163_activeRadio",
    ""
];

if (_activeValue isEqualType "") then {
    [
        _activeValue
    ] call _addCandidate;
};

private _currentValue = [] call acre_api_fnc_getCurrentRadio;

if (_currentValue isEqualType "") then {
    [
        _currentValue
    ] call _addCandidate;
};

private _resolvedPrimary = "";

{
    private _pair = [
        _x,
        player,
        false
    ] call UKSF_PRC163_fnc_resolvePair;

    private _radioA = _pair param [
        0,
        "",
        [""]
    ];

    if !(_radioA isEqualTo "") exitWith {
        _resolvedPrimary = _radioA;
    };
} forEach _candidates;

if !(_resolvedPrimary isEqualTo "") exitWith {
    _resolvedPrimary
};

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
    _mapKeys sort true;

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
            [
                _radioA,
                _radioB,
                player,
                false
            ] call UKSF_PRC163_fnc_isPairHealthy
        ) exitWith {
            _resolvedPrimary = _radioA;
        };
    } forEach _mapKeys;
} else {
    private _gear = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    private _entries = (
        _gear select {
            _x find _prefix isEqualTo 0
        }
    ) apply {
        [
            parseNumber (
                _x select [
                    count _prefix
                ]
            ),
            _x
        ]
    };

    _entries sort true;

    {
        _x params [
            "_number",
            "_radioA"
        ];

        if (
            _number > 0 &&
            {(_number mod 2) isEqualTo 1}
        ) then {
            private _radioB = format [
                "%1%2",
                _prefix,
                _number + 1
            ];

            if (
                [
                    _radioA,
                    _radioB,
                    player,
                    false
                ] call UKSF_PRC163_fnc_isPairHealthy
            ) exitWith {
                _resolvedPrimary = _radioA;
            };
        };
    } forEach _entries;
};

_resolvedPrimary
