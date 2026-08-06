params [
    ["_radioId","",[""]],
    ["_line",0,[0]],
    ["_channel",0,[0]]
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0} ||
    {!(_line in [0,1])}
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

    if (_entry isNotEqualTo []) then {
        _radioA = _sourceRadioId;
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

    _radioA = toLower _radioA;
    _radioB = toLower (
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
        !(_radioA in _gearRadios) ||
        {_radioA isEqualTo _radioB} ||
        {_radioB find _prefix != 0}
    ) then {
        _radioA = "";
        _radioB = "";
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

    private _sourceIndex = _radioEntries findIf {
        (_x select 1) isEqualTo _sourceRadioId
    };

    if (_sourceIndex >= 0) then {
        private _sourceNumber = (
            _radioEntries select _sourceIndex
        ) select 0;

        if (_sourceNumber >= 1) then {
            private _radioANumber = if (
                (_sourceNumber mod 2) isEqualTo 1
            ) then {
                _sourceNumber
            } else {
                _sourceNumber - 1
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
};

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""}
) exitWith {
    false
};

if !(
    [
        _radioA,
        _radioB,
        player
    ] call UKSF_PRC163_fnc_isPairHealthy
) exitWith {
    false
};

private _pairRadios = [
    _radioA,
    _radioB
];

private _targetRadioId = _pairRadios select _line;

private _channels = [
    _targetRadioId,
    "getState",
    "channels"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channels" ||
    {_channels isEqualTo []}
) exitWith {
    false
};

private _presetCount = (
    count _channels
) min 99;

if (_presetCount < 1) exitWith {
    false
};

_channel = floor _channel;

if (
    _channel < 0 ||
    {_channel >= _presetCount}
) exitWith {
    false
};

private _stateName = [
    "prc163ChannelA",
    "prc163ChannelB"
] select _line;

[
    _targetRadioId,
    "setCurrentChannel",
    _channel
] call acre_sys_data_fnc_dataEvent;

{
    [
        _x,
        "setState",
        [
            _stateName,
            _channel
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach _pairRadios;

true
