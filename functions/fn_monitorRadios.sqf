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
                        [
                            "AN/PRC-163 | BATTERY DEPLETED | RADIO OFF",
                            1.5,
                            [1,0.35,0.2,1],
                            true
                        ] call CBA_fnc_notify;
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
        private _gearLower = _gearRadios apply {
            toLower _x
        };

        private _sortedGear = +_gearLower;
        _sortedGear sort true;

        private _assignments = (
            [] call acre_api_fnc_getMultiPushToTalkAssignment
        ) apply {
            toLower _x
        };

        private _actualPTT = _assignments select [
            0,
            (count _assignments) min 3
        ];

        private _signature = str [
            _sortedGear,
            _actualPTT
        ];

        private _lastSignature = missionNamespace getVariable [
            "UKSF_PRC163_multiPTTSignature",
            ""
        ];

        if (_signature isNotEqualTo _lastSignature) then {
            private _collapsed = [];
            private _hasCompletePair = false;

            {
                private _radioId = _x;

                if (_radioId find "acre_prc163_id_" == 0) then {
                    private _parts = _radioId splitString "_";

                    private _number = parseNumber (
                        _parts select ((count _parts) - 1)
                    );

                    if (_number > 0) then {
                        private _oddNumber = if (
                            (_number mod 2) isEqualTo 0
                        ) then {
                            _number - 1
                        } else {
                            _number
                        };

                        private _radioA = format [
                            "acre_prc163_id_%1",
                            _oddNumber
                        ];

                        private _radioB = format [
                            "acre_prc163_id_%1",
                            _oddNumber + 1
                        ];

                        if (
                            _radioA in _gearLower &&
                            {_radioB in _gearLower}
                        ) then {
                            _hasCompletePair = true;
                            _collapsed pushBackUnique _radioA;
                        } else {
                            _collapsed pushBackUnique _radioId;
                        };
                    } else {
                        _collapsed pushBackUnique _radioId;
                    };
                } else {
                    _collapsed pushBackUnique _radioId;
                };
            } forEach _assignments;

            private _desiredPTT = _collapsed select [
                0,
                (count _collapsed) min 3
            ];

            if (
                _hasCompletePair &&
                {_actualPTT isNotEqualTo _desiredPTT}
            ) then {
                private _setResult = [
                    _desiredPTT
                ] call acre_api_fnc_setMultiPushToTalkAssignment;

                if (isNil "_setResult") then {
                    _setResult = false;
                };

                if (_setResult isEqualTo true) then {
                    missionNamespace setVariable [
                        "UKSF_PRC163_multiPTTSignature",
                        str [_sortedGear,_desiredPTT]
                    ];
                };
            } else {
                missionNamespace setVariable [
                    "UKSF_PRC163_multiPTTSignature",
                    str [_sortedGear,_actualPTT]
                ];
            };
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
                            [
                                "AN/PRC-163 | BATTERY DEPLETED | RADIO OFF",
                                1.5,
                                [1,0.35,0.2,1],
                                true
                            ] call CBA_fnc_notify;
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