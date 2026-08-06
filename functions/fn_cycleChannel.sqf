params [
    ["_direction",1,[0]]
];

if !(_direction in [-1,1]) exitWith {
    false
};

private _prefix = "acre_prc163_id_";

private _sourceRadio = toLower (
    [] call UKSF_PRC163_fnc_getTargetRadio
);

if (
    _sourceRadio isEqualTo "" ||
    {_sourceRadio find _prefix != 0}
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

        _sourceRadio in [
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
    private _radioIds = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    if (_sourceRadio in _radioIds) then {
        private _sourceNumber = parseNumber (
            _sourceRadio select [
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

private _selectedLine = [
    _radioA,
    "getState",
    "prc163SelectedLine"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_selectedLine" ||
    {!(_selectedLine isEqualType 0)} ||
    {!(_selectedLine in [0,1])}
) then {
    [
        _radioA
    ] call UKSF_PRC163_fnc_initializeState;

    _selectedLine = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    isNil "_selectedLine" ||
    {!(_selectedLine isEqualType 0)} ||
    {!(_selectedLine in [0,1])}
) then {
    _selectedLine = 0;
};

private _targetRadio = [
    _radioA,
    _radioB
] select _selectedLine;

private _stateName = [
    "prc163ChannelA",
    "prc163ChannelB"
] select _selectedLine;

private _channels = [
    _targetRadio,
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

if (_presetCount < 1) exitWith {
    false
};

private _channel = [
    _radioA,
    "getState",
    _stateName
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channel" ||
    {!(_channel isEqualType 0)}
) then {
    _channel = [
        _targetRadio,
        "getCurrentChannel"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    isNil "_channel" ||
    {!(_channel isEqualType 0)}
) then {
    _channel = 0;
};

_channel = floor _channel;

if (
    _channel < 0 ||
    {_channel >= _presetCount}
) then {
    _channel = 0;
};

private _newChannel = (
    _channel +
    _direction +
    _presetCount
) % _presetCount;

if !(
    [
        _radioA,
        _selectedLine,
        _newChannel
    ] call UKSF_PRC163_fnc_setLineChannel
) exitWith {
    false
};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _targetRadio
];

uiNamespace setVariable [
    "UKSF_PRC163_guiRadio",
    _targetRadio
];

private _radioType = [
    _targetRadio
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

private _listInfo = [
    _targetRadio,
    "getListInfo"
] call acre_sys_data_fnc_dataEvent;

private _switchColor = missionNamespace getVariable [
    "acre_sys_list_SwitchChannelColor",
    [1,0.8,0,1]
];

[
    "acre_switchChannel",
    _typeName,
    _listInfo,
    "",
    0.5,
    _switchColor
] call acre_sys_list_fnc_displayHint;

[
    "Acre_GenericClick",
    [0,0,0],
    [0,0,0],
    1,
    false
] call acre_sys_sounds_fnc_playSound;

true