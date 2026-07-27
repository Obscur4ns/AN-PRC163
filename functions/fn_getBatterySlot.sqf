params [
    ["_radioId","",[""]],
    ["_unit",player,[objNull]]
];

if (isNull _unit) exitWith {
    -1
};

private _prefix = "acre_prc163_id_";

_radioId = toLower _radioId;

if (_radioId isEqualTo "") then {
    _radioId = toLower (
        [] call UKSF_PRC163_fnc_getTargetRadio
    );
};

if (
    _radioId isEqualTo "" ||
    {_radioId find _prefix != 0}
) exitWith {
    -1
};

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _radios = (
    [_unit] call acre_sys_core_fnc_getGear
) apply {
    toLower _x
};

if (_pilotEnabled) then {
    private _visibleEntries = (
        _radios select {
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

    _visibleEntries sort true;

    private _primary = "";

    if (_radioId in _radios) then {
        _primary = _radioId;
    } else {
        private _statePrimary = [
            _radioId,
            "getState",
            "prc163PrimaryRadio"
        ] call acre_sys_data_fnc_dataEvent;

        if (
            !isNil "_statePrimary" &&
            {_statePrimary isEqualType ""}
        ) then {
            _statePrimary = toLower _statePrimary;

            if (_statePrimary in _radios) then {
                _primary = _statePrimary;
            };
        };

        if (_primary isEqualTo "") then {
            private _endpointMap = missionNamespace getVariable [
                "UKSF_PRC163_endpointMap",
                createHashMap
            ];

            private _primaryIndex = (
                keys _endpointMap
            ) findIf {
                private _entry = _endpointMap getOrDefault [
                    _x,
                    []
                ];

                toLower (
                    _entry param [
                        0,
                        "",
                        [""]
                    ]
                ) isEqualTo _radioId
            };

            if (_primaryIndex >= 0) then {
                private _candidate = toLower (
                    (
                        keys _endpointMap
                    ) select _primaryIndex
                );

                if (_candidate in _radios) then {
                    _primary = _candidate;
                };
            };
        };
    };

    if (_primary isEqualTo "") exitWith {
        -1
    };

    private _slotIndex = _visibleEntries findIf {
        (_x select 1) isEqualTo _primary
    };

    if (_slotIndex < 0) exitWith {
        -1
    };

    _slotIndex + 1
} else {
    private _number = parseNumber (
        _radioId select [
            count _prefix
        ]
    );

    if (_number < 1) exitWith {
        -1
    };

    private _radioANumber = if (
        (_number mod 2) isEqualTo 1
    ) then {
        _number
    } else {
        _number - 1
    };

    private _radioA = format [
        "%1%2",
        _prefix,
        _radioANumber
    ];

    private _radioB = format [
        "%1%2",
        _prefix,
        _radioANumber + 1
    ];

    if (
        !(_radioA in _radios) ||
        {!(_radioB in _radios)}
    ) exitWith {
        -1
    };

    ((_radioANumber - 1) / 2) + 1
}
