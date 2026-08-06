params [
    ["_radioId","",[""]],
    ["_line",0,[0]]
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
    private _radioIds = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (_sourceRadioId in _radioIds) then {
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
                _candidateA in _radioIds &&
                {_candidateB in _radioIds}
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

private _previousSelectedLine = [
    _radioA,
    "getState",
    "prc163SelectedLine"
] call acre_sys_data_fnc_dataEvent;

if !(_previousSelectedLine in [0,1]) then {
    _previousSelectedLine = -1;
};

private _lineChanged = !(
    _previousSelectedLine isEqualTo _line
);

private _channelA = [
    _radioA,
    "getState",
    "prc163ChannelA"
] call acre_sys_data_fnc_dataEvent;

private _channelB = [
    _radioA,
    "getState",
    "prc163ChannelB"
] call acre_sys_data_fnc_dataEvent;

private _dualWatch = [
    _radioA,
    "getState",
    "prc163DualWatch"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channelA" ||
    {!(_channelA isEqualType 0)} ||
    {_channelA < 0}
) exitWith {
    false
};

if (
    isNil "_channelB" ||
    {!(_channelB isEqualType 0)} ||
    {_channelB < 0}
) exitWith {
    false
};

if (
    isNil "_dualWatch" ||
    {!(_dualWatch isEqualType 0)} ||
    {!(_dualWatch in [0,1])}
) then {
    _dualWatch = 1;
};

private _targetChannel = [
    _channelA,
    _channelB
] select _line;

private _channels = [
    _targetRadioId,
    "getState",
    "channels"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channels" ||
    {!(_channels isEqualType [])} ||
    {_channels isEqualTo []}
) exitWith {
    false
};

private _presetCount = (
    count _channels
) min 99;

if (
    _presetCount < 1 ||
    {_targetChannel >= _presetCount}
) exitWith {
    false
};

{
    [
        _x,
        "setState",
        [
            "prc163ChannelA",
            _channelA
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163ChannelB",
            _channelB
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163DualWatch",
            _dualWatch
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163SelectedLine",
            _line
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach _pairRadios;

[
    _targetRadioId,
    "setCurrentChannel",
    _targetChannel
] call acre_sys_data_fnc_dataEvent;

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

if (_lineChanged) then {
    private _radioType = [
        _targetRadioId
    ] call acre_sys_radio_fnc_getRadioBaseClassname;

    private _typeName = getText (
        configFile >>
        "CfgAcreComponents" >>
        _radioType >>
        "name"
    );

    if (_typeName isEqualTo "") then {
        _typeName = getText (
            configFile >>
            "CfgWeapons" >>
            "ACRE_PRC163" >>
            "displayName"
        );
    };

    if (_typeName isEqualTo "") then {
        _typeName = "AN/PRC-163";
    };

    private _listInfo = [
        _targetRadioId,
        "getListInfo"
    ] call acre_sys_data_fnc_dataEvent;

    private _cycleColor = missionNamespace getVariable [
        "acre_sys_list_CycleRadiosColor",
        [1,0.8,0,1]
    ];

    [
        "acre_cycleRadio",
        format [
            "%1 R/T %2",
            _typeName,
            _line + 1
        ],
        _listInfo,
        "",
        1,
        _cycleColor
    ] call acre_sys_list_fnc_displayHint;
};

true