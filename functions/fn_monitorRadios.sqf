if (!hasInterface) exitWith {};

[{
    if (isNull player) exitWith {};

    private _enabled = missionNamespace getVariable [
        "UKSF_PRC163_SingleInstancePilot",
        false
    ];

    private _prefix = "acre_prc163_id_";
    private _map = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _pending = missionNamespace getVariable [
        "UKSF_PRC163_companionPending",
        createHashMap
    ];

    private _cleanupEndpoint = {
        params [
            "_primary",
            "_entry"
        ];

        private _companion = toLower (
            _entry param [
                0,
                "",
                [""]
            ]
        );

        private _rackId = toLower (
            _entry param [
                1,
                "",
                [""]
            ]
        );

        private _currentRadio = toLower (
            [] call acre_api_fnc_getCurrentRadio
        );

        if (
            _currentRadio isEqualTo _companion &&
            {!(_primary isEqualTo "")}
        ) then {
            [
                _primary
            ] call acre_api_fnc_setCurrentRadio;
        };

        if !(_companion isEqualTo "") then {
            [
                player,
                player,
                _companion
            ] call acre_sys_rack_fnc_stopUsingMountedRadio;

            [
                _companion,
                "setState",
                [
                    "prc163PrimaryRadio",
                    ""
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _companion,
                "setState",
                [
                    "prc163CompanionRadio",
                    ""
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _companion,
                "setState",
                [
                    "prc163CompanionRack",
                    ""
                ]
            ] call acre_sys_data_fnc_dataEvent;
        };

        if !(_rackId isEqualTo "") then {
            [
                _rackId,
                "setState",
                [
                    "mountedRadio",
                    ""
                ]
            ] call acre_sys_data_fnc_dataEvent;

            private _vehicleRacks = player getVariable [
                "acre_sys_rack_vehicleRacks",
                []
            ];

            _vehicleRacks = _vehicleRacks select {
                toLower _x isNotEqualTo _rackId
            };

            player setVariable [
                "acre_sys_rack_vehicleRacks",
                _vehicleRacks,
                true
            ];

            {
                if (
                    toLower (
                        typeOf _x
                    ) isEqualTo _rackId
                ) then {
                    deleteVehicle _x;
                };
            } forEach (
                nearestObjects [
                    [
                        -1000,
                        -1000,
                        -1000
                    ],
                    [
                        "ACRE_baseRack"
                    ],
                    2,
                    true
                ]
            );
        };

        if !(_primary isEqualTo "") then {
            [
                _primary,
                "setState",
                [
                    "prc163CompanionRadio",
                    ""
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _primary,
                "setState",
                [
                    "prc163CompanionRack",
                    ""
                ]
            ] call acre_sys_data_fnc_dataEvent;
        };
    };

    if (!_enabled) exitWith {
        {
            private _entry = _map getOrDefault [
                _x,
                []
            ];

            [
                _x,
                _entry
            ] call _cleanupEndpoint;
        } forEach (
            keys _map
        );

        missionNamespace setVariable [
            "UKSF_PRC163_endpointMap",
            createHashMap
        ];

        missionNamespace setVariable [
            "UKSF_PRC163_companionPending",
            createHashMap
        ];

        missionNamespace setVariable [
            "UKSF_PRC163_companionStatus",
            "DISABLED"
        ];
    };

    private _rackFunctionsAvailable = (
        !(isNil "acre_sys_rack_fnc_addRack") &&
        {!(isNil "acre_sys_rack_fnc_getMountedRadio")} &&
        {!(isNil "acre_sys_rack_fnc_getVehicleFromRack")} &&
        {!(isNil "acre_sys_rack_fnc_startUsingMountedRadio")} &&
        {!(isNil "acre_sys_rack_fnc_stopUsingMountedRadio")}
    );

    if (!_rackFunctionsAvailable) exitWith {
        missionNamespace setVariable [
            "UKSF_PRC163_companionStatus",
            "ACRE RACK FUNCTIONS UNAVAILABLE"
        ];
    };

    private _gear = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    private _primaries = _gear select {
        _x find _prefix isEqualTo 0
    };

    _primaries sort true;

    {
        private _primary = _x;

        if !(_primary in _primaries) then {
            private _entry = _map getOrDefault [
                _primary,
                []
            ];

            [
                _primary,
                _entry
            ] call _cleanupEndpoint;

            _map deleteAt _primary;
            _pending deleteAt _primary;
        };
    } forEach (
        keys _map
    );

    private _rackIds = player getVariable [
        "acre_sys_rack_vehicleRacks",
        []
    ];

    {
        private _primary = _x;
        private _rackName = format [
            "UKSF PRC163 RT2 %1",
            toUpper _primary
        ];

        private _entry = _map getOrDefault [
            _primary,
            []
        ];

        private _companion = toLower (
            _entry param [
                0,
                "",
                [""]
            ]
        );

        private _rackId = toLower (
            _entry param [
                1,
                "",
                [""]
            ]
        );

        private _entryValid = false;

        if (
            !(_companion isEqualTo "") &&
            {!(_rackId isEqualTo "")}
        ) then {
            private _rackPresent = (
                _rackIds findIf {
                    toLower _x isEqualTo _rackId
                }
            ) >= 0;

            private _mounted = if (_rackPresent) then {
                toLower (
                    [
                        _rackId
                    ] call acre_sys_rack_fnc_getMountedRadio
                )
            } else {
                ""
            };

            private _owner = if (_rackPresent) then {
                [
                    _rackId
                ] call acre_sys_rack_fnc_getVehicleFromRack
            } else {
                objNull
            };

            _entryValid = (
                _rackPresent &&
                {_mounted isEqualTo _companion} &&
                {_owner isEqualTo player}
            );
        };

        if (!_entryValid) then {
            if (_entry isNotEqualTo []) then {
                [
                    _primary,
                    _entry
                ] call _cleanupEndpoint;

                _map deleteAt _primary;
            };

            _companion = "";
            _rackId = "";

            {
                private _candidateRack = _x;
                private _candidateName = [
                    _candidateRack,
                    "getState",
                    "name"
                ] call acre_sys_data_fnc_dataEvent;

                if (
                    isNil "_candidateName"
                ) then {
                    _candidateName = "";
                };

                if (
                    _rackId isEqualTo "" &&
                    {_candidateName isEqualTo _rackName}
                ) then {
                    private _candidateRadio = toLower (
                        [
                            _candidateRack
                        ] call acre_sys_rack_fnc_getMountedRadio
                    );

                    private _candidateOwner = [
                        _candidateRack
                    ] call acre_sys_rack_fnc_getVehicleFromRack;

                    if (
                        _candidateRadio find _prefix isEqualTo 0 &&
                        {_candidateOwner isEqualTo player}
                    ) then {
                        _rackId = toLower _candidateRack;
                        _companion = _candidateRadio;
                    };
                };
            } forEach _rackIds;

            if (
                _rackId isEqualTo "" ||
                {_companion isEqualTo ""}
            ) then {
                private _requestedAt = _pending getOrDefault [
                    _primary,
                    -100
                ];

                if (
                    diag_tickTime - _requestedAt >= 15
                ) then {
                    player setVariable [
                        "acre_sys_rack_initPlayer",
                        player,
                        true
                    ];

                    [
                        player,
                        "ACRE_VRC110",
                        _rackName,
                        "RT2",
                        false,
                        [
                            "external"
                        ],
                        [],
                        "ACRE_PRC163",
                        [],
                        []
                    ] call acre_sys_rack_fnc_addRack;

                    _pending set [
                        _primary,
                        diag_tickTime
                    ];
                };
            } else {
                _map set [
                    _primary,
                    [
                        _companion,
                        _rackId
                    ]
                ];

                _pending deleteAt _primary;
            };
        };

        if (
            !(_companion isEqualTo "") &&
            {!(_rackId isEqualTo "")}
        ) then {
            [
                _rackId,
                "setState",
                [
                    "allowed",
                    [
                        "external"
                    ]
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _rackId,
                "setState",
                [
                    "disabled",
                    []
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _companion,
                "setState",
                [
                    "powerSource",
                    "BAT"
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _primary,
                "setState",
                [
                    "prc163PrimaryRadio",
                    _primary
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _primary,
                "setState",
                [
                    "prc163CompanionRadio",
                    _companion
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _primary,
                "setState",
                [
                    "prc163CompanionRack",
                    _rackId
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _primary,
                "setState",
                [
                    "prc163EndpointLine",
                    0
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _companion,
                "setState",
                [
                    "prc163PrimaryRadio",
                    _primary
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _companion,
                "setState",
                [
                    "prc163CompanionRadio",
                    _companion
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _companion,
                "setState",
                [
                    "prc163CompanionRack",
                    _rackId
                ]
            ] call acre_sys_data_fnc_dataEvent;

            [
                _companion,
                "setState",
                [
                    "prc163EndpointLine",
                    1
                ]
            ] call acre_sys_data_fnc_dataEvent;

            private _radioList = (
                [] call acre_api_fnc_getCurrentRadioList
            ) apply {
                toLower _x
            };

            if !(_companion in _radioList) then {
                private _oldActive = [] call acre_api_fnc_getCurrentRadio;

                if (
                    isNil "_oldActive"
                ) then {
                    _oldActive = "";
                };

                [
                    player,
                    player,
                    _companion
                ] call acre_sys_rack_fnc_startUsingMountedRadio;

                if (
                    !(_oldActive isEqualTo "") &&
                    {
                        toLower _oldActive
                        in (
                            (
                                [] call acre_api_fnc_getCurrentRadioList
                            ) apply {
                                toLower _x
                            }
                        )
                    }
                ) then {
                    [
                        _oldActive
                    ] call acre_api_fnc_setCurrentRadio;
                } else {
                    [
                        _primary
                    ] call acre_api_fnc_setCurrentRadio;
                };
            };
        };
    } forEach _primaries;

    missionNamespace setVariable [
        "UKSF_PRC163_endpointMap",
        _map
    ];

    missionNamespace setVariable [
        "UKSF_PRC163_companionPending",
        _pending
    ];

    missionNamespace setVariable [
        "UKSF_PRC163_companionStatus",
        format [
            "ACTIVE %1/%2",
            count (
                keys _map
            ),
            count _primaries
        ]
    ];
},0.5] call CBA_fnc_addPerFrameHandler;

[{
    if (isNull player) exitWith {};

    private _pilotEnabled = missionNamespace getVariable [
        "UKSF_PRC163_SingleInstancePilot",
        false
    ];

    if (_pilotEnabled) exitWith {
        private _now = diag_tickTime;
        private _prefix = "acre_prc163_id_";

        private _drainTimes = missionNamespace getVariable [
            "UKSF_PRC163_batteryDrainTimes",
            createHashMap
        ];

        private _radios = (
            [player] call acre_sys_core_fnc_getGear
        ) apply {
            toLower _x
        };

        _radios = _radios select {
            _x find _prefix isEqualTo 0
        };

        _radios sort true;

        if (
            _radios isNotEqualTo [] &&
            {
                !(
                    missionNamespace getVariable [
                        "UKSF_PRC163_batteryLoadRequested",
                        false
                    ]
                )
            }
        ) then {
            missionNamespace setVariable [
                "UKSF_PRC163_batteryLoadRequested",
                true
            ];

            [
                player
            ] remoteExecCall [
                "UKSF_PRC163_fnc_serverLoadBatteryRecords",
                2
            ];
        };

        private _lastLoad = missionNamespace getVariable [
            "UKSF_PRC163_lastBatteryLoad",
            [[],false]
        ];

        private _loadedRecords = _lastLoad param [
            0,
            [],
            [[]]
        ];

        private _map = missionNamespace getVariable [
            "UKSF_PRC163_endpointMap",
            createHashMap
        ];

        private _processed = 0;
        private _shutdown = 0;

        {
            private _radioA = _x;
            private _entry = _map getOrDefault [
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

            if (
                !(_radioB isEqualTo "") &&
                {_radioB find _prefix isEqualTo 0}
            ) then {
                private _pairRadios = [
                    _radioA,
                    _radioB
                ];

                private _initialized = [
                    _radioA,
                    "getState",
                    "prc163Initialized"
                ] call acre_sys_data_fnc_dataEvent;

                if (
                    isNil "_initialized" ||
                    {!_initialized}
                ) then {
                    [
                        _radioA
                    ] call UKSF_PRC163_fnc_initializeState;
                };

                private _batteryInitialized = [
                    _radioA,
                    "getState",
                    "prc163BatteryInitialized"
                ] call acre_sys_data_fnc_dataEvent;

                if (
                    isNil "_batteryInitialized" ||
                    {!_batteryInitialized}
                ) then {
                    [
                        _radioA,
                        []
                    ] call UKSF_PRC163_fnc_initializeBatteryState;

                    private _slot = [
                        _radioA
                    ] call UKSF_PRC163_fnc_getBatterySlot;

                    private _recordIndex = _loadedRecords findIf {
                        (
                            _x param [
                                0,
                                -1,
                                [0]
                            ]
                        ) isEqualTo _slot
                    };

                    if (_recordIndex >= 0) then {
                        private _record = (
                            _loadedRecords select _recordIndex
                        );

                        [
                            _radioA,
                            [
                                _record param [1,1,[0]],
                                _record param [2,"",[""]],
                                _record param [3,1,[0]],
                                _record param [4,1,[0]]
                            ]
                        ] call UKSF_PRC163_fnc_initializeBatteryState;
                    };
                };

                private _lastDrain = _drainTimes get _radioA;

                if (isNil "_lastDrain") then {
                    _lastDrain = _now;
                };

                private _elapsed = (
                    (
                        _now - _lastDrain
                    ) max 0
                ) min 5;

                _drainTimes set [
                    _radioA,
                    _now
                ];

                if (_elapsed > 0) then {
                    [
                        _radioA,
                        _elapsed
                    ] call UKSF_PRC163_fnc_drainBattery;
                };

                private _hasBattery = [
                    _radioA
                ] call UKSF_PRC163_fnc_hasUsableBattery;

                private _poweredIndex = _pairRadios findIf {
                    private _powerState = [
                        _x,
                        "getOnOffState"
                    ] call acre_sys_data_fnc_dataEvent;

                    _powerState isEqualTo 1 ||
                    {_powerState isEqualTo true}
                };

                if (
                    !_hasBattery &&
                    {_poweredIndex >= 0}
                ) then {
                    private _rememberedPTT = toLower (
                        missionNamespace getVariable [
                            "UKSF_PRC163_pttRadio",
                            ""
                        ]
                    );

                    private _pttIndex = _pairRadios findIf {
                        private _pttDown = [
                            _x,
                            "getState",
                            "prc163PTTDown"
                        ] call acre_sys_data_fnc_dataEvent;

                        _pttDown isEqualTo 1
                    };

                    if (
                        _rememberedPTT in _pairRadios ||
                        {_pttIndex >= 0}
                    ) then {
                        private _releaseRadio = if (
                            _rememberedPTT in _pairRadios
                        ) then {
                            _rememberedPTT
                        } else {
                            _pairRadios select _pttIndex
                        };

                        [
                            _releaseRadio
                        ] call UKSF_PRC163_fnc_handlePTTUp;
                    };

                    {
                        [
                            _x,
                            "setOnOffState",
                            0
                        ] call acre_sys_data_fnc_dataEvent;

                        [
                            _x,
                            "setState",
                            [
                                "prc163PTTDown",
                                0
                            ]
                        ] call acre_sys_data_fnc_dataEvent;

                        [
                            _x,
                            "setState",
                            [
                                "prc163ReceivingA",
                                0
                            ]
                        ] call acre_sys_data_fnc_dataEvent;

                        [
                            _x,
                            "setState",
                            [
                                "prc163ReceivingB",
                                0
                            ]
                        ] call acre_sys_data_fnc_dataEvent;

                        [
                            _x,
                            "setState",
                            [
                                "prc163TransmittingA",
                                0
                            ]
                        ] call acre_sys_data_fnc_dataEvent;

                        [
                            _x,
                            "setState",
                            [
                                "prc163TransmittingB",
                                0
                            ]
                        ] call acre_sys_data_fnc_dataEvent;
                    } forEach _pairRadios;

                    private _warnedIndex = _pairRadios findIf {
                        private _warned = [
                            _x,
                            "getState",
                            "prc163BatteryShutdownWarned"
                        ] call acre_sys_data_fnc_dataEvent;

                        _warned isEqualTo 1
                    };

                    if (_warnedIndex < 0) then {
                        private _slot = [
                            _radioA,
                            player
                        ] call UKSF_PRC163_fnc_getBatterySlot;

                        private _slotText = if (_slot > 0) then {
                            str _slot
                        } else {
                            "?"
                        };

                        [
                            format [
                                "<t align='center'>AN/PRC-163 %1<br/><t size='0.85'>BATTERY DEPLETED - RADIO OFF</t></t>",
                                _slotText
                            ],
                            1.5,
                            player,
                            10
                        ] call UKSF_PRC163_fnc_notifyStatus;
                    };

                    {
                        [
                            _x,
                            "setState",
                            [
                                "prc163BatteryShutdownWarned",
                                1
                            ]
                        ] call acre_sys_data_fnc_dataEvent;
                    } forEach _pairRadios;

                    [
                        false
                    ] call UKSF_PRC163_fnc_saveBatteryRecords;

                    _shutdown = _shutdown + 1;
                };

                _processed = _processed + 1;
            };
        } forEach _radios;

        {
            if !(_x in _radios) then {
                _drainTimes deleteAt _x;
            };
        } forEach (
            keys _drainTimes
        );

        missionNamespace setVariable [
            "UKSF_PRC163_batteryDrainTimes",
            _drainTimes
        ];

        missionNamespace setVariable [
            "UKSF_PRC163_lastPilotBatteryTick",
            [
                _now,
                count _radios,
                _processed,
                _shutdown
            ]
        ];
    };

    private _now = diag_tickTime;

    private _drainTimes = missionNamespace getVariable [
        "UKSF_PRC163_batteryDrainTimes",
        createHashMap
    ];

    private _gearRadios = [player] call acre_sys_core_fnc_getGear;

    private _radios = _gearRadios select {
        _x find "acre_prc163_id_" == 0
    };

    if (
        !isNil "acre_api_fnc_getMultiPushToTalkAssignment" &&
        {!isNil "acre_api_fnc_setMultiPushToTalkAssignment"}
    ) then {
        private _prefix = "acre_prc163_id_";
        private _availableRadios = [];

        {
            private _radioId = toLower _x;

            if !(_radioId isEqualTo "") then {
                _availableRadios pushBackUnique _radioId;
            };
        } forEach (
            _gearRadios +
            (
                [] call acre_api_fnc_getCurrentRadioList
            )
        );

        private _assignments = (
            [] call acre_api_fnc_getMultiPushToTalkAssignment
        ) apply {
            toLower _x
        };

        private _actualPTT = _assignments select [
            0,
            (count _assignments) min 3
        ];

        private _currentRadio = [] call acre_api_fnc_getCurrentRadio;

        if !(_currentRadio isEqualType "") then {
            _currentRadio = "";
        };

        _currentRadio = toLower _currentRadio;

        private _activeRadio = missionNamespace getVariable [
            "UKSF_PRC163_activeRadio",
            _currentRadio
        ];

        if !(_activeRadio isEqualType "") then {
            _activeRadio = _currentRadio;
        };

        _activeRadio = toLower _activeRadio;

        if !(_activeRadio in _availableRadios) then {
            _activeRadio = _currentRadio;
        };

        private _endpointMap = missionNamespace getVariable [
            "UKSF_PRC163_endpointMap",
            createHashMap
        ];

        private _resolvePair = {
            params [
                ["_sourceRadio","",[""]]
            ];

            private _radioA = "";
            private _radioB = "";

            _sourceRadio = toLower _sourceRadio;

            if (
                !(_sourceRadio isEqualTo "") &&
                {_sourceRadio find _prefix isEqualTo 0}
            ) then {
                private _statePrimary = [
                    _sourceRadio,
                    "getState",
                    "prc163PrimaryRadio"
                ] call acre_sys_data_fnc_dataEvent;

                if (
                    !isNil "_statePrimary" &&
                    {_statePrimary isEqualType ""}
                ) then {
                    _radioA = toLower _statePrimary;
                };

                private _stateCompanion = [
                    _sourceRadio,
                    "getState",
                    "prc163CompanionRadio"
                ] call acre_sys_data_fnc_dataEvent;

                if (
                    !isNil "_stateCompanion" &&
                    {_stateCompanion isEqualType ""}
                ) then {
                    _radioB = toLower _stateCompanion;
                };
            };

            if (
                _radioA isEqualTo "" ||
                {_radioB isEqualTo ""}
            ) then {
                private _entry = _endpointMap getOrDefault [
                    _sourceRadio,
                    []
                ];

                if !(_entry isEqualTo []) then {
                    _radioA = _sourceRadio;
                    _radioB = toLower (
                        _entry param [
                            0,
                            "",
                            [""]
                        ]
                    );
                } else {
                    private _mapKeys = keys _endpointMap;
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
                        ) isEqualTo _sourceRadio
                    };

                    if (_primaryIndex >= 0) then {
                        _radioA = toLower (
                            _mapKeys select _primaryIndex
                        );

                        private _primaryEntry = _endpointMap getOrDefault [
                            _radioA,
                            []
                        ];

                        _radioB = toLower (
                            _primaryEntry param [
                                0,
                                "",
                                [""]
                            ]
                        );
                    };
                };
            };

            if (
                _radioA isEqualTo "" ||
                {_radioB isEqualTo ""} ||
                {_radioA isEqualTo _radioB} ||
                {!(_radioA in _availableRadios)} ||
                {!(_radioB in _availableRadios)}
            ) then {
                _radioA = "";
                _radioB = "";
            };

            [
                _radioA,
                _radioB
            ]
        };

        private _pair = [
            _activeRadio
        ] call _resolvePair;

        if (
            (_pair select 0) isEqualTo "" ||
            {(_pair select 1) isEqualTo ""}
        ) then {
            _pair = [
                _currentRadio
            ] call _resolvePair;
        };

        if (
            (_pair select 0) isEqualTo "" ||
            {(_pair select 1) isEqualTo ""}
        ) then {
            private _mapKeys = keys _endpointMap;
            _mapKeys sort true;

            {
                if (
                    (_pair select 0) isEqualTo "" ||
                    {(_pair select 1) isEqualTo ""}
                ) then {
                    private _candidatePair = [
                        _x
                    ] call _resolvePair;

                    if (
                        !(
                            (_candidatePair select 0) isEqualTo ""
                        ) &&
                        {
                            !(
                                (_candidatePair select 1) isEqualTo ""
                            )
                        }
                    ) then {
                        _pair = _candidatePair;
                    };
                };
            } forEach _mapKeys;
        };

        private _radioA = _pair select 0;
        private _radioB = _pair select 1;

        if (
            !(_radioA isEqualTo "") &&
            {!(_radioB isEqualTo "")}
        ) then {
            private _desiredPTT = [
                _radioA,
                _radioB
            ];

            private _thirdIndex = _assignments findIf {
                !(_x in _desiredPTT) &&
                {_x in _availableRadios}
            };

            if (_thirdIndex >= 0) then {
                _desiredPTT pushBack (
                    _assignments select _thirdIndex
                );
            };

            if (_actualPTT isNotEqualTo _desiredPTT) then {
                private _setResult = [
                    _desiredPTT
                ] call acre_api_fnc_setMultiPushToTalkAssignment;

                if (isNil "_setResult") then {
                    _setResult = false;
                };

                if (_setResult isEqualTo true) then {
                    missionNamespace setVariable [
                        "UKSF_PRC163_multiPTTSignature",
                        str [
                            _availableRadios,
                            _desiredPTT
                        ]
                    ];
                };
            } else {
                missionNamespace setVariable [
                    "UKSF_PRC163_multiPTTSignature",
                    str [
                        _availableRadios,
                        _actualPTT
                    ]
                ];
            };
        } else {
            missionNamespace setVariable [
                "UKSF_PRC163_multiPTTSignature",
                str [
                    _availableRadios,
                    _actualPTT
                ]
            ];
        };
    };

    if (
        _radios isNotEqualTo [] &&
        {
            !(missionNamespace getVariable [
                "UKSF_PRC163_batteryLoadRequested",
                false
            ])
        }
    ) then {
        missionNamespace setVariable [
            "UKSF_PRC163_batteryLoadRequested",
            true
        ];

        [player] remoteExecCall [
            "UKSF_PRC163_fnc_serverLoadBatteryRecords",
            2
        ];
    };

    private _lastLoad = missionNamespace getVariable [
        "UKSF_PRC163_lastBatteryLoad",
        [[],false]
    ];

    private _loadedRecords = _lastLoad param [0,[],[[]]];

    {
        private _radioId = toLower _x;

        private _initialized = [
            _radioId,
            "getState",
            "prc163Initialized"
        ] call acre_sys_data_fnc_dataEvent;

        if (
            isNil "_initialized" ||
            {!_initialized}
        ) then {
            [_radioId] call UKSF_PRC163_fnc_initializeState;
        };

        private _batteryInitialized = [
            _radioId,
            "getState",
            "prc163BatteryInitialized"
        ] call acre_sys_data_fnc_dataEvent;

        if (
            isNil "_batteryInitialized" ||
            {!_batteryInitialized}
        ) then {
            [
                _radioId,
                []
            ] call UKSF_PRC163_fnc_initializeBatteryState;

            private _slot = [
                _radioId
            ] call UKSF_PRC163_fnc_getBatterySlot;

            private _recordIndex = _loadedRecords findIf {
                (_x param [0,-1,[0]]) isEqualTo _slot
            };

            if (_recordIndex >= 0) then {
                private _record = _loadedRecords select _recordIndex;

                [
                    _radioId,
                    [
                        _record param [1,1,[0]],
                        _record param [2,"",[""]],
                        _record param [3,1,[0]],
                        _record param [4,1,[0]]
                    ]
                ] call UKSF_PRC163_fnc_initializeBatteryState;
            };
        };

        private _lastDrain = _drainTimes get _radioId;

        if (isNil "_lastDrain") then {
            _lastDrain = _now;
        };

        private _elapsed = ((_now - _lastDrain) max 0) min 5;

        _drainTimes set [
            _radioId,
            _now
        ];

        if (_elapsed > 0) then {
            [
                _radioId,
                _elapsed
            ] call UKSF_PRC163_fnc_drainBattery;
        };

        private _parts = _radioId splitString "_";

        private _number = parseNumber (
            _parts select ((count _parts) - 1)
        );

        if (
            _number > 0 &&
            {(_number mod 2) isEqualTo 1}
        ) then {
            private _radioB = format [
                "acre_prc163_id_%1",
                _number + 1
            ];

            if (_radioB in _radios) then {
                private _pairRadios = [
                    _radioId,
                    _radioB
                ];

                private _hasBattery = [
                    _radioId
                ] call UKSF_PRC163_fnc_hasUsableBattery;

                private _poweredIndex = _pairRadios findIf {
                    private _powerState = [
                        _x,
                        "getOnOffState"
                    ] call acre_sys_data_fnc_dataEvent;

                    _powerState isEqualTo 1 ||
                    {_powerState isEqualTo true}
                };

                if (!_hasBattery) then {
                    if (_poweredIndex >= 0) then {
                        private _rememberedPTT = toLower (
                            missionNamespace getVariable [
                                "UKSF_PRC163_pttRadio",
                                ""
                            ]
                        );

                        private _pttIndex = _pairRadios findIf {
                            private _pttDown = [
                                _x,
                                "getState",
                                "prc163PTTDown"
                            ] call acre_sys_data_fnc_dataEvent;

                            _pttDown isEqualTo 1
                        };

                        if (
                            _rememberedPTT in _pairRadios ||
                            {_pttIndex >= 0}
                        ) then {
                            private _releaseRadio = if (
                                _rememberedPTT in _pairRadios
                            ) then {
                                _rememberedPTT
                            } else {
                                _pairRadios select _pttIndex
                            };

                            [
                                _releaseRadio
                            ] call UKSF_PRC163_fnc_handlePTTUp;
                        };

                        {
                            [
                                _x,
                                "setOnOffState",
                                0
                            ] call acre_sys_data_fnc_dataEvent;

                            [
                                _x,
                                "setState",
                                ["prc163PTTDown",0]
                            ] call acre_sys_data_fnc_dataEvent;

                            [
                                _x,
                                "setState",
                                ["prc163ReceivingA",0]
                            ] call acre_sys_data_fnc_dataEvent;

                            [
                                _x,
                                "setState",
                                ["prc163ReceivingB",0]
                            ] call acre_sys_data_fnc_dataEvent;

                            [
                                _x,
                                "setState",
                                ["prc163TransmittingA",0]
                            ] call acre_sys_data_fnc_dataEvent;

                            [
                                _x,
                                "setState",
                                ["prc163TransmittingB",0]
                            ] call acre_sys_data_fnc_dataEvent;
                        } forEach _pairRadios;

                        private _warnedIndex = _pairRadios findIf {
                            private _warned = [
                                _x,
                                "getState",
                                "prc163BatteryShutdownWarned"
                            ] call acre_sys_data_fnc_dataEvent;

                            _warned isEqualTo 1
                        };

                        if (_warnedIndex < 0) then {
                            private _slot = [
                                _radioId,
                                player
                            ] call UKSF_PRC163_fnc_getBatterySlot;

                            private _slotText = if (_slot > 0) then {
                                str _slot
                            } else {
                                "?"
                            };

                            [
                                format [
                                    "<t align='center'>AN/PRC-163 %1<br/><t size='0.85'>BATTERY DEPLETED - RADIO OFF</t></t>",
                                    _slotText
                                ],
                                1.5,
                                player,
                                10
                            ] call UKSF_PRC163_fnc_notifyStatus;
                        };

                        {
                            [
                                _x,
                                "setState",
                                ["prc163BatteryShutdownWarned",1]
                            ] call acre_sys_data_fnc_dataEvent;
                        } forEach _pairRadios;

                        [
                            false
                        ] call UKSF_PRC163_fnc_saveBatteryRecords;
                    };
                };
            };
        };
    } forEach _radios;

    private _radioEntries = _radios apply {
        private _id = toLower _x;
        private _parts = _id splitString "_";

        private _number = parseNumber (
            _parts select ((count _parts) - 1)
        );

        [_number,_id]
    };

    _radioEntries sort true;

    private _currentRadio = toLower (
        [] call acre_api_fnc_getCurrentRadio
    );

    {
        _x params [
            "_numberA",
            "_radioA"
        ];

        if ((_numberA mod 2) isEqualTo 1) then {
            private _radioBIndex = _radioEntries findIf {
                (_x select 0) isEqualTo (_numberA + 1)
            };

            if (_radioBIndex >= 0) then {
                private _radioB = (
                    _radioEntries select _radioBIndex
                ) select 1;

                private _channelA = [
                    _radioA,
                    "getCurrentChannel"
                ] call acre_sys_data_fnc_dataEvent;

                private _channelB = [
                    _radioB,
                    "getCurrentChannel"
                ] call acre_sys_data_fnc_dataEvent;

                private _selectedLine = if (
                    _currentRadio isEqualTo _radioA
                ) then {
                    0
                } else {
                    if (
                        _currentRadio isEqualTo _radioB
                    ) then {
                        1
                    } else {
                        private _storedLine = [
                            _radioA,
                            "getState",
                            "prc163SelectedLine"
                        ] call acre_sys_data_fnc_dataEvent;

                        if (_storedLine in [0,1]) then {
                            _storedLine
                        } else {
                            0
                        }
                    }
                };

                {
                    if (
                        _channelA isEqualType 0 &&
                        {_channelA >= 0}
                    ) then {
                        [
                            _x,
                            "setState",
                            ["prc163ChannelA",_channelA]
                        ] call acre_sys_data_fnc_dataEvent;
                    };

                    if (
                        _channelB isEqualType 0 &&
                        {_channelB >= 0}
                    ) then {
                        [
                            _x,
                            "setState",
                            ["prc163ChannelB",_channelB]
                        ] call acre_sys_data_fnc_dataEvent;
                    };

                    [
                        _x,
                        "setState",
                        ["prc163SelectedLine",_selectedLine]
                    ] call acre_sys_data_fnc_dataEvent;
                } forEach [
                    _radioA,
                    _radioB
                ];
            };
        };
    } forEach _radioEntries;

    missionNamespace setVariable [
        "UKSF_PRC163_batteryDrainTimes",
        _drainTimes
    ];
},1] call CBA_fnc_addPerFrameHandler;

[{
    if (isNull player) exitWith {};

    private _loadRequested = missionNamespace getVariable [
        "UKSF_PRC163_batteryLoadRequested",
        false
    ];

    if (!_loadRequested) exitWith {};

    [
        false
    ] call UKSF_PRC163_fnc_saveBatteryRecords;
},60] call CBA_fnc_addPerFrameHandler;

addMissionEventHandler [
    "MPEnded",
    {
        if (
            hasInterface &&
            {!isNull player}
        ) then {
            [
                true
            ] call UKSF_PRC163_fnc_saveBatteryRecords;
        };
    }
];