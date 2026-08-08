if (!hasInterface) exitWith {
    false
};

private _insertRadioChildren = {
    params [
        "_target",
        "_player"
    ];

    private _prefix = "acre_prc163_id_";

    private _radios = (
        [_player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    private _pilotEnabled = missionNamespace getVariable [
        "UKSF_PRC163_SingleInstancePilot",
        false
    ];

    private _pairEntries = [];

    if (_pilotEnabled) then {
        private _endpointMap = missionNamespace getVariable [
            "UKSF_PRC163_endpointMap",
            createHashMap
        ];

        {
            private _radioA = _x;

            if (_radioA find _prefix isEqualTo 0) then {
                private _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];

                private _radioB = toLower (
                    _entry param [
                        0,
                        "",
                        [""]
                    ]
                );

                private _slot = [
                    _radioA,
                    _player
                ] call UKSF_PRC163_fnc_getBatterySlot;

                if (
                    _slot > 0 &&
                    {_radioB find _prefix isEqualTo 0} &&
                    {_radioB isNotEqualTo _radioA}
                ) then {
                    _pairEntries pushBackUnique [
                        _slot,
                        _radioA,
                        _radioB
                    ];
                };
            };
        } forEach _radios;
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
                    _number > 0 &&
                    {(_number mod 2) isEqualTo 1}
                ) then {
                    private _radioB = format [
                        "%1%2",
                        _prefix,
                        _number + 1
                    ];

                    if (_radioB in _radios) then {
                        _pairEntries pushBackUnique [
                            floor (
                                (_number + 1) / 2
                            ),
                            _radioA,
                            _radioB
                        ];
                    };
                };
            };
        } forEach _radios;
    };

    _pairEntries sort true;

    private _radioChildren = [];

    {
        _x params [
            "_slot",
            "_radioA",
            "_radioB"
        ];

        private _state = [
            _radioA
        ] call UKSF_PRC163_fnc_getDisplayState;

        if !(_state isEqualType createHashMap) then {
            _state = createHashMap;
        };

        private _selectedLine = _state getOrDefault [
            "selectedLine",
            0
        ];

        if !(_selectedLine in [0,1]) then {
            _selectedLine = 0;
        };

        private _selectedLineName = [
            "R/T 1",
            "R/T 2"
        ] select _selectedLine;

        private _powerText = _state getOrDefault [
            "powerText",
            "OFF"
        ];

        private _dualWatch = _state getOrDefault [
            "dualWatch",
            0
        ];

        private _batteryText = _state getOrDefault [
            "batteryText",
            "NO BAT"
        ];

        private _spatialA = toUpper (
            _state getOrDefault [
                "spatialAText",
                "BOTH"
            ]
        );

        private _spatialB = toUpper (
            _state getOrDefault [
                "spatialBText",
                "BOTH"
            ]
        );

        if (_spatialA in ["CENTER","CENTRE"]) then {
            _spatialA = "BOTH";
        };

        if (_spatialB in ["CENTER","CENTRE"]) then {
            _spatialB = "BOTH";
        };

        private _radioBase = [
            _radioA
        ] call acre_api_fnc_getBaseRadio;

        private _radioPicture = getText (
            configFile >>
            "CfgWeapons" >>
            _radioBase >>
            "picture"
        );

        private _batteryPicture = getText (
            configFile >>
            "CfgWeapons" >>
            "UKSF_PRC163_Battery" >>
            "picture"
        );

        if (_batteryPicture isEqualTo "") then {
            _batteryPicture = _radioPicture;
        };

        private _openIcon = "\idi\acre\addons\ace_interact\data\icons\open.paa";
        private _activeIcon = "\idi\acre\addons\ace_interact\data\icons\active.paa";
        private _leftEarIcon = "\idi\acre\addons\ace_interact\data\icons\left_ear.paa";
        private _bothEarsIcon = "\idi\acre\addons\ace_interact\data\icons\both_ears.paa";
        private _rightEarIcon = "\idi\acre\addons\ace_interact\data\icons\right_ear.paa";

        private _audioAText = switch (_spatialA) do {
            case "LEFT": {
                localize "STR_ACRE_ace_interact_leftEar"
            };

            case "RIGHT": {
                localize "STR_ACRE_ace_interact_rightEar"
            };

            default {
                localize "STR_ACRE_ace_interact_bothEars"
            };
        };

        private _audioBText = switch (_spatialB) do {
            case "LEFT": {
                localize "STR_ACRE_ace_interact_leftEar"
            };

            case "RIGHT": {
                localize "STR_ACRE_ace_interact_rightEar"
            };

            default {
                localize "STR_ACRE_ace_interact_bothEars"
            };
        };

        private _audioAIcon = switch (_spatialA) do {
            case "LEFT": {
                _leftEarIcon
            };

            case "RIGHT": {
                _rightEarIcon
            };

            default {
                _bothEarsIcon
            };
        };

        private _audioBIcon = switch (_spatialB) do {
            case "LEFT": {
                _leftEarIcon
            };

            case "RIGHT": {
                _rightEarIcon
            };

            default {
                _bothEarsIcon
            };
        };

        private _pairCondition = {
            params ["_target","_player","_arguments"];
            _arguments params ["_radioA","_radioB"];
            private _pair = [_radioA,_player,false] call UKSF_PRC163_fnc_resolvePair;
            if ((_pair param [0,""]) isNotEqualTo _radioA || {(_pair param [1,""]) isNotEqualTo _radioB}) exitWith {false};
            private _broadcast = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
            private _remembered = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
            private _pairRadios = [_radioA,_radioB];
            !(
                (missionNamespace getVariable ["acre_sys_core_pttKeyDown",false]) &&
                {_broadcast in _pairRadios || {_remembered in _pairRadios}}
            )
        };

        private _poweredPairCondition = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB"
            ];

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if !(_radioA in _carriedRadios) exitWith {
                false
            };

            if (
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) then {
                private _endpointMap = missionNamespace getVariable [
                    "UKSF_PRC163_endpointMap",
                    createHashMap
                ];

                private _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];

                if (
                    toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    ) isNotEqualTo _radioB
                ) exitWith {
                    false
                };
            } else {
                if !(_radioB in _carriedRadios) exitWith {
                    false
                };
            };

            private _powerA = [
                _radioA,
                "getOnOffState"
            ] call acre_sys_data_fnc_dataEvent;

            private _powerB = [
                _radioB,
                "getOnOffState"
            ] call acre_sys_data_fnc_dataEvent;

            (
                _powerA isEqualTo 1 ||
                {_powerA isEqualTo true} ||
                {_powerB isEqualTo 1} ||
                {_powerB isEqualTo true}
            )
        };

        private _batteryCondition = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB"
            ];

            if !(
                missionNamespace getVariable [
                    "UKSF_PRC163_BatteriesEnabled",
                    true
                ]
            ) exitWith {
                false
            };

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if !(_radioA in _carriedRadios) exitWith {
                false
            };

            if !(
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) exitWith {
                _radioB in _carriedRadios
            };

            private _endpointMap = missionNamespace getVariable [
                "UKSF_PRC163_endpointMap",
                createHashMap
            ];

            private _entry = _endpointMap getOrDefault [
                _radioA,
                []
            ];

            toLower (
                _entry param [
                    0,
                    "",
                    [""]
                ]
            ) isEqualTo _radioB
        };

        private _openStatement = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB"
            ];

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if !(_radioA in _carriedRadios) exitWith {};

            if (
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) then {
                private _endpointMap = missionNamespace getVariable [
                    "UKSF_PRC163_endpointMap",
                    createHashMap
                ];

                private _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];

                if (
                    toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    ) isNotEqualTo _radioB
                ) exitWith {};
            } else {
                if !(_radioB in _carriedRadios) exitWith {};
            };

            [
                _radioA,
                "openGui"
            ] call acre_sys_data_fnc_interactEvent;
        };

        private _selectStatement = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB",
                "_line"
            ];

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if (
                !(_radioA in _carriedRadios) ||
                {!(_line in [0,1])}
            ) exitWith {};

            if (
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) then {
                private _endpointMap = missionNamespace getVariable [
                    "UKSF_PRC163_endpointMap",
                    createHashMap
                ];

                private _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];

                if (
                    toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    ) isNotEqualTo _radioB
                ) exitWith {};
            } else {
                if !(_radioB in _carriedRadios) exitWith {};
            };

            [
                _radioA,
                _line
            ] call UKSF_PRC163_fnc_selectLine;
        };

        private _earStatement = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB",
                "_line",
                "_spatial"
            ];

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if (
                !(_radioA in _carriedRadios) ||
                {!(_line in [0,1])} ||
                {!(_spatial in ["LEFT","CENTER","RIGHT"])}
            ) exitWith {};

            if (
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) then {
                private _endpointMap = missionNamespace getVariable [
                    "UKSF_PRC163_endpointMap",
                    createHashMap
                ];

                private _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];

                if (
                    toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    ) isNotEqualTo _radioB
                ) exitWith {};
            } else {
                if !(_radioB in _carriedRadios) exitWith {};
            };

            private _pairRadios = [_radioA,_radioB];
            private _coreDown = missionNamespace getVariable ["acre_sys_core_pttKeyDown",false];
            private _broadcast = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
            private _remembered = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
            if (_coreDown && {_broadcast in _pairRadios || {_remembered in _pairRadios}}) exitWith {};

            private _stale = _remembered in _pairRadios || {_broadcast in _pairRadios};
            if (!_stale) then {
                _stale = (_pairRadios findIf {
                    ([_x,"getState","prc163PTTDown"] call acre_sys_data_fnc_dataEvent) isEqualTo 1
                }) >= 0;
            };
            if (_stale) then {[_radioA,_player,false] call UKSF_PRC163_fnc_normalizePairState};

            private _targetRadio = _pairRadios select _line;
            [_targetRadio,"setSpatial",_spatial] call acre_sys_data_fnc_dataEvent;
        };

        private _dualWatchStatement = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB"
            ];

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if !(_radioA in _carriedRadios) exitWith {};

            if (
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) then {
                private _endpointMap = missionNamespace getVariable [
                    "UKSF_PRC163_endpointMap",
                    createHashMap
                ];

                private _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];

                if (
                    toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    ) isNotEqualTo _radioB
                ) exitWith {};
            } else {
                if !(_radioB in _carriedRadios) exitWith {};
            };

            [_radioA] call UKSF_PRC163_fnc_toggleDualWatch;
        };

        private _statusStatement = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB",
                "_slot"
            ];

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if !(_radioA in _carriedRadios) exitWith {};

            if (
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) then {
                private _endpointMap = missionNamespace getVariable [
                    "UKSF_PRC163_endpointMap",
                    createHashMap
                ];

                private _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];

                if (
                    toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    ) isNotEqualTo _radioB
                ) exitWith {};
            } else {
                if !(_radioB in _carriedRadios) exitWith {};
            };

            private _state = [
                _radioA
            ] call UKSF_PRC163_fnc_getDisplayState;

            if ((count _state) isEqualTo 0) exitWith {};

            private _message = format [
                "<t align='center'>AN/PRC-163 %1 - %2"
                + "<br/><t size='0.9'>R/T 1: P%3 %4</t>"
                + "<br/><t size='0.9'>R/T 2: P%5 %6</t>"
                + "<br/><t size='0.85'>DW: %7 | %8</t></t>",
                _slot,
                _state getOrDefault [
                    "powerText",
                    "OFF"
                ],
                _state getOrDefault [
                    "channelADisplay",
                    1
                ],
                _state getOrDefault [
                    "txPowerAText",
                    "--"
                ],
                _state getOrDefault [
                    "channelBDisplay",
                    1
                ],
                _state getOrDefault [
                    "txPowerBText",
                    "--"
                ],
                if (
                    (
                        _state getOrDefault [
                            "dualWatch",
                            0
                        ]
                    ) isEqualTo 1
                ) then {
                    "ON"
                } else {
                    "OFF"
                },
                _state getOrDefault [
                    "batteryText",
                    "NO BAT"
                ]
            ];

            [
                _message,
                3,
                player,
                10
            ] call UKSF_PRC163_fnc_notifyStatus;
        };

        private _checkBatteryStatement = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB"
            ];

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if !(_radioA in _carriedRadios) exitWith {};

            if (
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) then {
                private _endpointMap = missionNamespace getVariable [
                    "UKSF_PRC163_endpointMap",
                    createHashMap
                ];

                private _entry = _endpointMap getOrDefault [
                    _radioA,
                    []
                ];

                if (
                    toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    ) isNotEqualTo _radioB
                ) exitWith {};
            } else {
                if !(_radioB in _carriedRadios) exitWith {};
            };

            private _record = [
                _radioA
            ] call UKSF_PRC163_fnc_getBatteryRecord;

            if ((count _record) isNotEqualTo 5) exitWith {};

            private _slot = _record select 0;
            private _installed = _record select 1;

            private _charge = round (
                (
                    (
                        (_record select 3) max 0
                    ) min 1
                ) * 100
            );

            private _health = round (
                (
                    (
                        (_record select 4) max 0
                    ) min 1
                ) * 100
            );

            private _message = if (
                _installed isEqualTo 0
            ) then {
                format [
                    "<t align='center'>AN/PRC-163 %1<br/>NO BATTERY</t>",
                    _slot
                ]
            } else {
                format [
                    "<t align='center'>AN/PRC-163 %1"
                    + "<br/><t size='0.85'>BATTERY: %2%3 | HEALTH: %4%5</t></t>",
                    _slot,
                    _charge,
                    "%",
                    _health,
                    "%"
                ]
            };

            [
                _message,
                1.5,
                player,
                10
            ] call UKSF_PRC163_fnc_notifyStatus;
        };

        private _replaceBatteryStatement = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB"
            ];

            [
                4,
                [
                    _radioA,
                    _radioB,
                    _player
                ],
                {
                    params ["_arguments"];

                    _arguments params [
                        "_radioA",
                        "_radioB",
                        "_player"
                    ];

                    private _carriedRadios = (
                        [_player] call acre_sys_core_fnc_getGear
                    ) apply {
                        toLower _x
                    };

                    if !(_radioA in _carriedRadios) exitWith {};

                    if (
                        missionNamespace getVariable [
                            "UKSF_PRC163_SingleInstancePilot",
                            false
                        ]
                    ) then {
                        private _endpointMap = missionNamespace getVariable [
                            "UKSF_PRC163_endpointMap",
                            createHashMap
                        ];

                        private _entry = _endpointMap getOrDefault [
                            _radioA,
                            []
                        ];

                        if (
                            toLower (
                                _entry param [
                                    0,
                                    "",
                                    [""]
                                ]
                            ) isNotEqualTo _radioB
                        ) exitWith {};
                    } else {
                        if !(_radioB in _carriedRadios) exitWith {};
                    };

                    [
                        _radioA,
                        _player,
                        true
                    ] call UKSF_PRC163_fnc_replaceBattery;
                },
                {},
                "Replacing AN/PRC-163 battery...",
                {
                    params ["_arguments"];

                    _arguments params [
                        "_radioA",
                        "_radioB",
                        "_player"
                    ];

                    private _carriedRadios = (
                        [_player] call acre_sys_core_fnc_getGear
                    ) apply {
                        toLower _x
                    };

                    if (
                        !alive _player ||
                        {!(_radioA in _carriedRadios)} ||
                        {
                            !(
                                "UKSF_PRC163_Battery" in items _player
                            )
                        }
                    ) exitWith {
                        false
                    };

                    if !(
                        missionNamespace getVariable [
                            "UKSF_PRC163_SingleInstancePilot",
                            false
                        ]
                    ) exitWith {
                        _radioB in _carriedRadios
                    };

                    private _endpointMap = missionNamespace getVariable [
                        "UKSF_PRC163_endpointMap",
                        createHashMap
                    ];

                    private _entry = _endpointMap getOrDefault [
                        _radioA,
                        []
                    ];

                    toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    ) isEqualTo _radioB
                }
            ] call ace_common_fnc_progressBar;
        };

        private _replaceBatteryCondition = {
            params [
                "_target",
                "_player",
                "_arguments"
            ];

            _arguments params [
                "_radioA",
                "_radioB"
            ];

            if !(
                missionNamespace getVariable [
                    "UKSF_PRC163_BatteriesEnabled",
                    true
                ]
            ) exitWith {
                false
            };

            if !(
                "UKSF_PRC163_Battery" in items _player
            ) exitWith {
                false
            };

            private _pairRadios = [_radioA,_radioB];
            private _broadcast = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
            private _remembered = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
            if (
                (missionNamespace getVariable ["acre_sys_core_pttKeyDown",false]) &&
                {_broadcast in _pairRadios || {_remembered in _pairRadios}}
            ) exitWith {false};

            private _carriedRadios = (
                [_player] call acre_sys_core_fnc_getGear
            ) apply {
                toLower _x
            };

            if !(_radioA in _carriedRadios) exitWith {
                false
            };

            if !(
                missionNamespace getVariable [
                    "UKSF_PRC163_SingleInstancePilot",
                    false
                ]
            ) exitWith {
                _radioB in _carriedRadios
            };

            private _endpointMap = missionNamespace getVariable [
                "UKSF_PRC163_endpointMap",
                createHashMap
            ];

            private _entry = _endpointMap getOrDefault [
                _radioA,
                []
            ];

            toLower (
                _entry param [
                    0,
                    "",
                    [""]
                ]
            ) isEqualTo _radioB
        };

        private _openAction = [
            format [
                "UKSF_PRC163_Open_%1",
                _slot
            ],
            localize "STR_ACRE_sys_gui_Open",
            _openIcon,
            _openStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _selectAAction = [
            format [
                "UKSF_PRC163_SelectRT1_%1",
                _slot
            ],
            localize "STR_ACRE_ace_interact_setAsActive",
            _activeIcon,
            _selectStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                0
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _selectBAction = [
            format [
                "UKSF_PRC163_SelectRT2_%1",
                _slot
            ],
            localize "STR_ACRE_ace_interact_setAsActive",
            _activeIcon,
            _selectStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                1
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _leftEarAAction = [
            format [
                "UKSF_PRC163_RT1Left_%1",
                _slot
            ],
            localize "STR_ACRE_ace_interact_leftEar",
            _leftEarIcon,
            _earStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                0,
                "LEFT"
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _bothEarsAAction = [
            format [
                "UKSF_PRC163_RT1Both_%1",
                _slot
            ],
            localize "STR_ACRE_ace_interact_bothEars",
            _bothEarsIcon,
            _earStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                0,
                "CENTER"
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _rightEarAAction = [
            format [
                "UKSF_PRC163_RT1Right_%1",
                _slot
            ],
            localize "STR_ACRE_ace_interact_rightEar",
            _rightEarIcon,
            _earStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                0,
                "RIGHT"
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _leftEarBAction = [
            format [
                "UKSF_PRC163_RT2Left_%1",
                _slot
            ],
            localize "STR_ACRE_ace_interact_leftEar",
            _leftEarIcon,
            _earStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                1,
                "LEFT"
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _bothEarsBAction = [
            format [
                "UKSF_PRC163_RT2Both_%1",
                _slot
            ],
            localize "STR_ACRE_ace_interact_bothEars",
            _bothEarsIcon,
            _earStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                1,
                "CENTER"
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _rightEarBAction = [
            format [
                "UKSF_PRC163_RT2Right_%1",
                _slot
            ],
            localize "STR_ACRE_ace_interact_rightEar",
            _rightEarIcon,
            _earStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                1,
                "RIGHT"
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _audioAAction = [
            format [
                "UKSF_PRC163_RT1Audio_%1",
                _slot
            ],
            _audioAText,
            _audioAIcon,
            {},
            _pairCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _audioBAction = [
            format [
                "UKSF_PRC163_RT2Audio_%1",
                _slot
            ],
            _audioBText,
            _audioBIcon,
            {},
            _pairCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _rtAAction = [
            format [
                "UKSF_PRC163_RT1_%1",
                _slot
            ],
            format [
                "R/T 1 | Chn %1",
                _state getOrDefault [
                    "channelADisplay",
                    1
                ]
            ],
            if (_selectedLine isEqualTo 0) then {
                _activeIcon
            } else {
                _radioPicture
            },
            {},
            _pairCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _rtBAction = [
            format [
                "UKSF_PRC163_RT2_%1",
                _slot
            ],
            format [
                "R/T 2 | Chn %1",
                _state getOrDefault [
                    "channelBDisplay",
                    1
                ]
            ],
            if (_selectedLine isEqualTo 1) then {
                _activeIcon
            } else {
                _radioPicture
            },
            {},
            _pairCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _dualWatchAction = [
            format [
                "UKSF_PRC163_DualWatch_%1",
                _slot
            ],
            format [
                "Dual Watch: %1",
                if (_dualWatch isEqualTo 1) then {
                    "ON"
                } else {
                    "OFF"
                }
            ],
            if (_dualWatch isEqualTo 1) then {
                _activeIcon
            } else {
                ""
            },
            _dualWatchStatement,
            _poweredPairCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _statusAction = [
            format [
                "UKSF_PRC163_Status_%1",
                _slot
            ],
            "Status",
            _radioPicture,
            _statusStatement,
            _pairCondition,
            {},
            [
                _radioA,
                _radioB,
                _slot
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _checkBatteryAction = [
            format [
                "UKSF_PRC163_CheckBattery_%1",
                _slot
            ],
            "Check Battery",
            _batteryPicture,
            _checkBatteryStatement,
            _batteryCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _replaceBatteryAction = [
            format [
                "UKSF_PRC163_ReplaceBattery_%1",
                _slot
            ],
            "Replace Battery",
            _batteryPicture,
            _replaceBatteryStatement,
            _replaceBatteryCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _batteryAction = [
            format [
                "UKSF_PRC163_Battery_%1",
                _slot
            ],
            "Battery",
            _batteryPicture,
            {},
            _batteryCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _radioAction = [
            format [
                "UKSF_PRC163_Radio_%1",
                _slot
            ],
            format [
                "AN/PRC-163 %1",
                _slot
            ],
            _radioPicture,
            {},
            _pairCondition,
            {},
            [
                _radioA,
                _radioB
            ]
        ] call ace_interact_menu_fnc_createAction;

        private _audioAChildren = [];

        if (_spatialA isNotEqualTo "RIGHT") then {
            _audioAChildren pushBack [
                _rightEarAAction,
                [],
                _target
            ];
        };

        if (_spatialA isNotEqualTo "BOTH") then {
            _audioAChildren pushBack [
                _bothEarsAAction,
                [],
                _target
            ];
        };

        if (_spatialA isNotEqualTo "LEFT") then {
            _audioAChildren pushBack [
                _leftEarAAction,
                [],
                _target
            ];
        };

        private _audioBChildren = [];

        if (_spatialB isNotEqualTo "RIGHT") then {
            _audioBChildren pushBack [
                _rightEarBAction,
                [],
                _target
            ];
        };

        if (_spatialB isNotEqualTo "BOTH") then {
            _audioBChildren pushBack [
                _bothEarsBAction,
                [],
                _target
            ];
        };

        if (_spatialB isNotEqualTo "LEFT") then {
            _audioBChildren pushBack [
                _leftEarBAction,
                [],
                _target
            ];
        };

        private _rtAChildren = [
            [
                _selectAAction,
                [],
                _target
            ],
            [
                _audioAAction,
                _audioAChildren,
                _target
            ]
        ];

        private _rtBChildren = [
            [
                _selectBAction,
                [],
                _target
            ],
            [
                _audioBAction,
                _audioBChildren,
                _target
            ]
        ];

        private _batteryChildren = [
            [
                _checkBatteryAction,
                [],
                _target
            ],
            [
                _replaceBatteryAction,
                [],
                _target
            ]
        ];

        private _pairChildren = [
            [
                _openAction,
                [],
                _target
            ],
            [
                _rtAAction,
                _rtAChildren,
                _target
            ],
            [
                _rtBAction,
                _rtBChildren,
                _target
            ],
            [
                _dualWatchAction,
                [],
                _target
            ],
            [
                _batteryAction,
                _batteryChildren,
                _target
            ],
            [
                _statusAction,
                [],
                _target
            ]
        ];

        _radioChildren pushBack [
            _radioAction,
            _pairChildren,
            _target
        ];
    } forEach _pairEntries;

    _radioChildren
};

missionNamespace setVariable [
    "UKSF_PRC163_interactionChildren",
    _insertRadioChildren
];

true
