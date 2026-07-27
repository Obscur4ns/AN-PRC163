params [
    ["_radioId","",[""]]
];

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    []
};

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _radioA = "";

if (_pilotEnabled) then {
    private _gear = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (_sourceRadioId in _gear) then {
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

            if (_statePrimary in _gear) then {
                _radioA = _statePrimary;
            };
        };

        if (_radioA isEqualTo "") then {
            private _endpointMap = missionNamespace getVariable [
                "UKSF_PRC163_endpointMap",
                createHashMap
            ];

            private _mapKeys = keys _endpointMap;
            private _primaryIndex = _mapKeys findIf {
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
                ) isEqualTo _sourceRadioId
            };

            if (_primaryIndex >= 0) then {
                private _candidate = toLower (
                    _mapKeys select _primaryIndex
                );

                if (_candidate in _gear) then {
                    _radioA = _candidate;
                };
            };
        };
    };
} else {
    private _number = parseNumber (
        _sourceRadioId select [
            count _prefix
        ]
    );

    if (_number >= 1) then {
        private _radioANumber = if (
            (_number mod 2) isEqualTo 1
        ) then {
            _number
        } else {
            _number - 1
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

        private _gear = (
            [player] call acre_sys_core_fnc_getGear
        ) apply {
            toLower _x
        };

        if (
            _candidateA in _gear &&
            {_candidateB in _gear}
        ) then {
            _radioA = _candidateA;
        };
    };
};

if (_radioA isEqualTo "") exitWith {
    []
};

private _slot = [
    _radioA
] call UKSF_PRC163_fnc_getBatterySlot;

if (_slot < 1) exitWith {
    []
};

private _installed = [
    _radioA,
    "getState",
    "prc163BatteryInstalled"
] call acre_sys_data_fnc_dataEvent;

private _serial = [
    _radioA,
    "getState",
    "prc163BatterySerial"
] call acre_sys_data_fnc_dataEvent;

private _charge = [
    _radioA,
    "getState",
    "prc163BatteryCharge"
] call acre_sys_data_fnc_dataEvent;

private _health = [
    _radioA,
    "getState",
    "prc163BatteryHealth"
] call acre_sys_data_fnc_dataEvent;

if (isNil "_installed") then {
    _installed = 0;
};

if (isNil "_serial") then {
    _serial = "";
};

if (isNil "_charge") then {
    _charge = 0;
};

if (isNil "_health") then {
    _health = 1;
};

_installed = if (_installed isEqualTo 0) then {
    0
} else {
    1
};

_charge = (
    (_charge max 0) min 1
);

_health = (
    (_health max 0) min 1
);

if (_installed isEqualTo 0) then {
    _serial = "";
    _charge = 0;
};

[
    _slot,
    _installed,
    _serial,
    _charge,
    _health
]
