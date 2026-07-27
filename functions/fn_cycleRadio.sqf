params [
    ["_direction",1,[0]]
];

if !(_direction in [-1,1]) exitWith {
    false
};

private _prefix = "acre_prc163_id_";
private _radios = (
    [player] call acre_sys_core_fnc_getGear
) apply {
    toLower _x
};

private _pairs = [];
private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

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
            _radioA in _radios &&
            {_radioA find _prefix isEqualTo 0} &&
            {_radioB find _prefix isEqualTo 0} &&
            {_radioA isNotEqualTo _radioB}
        ) then {
            private _slot = [
                _radioA
            ] call UKSF_PRC163_fnc_getBatterySlot;

            private _number = parseNumber (
                _radioA select [
                    count _prefix
                ]
            );

            private _sortValue = if (_slot >= 1) then {
                _slot
            } else {
                _number
            };

            _pairs pushBackUnique [
                _sortValue,
                _radioA,
                _radioB
            ];
        };
    } forEach keys _endpointMap;
} else {
    {
        private _radioA = _x;

        if (_radioA find _prefix isEqualTo 0) then {
            private _number = parseNumber (
                _radioA select [
                    count _prefix
                ]
            );

            if (
                _number >= 1 &&
                {(_number mod 2) isEqualTo 1}
            ) then {
                private _radioB = format [
                    "%1%2",
                    _prefix,
                    _number + 1
                ];

                if (_radioB in _radios) then {
                    _pairs pushBackUnique [
                        _number,
                        _radioA,
                        _radioB
                    ];
                };
            };
        };
    } forEach _radios;
};

_pairs sort true;

if (_pairs isEqualTo []) exitWith {
    false
};

private _currentRadio = toLower (
    [] call UKSF_PRC163_fnc_getTargetRadio
);

private _currentIndex = _pairs findIf {
    _currentRadio in [
        _x select 1,
        _x select 2
    ]
};

private _newIndex = if (_currentIndex < 0) then {
    if (_direction isEqualTo 1) then {
        0
    } else {
        (count _pairs) - 1
    }
} else {
    (
        _currentIndex +
        _direction +
        count _pairs
    ) % count _pairs
};

private _newPair = _pairs select _newIndex;

_newPair params [
    "_sortValue",
    "_radioA",
    "_radioB"
];

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

private _newRadio = [
    _radioA,
    _radioB
] select _selectedLine;

if !(
    [
        _newRadio
    ] call acre_api_fnc_setCurrentRadio
) exitWith {
    false
};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _newRadio
];

private _guiRadio = toLower (
    uiNamespace getVariable [
        "UKSF_PRC163_guiRadio",
        ""
    ]
);

if (_guiRadio isNotEqualTo "") then {
    uiNamespace setVariable [
        "UKSF_PRC163_guiRadio",
        _newRadio
    ];
};

[
    _newRadio
] call UKSF_PRC163_fnc_notifyStatus;

true
