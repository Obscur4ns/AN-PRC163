if (!hasInterface) exitWith {};
if (
    isNil "UKSF_PRC163_staleRemoteSpeakingEH" &&
    {!(isNil "CBA_fnc_addEventHandler")}
) then {
    UKSF_PRC163_staleRemoteSpeakingEH = [
        "acre_remoteStartedSpeaking",
        {
            params ["_unit","_speakingType","_radioId"];

            if !(_radioId isEqualType "") exitWith {};
            _radioId = toLower _radioId;

            if (
                _radioId find "acre_prc163_id_" isEqualTo 0 &&
                {!(isNil "acre_sys_radio_fnc_radioExists")} &&
                {!([_radioId] call acre_sys_radio_fnc_radioExists)}
            ) then {
                private _now = diag_tickTime;
                private _last = missionNamespace getVariable [
                    "UKSF_PRC163_lastStaleRemoteSpeakingLog",
                    createHashMap
                ];
                private _lastAt = _last getOrDefault [_radioId,-10];

                if (_now - _lastAt >= 5) then {
                    _last set [_radioId,_now];
                    missionNamespace setVariable [
                        "UKSF_PRC163_lastStaleRemoteSpeakingLog",
                        _last
                    ];

                    diag_log format [
                        "UKSF_PRC163 STALE REMOTE RADIO: unit=%1 netId=%2 type=%3 radio=%4 map=%5 companions=%6",
                        if (isNull _unit) then {"<NULL>"} else {name _unit},
                        if (isNull _unit) then {""} else {netId _unit},
                        _speakingType,
                        _radioId,
                        missionNamespace getVariable [
                            "UKSF_PRC163_endpointMap",
                            createHashMap
                        ],
                        missionNamespace getVariable [
                            "UKSF_PRC163_companionRadios",
                            []
                        ]
                    ];
                };
            };
        }
    ] call CBA_fnc_addEventHandler;
};

[{
    if (isNull player) exitWith {};

    private _enabled = missionNamespace getVariable [
        "UKSF_PRC163_SingleInstancePilot",
        false
    ];

    private _prefix = "acre_prc163_id_";

    private _radioExists = {
        params [
            ["_radioId","",[""]]
        ];

        _radioId = toLower _radioId;

        if (
            _radioId isEqualTo "" ||
            {isNil "acre_sys_radio_fnc_radioExists"}
        ) exitWith {
            false
        };

        [
            _radioId
        ] call acre_sys_radio_fnc_radioExists
    };

    /*
        ACRE invalidates its speaking/radio cache whenever radio data is
        written. Reconciliation runs twice per second, so never emit a data
        write merely to reaffirm an already-correct value.
    */
    private _setStateIfChanged = {
        params [
            ["_radioId","",[""]],
            ["_stateName","",[""]],
            "_desired"
        ];

        if (
            _radioId isEqualTo "" ||
            {_stateName isEqualTo ""}
        ) exitWith {false};

        private _current = [
            _radioId,
            "getState",
            _stateName
        ] call acre_sys_data_fnc_dataEvent;

        if (
            !isNil "_current" &&
            {_current isEqualTo _desired}
        ) exitWith {false};

        [
            _radioId,
            "setState",
            [_stateName,_desired]
        ] call acre_sys_data_fnc_dataEvent;

        true
    };

    private _setCurrentChannelIfChanged = {
        params [
            ["_radioId","",[""]],
            ["_desired",-1,[0]]
        ];

        if (
            _radioId isEqualTo "" ||
            {_desired < 0}
        ) exitWith {false};

        private _current = [
            _radioId,
            "getCurrentChannel"
        ] call acre_sys_data_fnc_dataEvent;

        if (
            !isNil "_current" &&
            {_current isEqualType 0} &&
            {_current isEqualTo _desired}
        ) exitWith {false};

        [
            _radioId,
            "setCurrentChannel",
            _desired
        ] call acre_sys_data_fnc_dataEvent;

        true
    };

    private _map = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _pending = missionNamespace getVariable [
        "UKSF_PRC163_companionPending",
        createHashMap
    ];

    private _missingSince = missionNamespace getVariable [
        "UKSF_PRC163_primaryMissingSince",
        createHashMap
    ];

    if (isNil "ACRE_EXTERNALLY_USED_MANPACK_RADIOS") then {
        ACRE_EXTERNALLY_USED_MANPACK_RADIOS = [];
    };

    private _removeFromAcreLists = {
        params [
            ["_radioId","",[""]],
            ["_removeManpack",true,[true]],
            ["_removeBlocked",true,[true]]
        ];

        _radioId = toLower _radioId;

        if (_radioId isEqualTo "") exitWith {};

        if (
            _removeManpack &&
            {!(isNil "ACRE_EXTERNALLY_USED_MANPACK_RADIOS")}
        ) then {
            ACRE_EXTERNALLY_USED_MANPACK_RADIOS =
                ACRE_EXTERNALLY_USED_MANPACK_RADIOS - [_radioId];
        };

        if !(isNil "ACRE_ACCESSIBLE_RACK_RADIOS") then {
            ACRE_ACCESSIBLE_RACK_RADIOS =
                ACRE_ACCESSIBLE_RACK_RADIOS - [_radioId];
        };

        if !(isNil "ACRE_HEARABLE_RACK_RADIOS") then {
            ACRE_HEARABLE_RACK_RADIOS =
                ACRE_HEARABLE_RACK_RADIOS - [_radioId];
        };

        if !(isNil "ACRE_ACTIVE_EXTERNAL_RADIOS") then {
            ACRE_ACTIVE_EXTERNAL_RADIOS =
                ACRE_ACTIVE_EXTERNAL_RADIOS - [_radioId];
        };

        if !(isNil "ACRE_EXTERNALLY_USED_PERSONAL_RADIOS") then {
            ACRE_EXTERNALLY_USED_PERSONAL_RADIOS =
                ACRE_EXTERNALLY_USED_PERSONAL_RADIOS - [_radioId];
        };

        if (
            _removeBlocked &&
            {!(isNil "ACRE_BLOCKED_TRANSMITTING_RADIOS")}
        ) then {
            ACRE_BLOCKED_TRANSMITTING_RADIOS =
                ACRE_BLOCKED_TRANSMITTING_RADIOS - [_radioId];
        };
    };

    private _deleteRack = {
        params [
            ["_rackOwner",objNull,[objNull]],
            ["_rackId","",[""]],
            ["_rackName","",[""]]
        ];

        private _owners = [];

        if !(isNull _rackOwner) then {
            _owners pushBackUnique _rackOwner;
        };

        if !(isNull player) then {
            _owners pushBackUnique player;
        };

        {
            private _owner = _x;

            private _queue = _owner getVariable [
                "acre_sys_rack_queue",
                []
            ];

            if !(_rackName isEqualTo "") then {
                _queue = _queue select {
                    (_x param [1,"",[""]]) isNotEqualTo _rackName
                };

                _owner setVariable [
                    "acre_sys_rack_queue",
                    _queue
                ];
            };

            if !(_rackId isEqualTo "") then {
                private _racks = _owner getVariable [
                    "acre_sys_rack_vehicleRacks",
                    []
                ];

                _racks = _racks select {
                    toLower _x isNotEqualTo _rackId
                };

                _owner setVariable [
                    "acre_sys_rack_vehicleRacks",
                    _racks,
                    true
                ];
            };
        } forEach _owners;

        if !(_rackId isEqualTo "") then {
            private _mountedRadio = "";

            if !(isNil "acre_sys_rack_fnc_getMountedRadio") then {
                _mountedRadio = toLower (
                    [
                        _rackId
                    ] call acre_sys_rack_fnc_getMountedRadio
                );
            };

            /*
                Never immediately destroy a synthetic PRC-163 endpoint that has
                already been issued a unique ACRE ID. ACRE/TeamSpeak speaking
                updates can outlive local pair ownership; deleting the rack
                first can leave remote clients receiving a radio ID that no
                longer exists.

                The rack is removed from every usable rack list above, renamed
                so it can never be rediscovered as an active pair, and retained
                only as a mission-lifetime unique-ID tombstone.
            */
            private _mountedRadioExists = [
                _mountedRadio
            ] call _radioExists;

            if (
                _mountedRadio find _prefix isEqualTo 0 &&
                {_mountedRadioExists}
            ) then {
                [
                    _mountedRadio
                ] call _removeFromAcreLists;

                [
                    _rackId,
                    "setState",
                    [
                        "allowed",
                        []
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
                    _rackId,
                    "setState",
                    [
                        "name",
                        format [
                            "UKSF PRC163 RETIRED %1",
                            toUpper _mountedRadio
                        ]
                    ]
                ] call acre_sys_data_fnc_dataEvent;

                private _retired = missionNamespace getVariable [
                    "UKSF_PRC163_retiredCompanionIds",
                    []
                ];

                _retired pushBackUnique _mountedRadio;

                missionNamespace setVariable [
                    "UKSF_PRC163_retiredCompanionIds",
                    _retired
                ];

                diag_log format [
                    "UKSF_PRC163 ENDPOINT RETIRED: radio=%1 rack=%2 owner=%3",
                    _mountedRadio,
                    _rackId,
                    _rackOwner
                ];
            } else {
                [
                    _rackId,
                    "setState",
                    [
                        "mountedRadio",
                        ""
                    ]
                ] call acre_sys_data_fnc_dataEvent;

                {
                    if (toLower (typeOf _x) isEqualTo _rackId) then {
                        deleteVehicle _x;
                    };
                } forEach (
                    allMissionObjects "ACRE_baseRack"
                );
            };
        };
    };

    private _cleanupEndpoint = {
        params [
            ["_primary","",[""]],
            ["_entry",[],[[]]]
        ];

        _primary = toLower _primary;

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

        private _rackName = if (_primary isEqualTo "") then {
            ""
        } else {
            format [
                "UKSF PRC163 RT2 %1",
                toUpper _primary
            ]
        };

        private _rackOwner = if !(_rackId isEqualTo "") then {
            [
                _rackId
            ] call acre_sys_rack_fnc_getVehicleFromRack
        } else {
            objNull
        };

        private _primaryExists = [
            _primary
        ] call _radioExists;

        private _companionExists = [
            _companion
        ] call _radioExists;

        private _broadcast = toLower (
            missionNamespace getVariable [
                "ACRE_BROADCASTING_RADIOID",
                ""
            ]
        );

        private _remembered = toLower (
            missionNamespace getVariable [
                "UKSF_PRC163_pttRadio",
                ""
            ]
        );

        private _pairIds = [
            _primary,
            _companion
        ] select {
            _x find _prefix isEqualTo 0
        };

        private _pairReferenced = (
            _broadcast in _pairIds ||
            {_remembered in _pairIds}
        );

        if (
            _primaryExists &&
            {_companionExists} &&
            {_pairReferenced}
        ) then {
            [
                _primary,
                player,
                false,
                _companion
            ] call UKSF_PRC163_fnc_normalizePairState;
        };

        /*
            Ordinary PTT release leaves ACRE_BROADCASTING_RADIOID alone.
            Endpoint retirement is different. Even if ACRE has already
            garbage-collected one endpoint, retire local/TeamSpeak ownership
            without calling data events on that dead ID.
        */
        if (_pairReferenced) then {
            private _coreStillDown = missionNamespace getVariable [
                "acre_sys_core_pttKeyDown",
                false
            ];

            if (!_coreStillDown) then {
                if !(isNil "acre_sys_rpc_fnc_callRemoteProcedure") then {
                    [
                        "stopRadioSpeaking",
                        ","
                    ] call acre_sys_rpc_fnc_callRemoteProcedure;
                };

                private _broadcastAfter = toLower (
                    missionNamespace getVariable [
                        "ACRE_BROADCASTING_RADIOID",
                        ""
                    ]
                );

                if (_broadcastAfter in _pairIds) then {
                    missionNamespace setVariable [
                        "ACRE_BROADCASTING_RADIOID",
                        ""
                    ];
                };
            };

            if (_remembered in _pairIds) then {
                missionNamespace setVariable [
                    "UKSF_PRC163_pttHeld",
                    false
                ];

                missionNamespace setVariable [
                    "UKSF_PRC163_pttRadio",
                    nil
                ];

                missionNamespace setVariable [
                    "UKSF_PRC163_pttLine",
                    -1
                ];

                missionNamespace setVariable [
                    "UKSF_PRC163_pttPrimary",
                    nil
                ];

                missionNamespace setVariable [
                    "UKSF_PRC163_pttRestoreRadio",
                    nil
                ];

                missionNamespace setVariable [
                    "UKSF_PRC163_pttRestoreChannel",
                    nil
                ];
            };

            if !(isNil "ACRE_BLOCKED_TRANSMITTING_RADIOS") then {
                ACRE_BLOCKED_TRANSMITTING_RADIOS =
                    ACRE_BLOCKED_TRANSMITTING_RADIOS - _pairIds;
            };
        };

        private _currentRadioValue = [] call acre_api_fnc_getCurrentRadio;

        private _currentRadio = if (
            _currentRadioValue isEqualType ""
        ) then {
            toLower _currentRadioValue
        } else {
            ""
        };

        if (
            _currentRadio isEqualTo _companion &&
            {_primaryExists}
        ) then {
            [
                _primary
            ] call acre_api_fnc_setCurrentRadio;
        };

        private _guiRadioValue = uiNamespace getVariable [
            "UKSF_PRC163_guiRadio",
            ""
        ];

        private _guiRadio = if (
            _guiRadioValue isEqualType ""
        ) then {
            toLower _guiRadioValue
        } else {
            ""
        };

        if (_guiRadio in [_primary,_companion]) then {
            if !(isNull (findDisplay 16300)) then {
                closeDialog 0;
            };

            {
                if (
                    _x find _prefix isEqualTo 0 &&
                    {!isNil "acre_sys_radio_fnc_radioExists"} &&
                    {[_x] call acre_sys_radio_fnc_radioExists}
                ) then {
                    [
                        _x,
                        false
                    ] call acre_sys_radio_fnc_setRadioOpenState;
                };
            } forEach [
                _primary,
                _companion
            ];

            uiNamespace setVariable [
                "UKSF_PRC163_guiRadio",
                ""
            ];

            uiNamespace setVariable [
                "UKSF_PRC163_display",
                displayNull
            ];
        };

        if !(_companion isEqualTo "") then {
            [
                _companion
            ] call _removeFromAcreLists;
        };

        if (
            !_primaryExists &&
            {!(_primary isEqualTo "")}
        ) then {
            [
                _primary
            ] call _removeFromAcreLists;
        };

        if (
            !isNil "acre_api_fnc_getMultiPushToTalkAssignment" &&
            {!isNil "acre_api_fnc_setMultiPushToTalkAssignment"}
        ) then {
            private _assignments =
                [] call acre_api_fnc_getMultiPushToTalkAssignment;

            private _retiredAssignments = [
                _companion
            ];

            if (!_primaryExists) then {
                _retiredAssignments pushBack _primary;
            };

            private _filteredAssignments = _assignments select {
                !(toLower _x in _retiredAssignments)
            };

            if (_filteredAssignments isNotEqualTo _assignments) then {
                [
                    _filteredAssignments
                ] call acre_api_fnc_setMultiPushToTalkAssignment;
            };
        };

        if (_companionExists) then {
            {
                [
                    _companion,
                    "setState",
                    [
                        _x,
                        ""
                    ]
                ] call acre_sys_data_fnc_dataEvent;
            } forEach [
                "prc163PrimaryRadio",
                "prc163CompanionRadio",
                "prc163CompanionRack"
            ];

            {
                [
                    _companion,
                    "setState",
                    [
                        _x,
                        0
                    ]
                ] call acre_sys_data_fnc_dataEvent;
            } forEach [
                "prc163PTTDown",
                "prc163TransmittingA",
                "prc163TransmittingB"
            ];
        };

        if (_primaryExists) then {
            {
                [
                    _primary,
                    "setState",
                    [
                        _x,
                        ""
                    ]
                ] call acre_sys_data_fnc_dataEvent;
            } forEach [
                "prc163CompanionRadio",
                "prc163CompanionRack"
            ];
        };

        [
            _rackOwner,
            _rackId,
            _rackName
        ] call _deleteRack;

        if (
            !_primaryExists &&
            {_currentRadio in _pairIds}
        ) then {
            private _available = (
                [] call acre_api_fnc_getCurrentRadioList
            ) select {
                [
                    _x
                ] call _radioExists
            };

            if (_available isNotEqualTo []) then {
                [
                    _available select 0
                ] call acre_api_fnc_setCurrentRadio;
            };
        };

        if (
            !_primaryExists &&
            {
                toLower (
                    missionNamespace getVariable [
                        "UKSF_PRC163_activeRadio",
                        ""
                    ]
                ) in _pairIds
            }
        ) then {
            missionNamespace setVariable [
                "UKSF_PRC163_activeRadio",
                ""
            ];
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

        {
            private _rackName = format [
                "UKSF PRC163 RT2 %1",
                toUpper _x
            ];

            [
                player,
                "",
                _rackName
            ] call _deleteRack;
        } forEach (
            keys _pending
        );

        private _disabledGear = (
            [player] call acre_sys_core_fnc_getGear
        ) apply {
            toLower _x
        };

        ACRE_EXTERNALLY_USED_MANPACK_RADIOS =
            ACRE_EXTERNALLY_USED_MANPACK_RADIOS select {
                private _radioId = toLower _x;

                _radioId find _prefix != 0 ||
                {_radioId in _disabledGear}
            };

        missionNamespace setVariable [
            "UKSF_PRC163_companionRadios",
            []
        ];

        missionNamespace setVariable [
            "UKSF_PRC163_endpointMap",
            createHashMap
        ];

        missionNamespace setVariable [
            "UKSF_PRC163_companionPending",
            createHashMap
        ];

        missionNamespace setVariable [
            "UKSF_PRC163_primaryMissingSince",
            createHashMap
        ];

        missionNamespace setVariable [
            "UKSF_PRC163_companionStatus",
            "DISABLED"
        ];
    };

    private _functionsAvailable = (
        !(isNil "acre_sys_rack_fnc_addRack") &&
        {!(isNil "acre_sys_rack_fnc_getMountedRadio")} &&
        {!(isNil "acre_sys_rack_fnc_getVehicleFromRack")} &&
        {!(isNil "acre_sys_radio_fnc_radioExists")}
    );

    if (!_functionsAvailable) exitWith {
        missionNamespace setVariable [
            "UKSF_PRC163_companionStatus",
            "ACRE FUNCTIONS UNAVAILABLE"
        ];
    };

    private _gear = (
        [player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };

    private _rawPrimaries = _gear select {
        _x find _prefix isEqualTo 0
    };

    private _deadPrimaries = _rawPrimaries select {
        !([
            _x
        ] call _radioExists)
    };

    private _primaries = _rawPrimaries select {
        [
            _x
        ] call _radioExists
    };

    _primaries sort true;

    if (_deadPrimaries isNotEqualTo []) then {
        private _deadLogged = missionNamespace getVariable [
            "UKSF_PRC163_deadRadioIdsLogged",
            []
        ];

        {
            if !(_x in _deadLogged) then {
                _deadLogged pushBack _x;

                diag_log format [
                    "UKSF_PRC163 DEAD PRIMARY QUARANTINED: radio=%1",
                    _x
                ];
            };

            if (
                _x in (keys _map) ||
                {_x in (keys _pending)}
            ) then {
                _missingSince set [
                    _x,
                    diag_tickTime - 3.1
                ];
            };
        } forEach _deadPrimaries;

        missionNamespace setVariable [
            "UKSF_PRC163_deadRadioIdsLogged",
            _deadLogged
        ];
    };

    private _trackedPrimaries = (
        keys _map
    ) + (
        keys _pending
    );

    _trackedPrimaries = _trackedPrimaries arrayIntersect _trackedPrimaries;

    {
        private _primary = _x;

        if (_primary in _primaries) then {
            _missingSince deleteAt _primary;
        } else {
            private _missingAt = _missingSince getOrDefault [
                _primary,
                -1
            ];

            if (_missingAt < 0) then {
                _missingSince set [
                    _primary,
                    diag_tickTime
                ];
            } else {
                if (diag_tickTime - _missingAt >= 3) then {
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
                    _missingSince deleteAt _primary;
                };
            };
        };
    } forEach _trackedPrimaries;

    {
        if !(_x in (keys _map)) then {
            _missingSince deleteAt _x;
        };
    } forEach (
        keys _missingSince
    );

    private _rackHost = player;

    private _rackIds = _rackHost getVariable [
        "acre_sys_rack_vehicleRacks",
        []
    ];

    private _validCompanions = [];

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
                {_owner isEqualTo _rackHost} &&
                {[_primary] call _radioExists} &&
                {[_companion] call _radioExists}
            );
        };

        if (!_entryValid && {_entry isNotEqualTo []}) then {
            [
                _primary,
                _entry
            ] call _cleanupEndpoint;

            _map deleteAt _primary;
            _companion = "";
            _rackId = "";
            _rackIds = _rackHost getVariable [
                "acre_sys_rack_vehicleRacks",
                []
            ];
        };

        if (!_entryValid) then {
            {
                private _candidateRack = toLower _x;

                private _candidateName = [
                    _candidateRack,
                    "getState",
                    "name"
                ] call acre_sys_data_fnc_dataEvent;

                if (isNil "_candidateName") then {
                    _candidateName = "";
                };

                if (
                    _rackId isEqualTo "" &&
                    {_candidateName isEqualTo _rackName}
                ) then {
                    private _candidateOwner = [
                        _candidateRack
                    ] call acre_sys_rack_fnc_getVehicleFromRack;

                    if (_candidateOwner isEqualTo _rackHost) then {
                        _rackId = _candidateRack;
                        _companion = toLower (
                            [
                                _candidateRack
                            ] call acre_sys_rack_fnc_getMountedRadio
                        );
                    };
                };
            } forEach _rackIds;

            if (
                !(_rackId isEqualTo "") &&
                {_companion find _prefix isEqualTo 0} &&
                {[_primary] call _radioExists} &&
                {[_companion] call _radioExists}
            ) then {
                _entryValid = true;

                _map set [
                    _primary,
                    [
                        _companion,
                        _rackId
                    ]
                ];

                missionNamespace setVariable [
                    "UKSF_PRC163_endpointMap",
                    _map
                ];

                _pending deleteAt _primary;
            } else {
                private _requestedAt = _pending getOrDefault [
                    _primary,
                    -1
                ];

                private _queue = _rackHost getVariable [
                    "acre_sys_rack_queue",
                    []
                ];

                private _queued = (
                    _queue findIf {
                        (_x param [1,"",[""]]) isEqualTo _rackName
                    }
                ) >= 0;

                if (!(_rackId isEqualTo "")) then {
                    if (_requestedAt < 0) then {
                        _pending set [
                            _primary,
                            diag_tickTime
                        ];
                    } else {
                        if (diag_tickTime - _requestedAt >= 10) then {
                            [
                                _rackHost,
                                _rackId,
                                _rackName
                            ] call _deleteRack;

                            _pending deleteAt _primary;
                            _rackIds = _rackHost getVariable [
                                "acre_sys_rack_vehicleRacks",
                                []
                            ];
                        };
                    };
                } else {
                    if (_queued) then {
                        if (_requestedAt < 0) then {
                            _pending set [
                                _primary,
                                diag_tickTime
                            ];
                        } else {
                            if (diag_tickTime - _requestedAt >= 10) then {
                                _queue = _queue select {
                                    (_x param [1,"",[""]]) isNotEqualTo _rackName
                                };

                                _rackHost setVariable [
                                    "acre_sys_rack_queue",
                                    _queue
                                ];

                                _pending deleteAt _primary;
                            };
                        };
                    } else {
                        if (
                            _requestedAt < 0 ||
                            {diag_tickTime - _requestedAt >= 3}
                        ) then {
                            _rackHost setVariable [
                                "acre_sys_rack_initPlayer",
                                player,
                                true
                            ];

                            [
                                _rackHost,
                                "ACRE_VRC110",
                                _rackName,
                                "RT2",
                                false,
                                [],
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
                    };
                };
            };
        };

        if (
            _entryValid &&
            {[_primary] call _radioExists} &&
            {[_companion] call _radioExists}
        ) then {
            [
                _rackId,
                "allowed",
                []
            ] call _setStateIfChanged;

            [
                _rackId,
                "disabled",
                []
            ] call _setStateIfChanged;

            [
                _companion,
                "powerSource",
                "BAT"
            ] call _setStateIfChanged;

            [
                _companion,
                false,
                false
            ] call _removeFromAcreLists;

            private _retiredCompanions = missionNamespace getVariable [
                "UKSF_PRC163_retiredCompanionIds",
                []
            ];

            if !(_companion in _retiredCompanions) then {
                ACRE_EXTERNALLY_USED_MANPACK_RADIOS pushBackUnique _companion;
            };

            [_primary,"prc163PrimaryRadio",_primary] call _setStateIfChanged;

            [_primary,"prc163CompanionRadio",_companion] call _setStateIfChanged;

            [_primary,"prc163CompanionRack",_rackId] call _setStateIfChanged;

            [_primary,"prc163EndpointLine",0] call _setStateIfChanged;

            [_companion,"prc163PrimaryRadio",_primary] call _setStateIfChanged;

            [_companion,"prc163CompanionRadio",_companion] call _setStateIfChanged;

            [_companion,"prc163CompanionRack",_rackId] call _setStateIfChanged;

            [_companion,"prc163EndpointLine",1] call _setStateIfChanged;

            private _initialized = [
                _primary,
                "getState",
                "prc163Initialized"
            ] call acre_sys_data_fnc_dataEvent;

            if (
                isNil "_initialized" ||
                {!_initialized}
            ) then {
                [
                    _primary
                ] call UKSF_PRC163_fnc_initializeState;
            };

            private _channelA = [
                _primary,
                "getState",
                "prc163ChannelA"
            ] call acre_sys_data_fnc_dataEvent;

            if !(_channelA isEqualType 0) then {
                _channelA = 0;
            };

            private _channelB = [
                _primary,
                "getState",
                "prc163ChannelB"
            ] call acre_sys_data_fnc_dataEvent;

            if !(_channelB isEqualType 0) then {
                _channelB = 0;
            };

            private _pairPTTDown = (
                [
                    _primary,
                    "getState",
                    "prc163PTTDown"
                ] call acre_sys_data_fnc_dataEvent
            ) isEqualTo 1;

            private _corePTTDown = missionNamespace getVariable ["acre_sys_core_pttKeyDown",false];
            private _broadcastPair = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
            private _rememberedPair = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
            if (
                !_corePTTDown &&
                {_pairPTTDown || {_broadcastPair in [_primary,_companion]} || {_rememberedPair in [_primary,_companion]}}
            ) then {
                [_primary,player,false,_companion] call UKSF_PRC163_fnc_normalizePairState;
                _pairPTTDown = false;
            };

            if (!_pairPTTDown) then {
                [_primary,_channelA] call _setCurrentChannelIfChanged;
                [_companion,_channelB] call _setCurrentChannelIfChanged;

                private _currentPairRadio = toLower (
                    [] call acre_api_fnc_getCurrentRadio
                );

                if (_currentPairRadio isEqualTo _companion) then {
                    [
                        _primary
                    ] call acre_api_fnc_setCurrentRadio;
                };
            };

            _validCompanions pushBackUnique _companion;
        };
    } forEach _primaries;

    private _activeRackIds = [];
    private _activeRackNames = [];

    {
        private _activeEntry = _map getOrDefault [
            _x,
            []
        ];

        private _activeRackId = toLower (
            _activeEntry param [
                1,
                "",
                [""]
            ]
        );

        if !(_activeRackId isEqualTo "") then {
            _activeRackIds pushBackUnique _activeRackId;

            private _activeRackName = [
                _activeRackId,
                "getState",
                "name"
            ] call acre_sys_data_fnc_dataEvent;

            if (_activeRackName isEqualType "") then {
                _activeRackNames pushBackUnique _activeRackName;
            };
        };
    } forEach (keys _map);

    private _expectedRackNames = _primaries apply {
        format [
            "UKSF PRC163 RT2 %1",
            toUpper _x
        ]
    };

    private _latestRackIds = _rackHost getVariable [
        "acre_sys_rack_vehicleRacks",
        []
    ];

    {
        private _candidateRackId = toLower _x;
        private _candidateName = [
            _candidateRackId,
            "getState",
            "name"
        ] call acre_sys_data_fnc_dataEvent;

        if (isNil "_candidateName") then {
            _candidateName = "";
        };

        private _isPrcRack = (
            _candidateName isEqualType "" &&
            {_candidateName find "UKSF PRC163 RT2 " isEqualTo 0}
        );

        private _isActiveRack = _candidateRackId in _activeRackIds;
        private _isExpectedRack = _candidateName in _expectedRackNames;
        private _isDuplicateRack = (
            _candidateName in _activeRackNames &&
            {!_isActiveRack}
        );

        if (
            _isPrcRack &&
            {
                _isDuplicateRack ||
                {!_isActiveRack && {!_isExpectedRack}}
            }
        ) then {
            [
                _rackHost,
                _candidateRackId,
                _candidateName
            ] call _deleteRack;
        };
    } forEach _latestRackIds;

    ACRE_EXTERNALLY_USED_MANPACK_RADIOS =
        ACRE_EXTERNALLY_USED_MANPACK_RADIOS select {
            private _radioId = toLower _x;

            _radioId find _prefix != 0 ||
            {_radioId in _validCompanions} ||
            {_radioId in _gear}
        };

    missionNamespace setVariable [
        "UKSF_PRC163_endpointMap",
        _map
    ];

    missionNamespace setVariable [
        "UKSF_PRC163_companionPending",
        _pending
    ];

    missionNamespace setVariable [
        "UKSF_PRC163_primaryMissingSince",
        _missingSince
    ];

    missionNamespace setVariable [
        "UKSF_PRC163_companionRadios",
        _validCompanions
    ];

    /*
        Loadout/Arsenal changes can replace ACRE unique IDs while UI state still
        remembers an endpoint from the previous kit. The dialog updater treats
        a non-empty UKSF_PRC163_guiRadio as authoritative, so a stale string can
        make the LCD appear powered off/blank until the client reconnects.

        Reconciliation is the authoritative owner of the live pair set. Sanitize
        remembered PRC-163 pointers here so the existing HMI updater can
        immediately re-resolve the current pair without another PFH or relog.
    */
    private _validPairIds = [];

    {
        private _radioA = toLower _x;
        private _entry = _map getOrDefault [
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
            _radioA find _prefix isEqualTo 0 &&
            {[_radioA] call _radioExists}
        ) then {
            _validPairIds pushBackUnique _radioA;
        };

        if (
            _radioB find _prefix isEqualTo 0 &&
            {[_radioB] call _radioExists}
        ) then {
            _validPairIds pushBackUnique _radioB;
        };
    } forEach (
        keys _map
    );

    private _guiRemembered = uiNamespace getVariable [
        "UKSF_PRC163_guiRadio",
        ""
    ];

    if !(_guiRemembered isEqualType "") then {
        _guiRemembered = "";
        uiNamespace setVariable [
            "UKSF_PRC163_guiRadio",
            ""
        ];
    };

    _guiRemembered = toLower _guiRemembered;

    if (
        _guiRemembered find _prefix isEqualTo 0 &&
        {!(_guiRemembered in _validPairIds)}
    ) then {
        uiNamespace setVariable [
            "UKSF_PRC163_guiRadio",
            ""
        ];

        diag_log format [
            "UKSF_PRC163 HMI REBIND: cleared stale guiRadio=%1 valid=%2",
            _guiRemembered,
            _validPairIds
        ];
    };

    private _activeRemembered = missionNamespace getVariable [
        "UKSF_PRC163_activeRadio",
        ""
    ];

    if !(_activeRemembered isEqualType "") then {
        _activeRemembered = "";
        missionNamespace setVariable [
            "UKSF_PRC163_activeRadio",
            ""
        ];
    };

    _activeRemembered = toLower _activeRemembered;

    if (
        _activeRemembered find _prefix isEqualTo 0 &&
        {!(_activeRemembered in _validPairIds)}
    ) then {
        missionNamespace setVariable [
            "UKSF_PRC163_activeRadio",
            ""
        ];
    };

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

    private _zeusDisplay = findDisplay 312;

    if (isNull _zeusDisplay) exitWith {};

    private _keyUpId = _zeusDisplay getVariable [
        "UKSF_PRC163_zeusPTTKeyUpEH",
        -1
    ];

    if (_keyUpId < 0) then {
        private _broadcastAtOpen = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
        private _rememberedAtOpen = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
        private _heldPRC = if (_broadcastAtOpen find "acre_prc163_id_" isEqualTo 0) then {_broadcastAtOpen} else {_rememberedAtOpen};
        if (_heldPRC find "acre_prc163_id_" isEqualTo 0) then {
            [_heldPRC,player,true] call UKSF_PRC163_fnc_normalizePairState;
        };

        _keyUpId = _zeusDisplay displayAddEventHandler [
            "KeyUp",
            {
                params [
                    "_display",
                    "_key"
                ];

                private _prefix = "acre_prc163_id_";

                private _broadcastRadio = toLower (
                    missionNamespace getVariable [
                        "ACRE_BROADCASTING_RADIOID",
                        ""
                    ]
                );

                private _rememberedRadio = toLower (
                    missionNamespace getVariable [
                        "UKSF_PRC163_pttRadio",
                        ""
                    ]
                );

                if (
                    _broadcastRadio find _prefix != 0 &&
                    {_rememberedRadio find _prefix != 0}
                ) exitWith {
                    false
                };

                private _activePTT = missionNamespace getVariable [
                    "ACRE_ACTIVE_PTTKEY",
                    -2
                ];

                private _actionName = switch (_activePTT) do {
                    case -1: {
                        "DefaultPTTKey"
                    };

                    case 0: {
                        "AltPTTKey1"
                    };

                    case 1: {
                        "AltPTTKey2"
                    };

                    case 2: {
                        "AltPTTKey3"
                    };

                    default {
                        ""
                    };
                };

                if (_actionName isEqualTo "") exitWith {
                    false
                };

                private _keybind = [
                    "ACRE2",
                    _actionName
                ] call CBA_fnc_getKeybind;

                if (isNil "_keybind") exitWith {
                    false
                };

                private _bindings = _keybind param [
                    8,
                    []
                ];

                if (_bindings isEqualTo []) then {
                    _bindings = [
                        _keybind param [
                            5,
                            [
                                -1,
                                [
                                    false,
                                    false,
                                    false
                                ]
                            ]
                        ]
                    ];
                };

                private _releasedPTT = _bindings findIf {
                    (
                        _x param [
                            0,
                            -1
                        ]
                    ) isEqualTo _key
                } >= 0;

                if (_releasedPTT) then {
                    [] call acre_sys_core_fnc_handleMultiPttKeyPressUp;
                };

                false
            }
        ];

        _zeusDisplay setVariable [
            "UKSF_PRC163_zeusPTTKeyUpEH",
            _keyUpId
        ];
    };

    private _unloadId = _zeusDisplay getVariable [
        "UKSF_PRC163_zeusPTTUnloadEH",
        -1
    ];

    if (_unloadId < 0) then {
        _unloadId = _zeusDisplay displayAddEventHandler [
            "Unload",
            {
                private _prefix = "acre_prc163_id_";

                private _broadcastRadio = toLower (
                    missionNamespace getVariable [
                        "ACRE_BROADCASTING_RADIOID",
                        ""
                    ]
                );

                private _rememberedRadio = toLower (
                    missionNamespace getVariable [
                        "UKSF_PRC163_pttRadio",
                        ""
                    ]
                );

                if (
                    _broadcastRadio find _prefix isEqualTo 0 ||
                    {_rememberedRadio find _prefix isEqualTo 0}
                ) then {
                    [] call acre_sys_core_fnc_handleMultiPttKeyPressUp;
                };
            }
        ];

        _zeusDisplay setVariable [
            "UKSF_PRC163_zeusPTTUnloadEH",
            _unloadId
        ];
    };
},0.1] call CBA_fnc_addPerFrameHandler;

[{
    if (isNull player) exitWith {};

    private _radioExists = {
        params [
            ["_radioId","",[""]]
        ];

        _radioId = toLower _radioId;

        if (
            _radioId isEqualTo "" ||
            {isNil "acre_sys_radio_fnc_radioExists"}
        ) exitWith {
            false
        };

        [
            _radioId
        ] call acre_sys_radio_fnc_radioExists
    };

    private _setStateIfChanged = {
        params [
            ["_radioId","",[""]],
            ["_stateName","",[""]],
            "_desired"
        ];

        private _current = [
            _radioId,
            "getState",
            _stateName
        ] call acre_sys_data_fnc_dataEvent;

        if (
            !isNil "_current" &&
            {_current isEqualTo _desired}
        ) exitWith {false};

        [
            _radioId,
            "setState",
            [_stateName,_desired]
        ] call acre_sys_data_fnc_dataEvent;

        true
    };

    private _setCurrentChannelIfChanged = {
        params [
            ["_radioId","",[""]],
            ["_desired",-1,[0]]
        ];

        if (_desired < 0) exitWith {false};

        private _current = [
            _radioId,
            "getCurrentChannel"
        ] call acre_sys_data_fnc_dataEvent;

        if (
            !isNil "_current" &&
            {_current isEqualType 0} &&
            {_current isEqualTo _desired}
        ) exitWith {false};

        [
            _radioId,
            "setCurrentChannel",
            _desired
        ] call acre_sys_data_fnc_dataEvent;

        true
    };

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

        private _map = missionNamespace getVariable [
            "UKSF_PRC163_endpointMap",
            createHashMap
        ];

        private _radios = keys _map;

        _radios = _radios select {
            private _radioA = toLower _x;
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

            (
                _radioA find _prefix isEqualTo 0 &&
                {_radioB find _prefix isEqualTo 0} &&
                {[_radioA] call _radioExists} &&
                {[_radioB] call _radioExists}
            )
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
                {_radioB find _prefix isEqualTo 0} &&
                {[_radioA] call _radioExists} &&
                {[_radioB] call _radioExists}
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
                    _drainTimes set [_radioA,_now];
                };

                private _elapsedSinceDrain = (_now - _lastDrain) max 0;

                if (_elapsedSinceDrain >= 5) then {
                    private _elapsed = _elapsedSinceDrain min 5;
                    _drainTimes set [_radioA,_lastDrain + _elapsed];

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
        _x find "acre_prc163_id_" == 0 &&
        {[_x] call _radioExists}
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
                if (
                    _radioId find _prefix isEqualTo 0
                ) then {
                    if ([_radioId] call _radioExists) then {
                        _availableRadios pushBackUnique _radioId;
                    };
                } else {
                    _availableRadios pushBackUnique _radioId;
                };
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
                {_sourceRadio find _prefix isEqualTo 0} &&
                {[_sourceRadio] call _radioExists}
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
                {!(_radioB in _availableRadios)} ||
                {!([_radioA] call _radioExists)} ||
                {!([_radioB] call _radioExists)}
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
            _drainTimes set [_radioId,_now];
        };

        private _elapsedSinceDrain = (_now - _lastDrain) max 0;

        if (_elapsedSinceDrain >= 5) then {
            private _elapsed = _elapsedSinceDrain min 5;
            _drainTimes set [_radioId,_lastDrain + _elapsed];

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
                    "getState",
                    "prc163ChannelA"
                ] call acre_sys_data_fnc_dataEvent;

                private _channelB = [
                    _radioA,
                    "getState",
                    "prc163ChannelB"
                ] call acre_sys_data_fnc_dataEvent;

                private _selectedLine = [
                    _radioA,
                    "getState",
                    "prc163SelectedLine"
                ] call acre_sys_data_fnc_dataEvent;

                if !(_selectedLine in [0,1]) then {
                    _selectedLine = 0;
                };

                private _pairPTTDown = (
                    [
                        _radioA,
                        "getState",
                        "prc163PTTDown"
                    ] call acre_sys_data_fnc_dataEvent
                ) isEqualTo 1;

                private _corePTTDown = missionNamespace getVariable ["acre_sys_core_pttKeyDown",false];
                private _broadcastPair = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
                private _rememberedPair = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
                if (
                    !_corePTTDown &&
                    {_pairPTTDown || {_broadcastPair in [_radioA,_radioB]} || {_rememberedPair in [_radioA,_radioB]}}
                ) then {
                    [_radioA,player,false,_radioB] call UKSF_PRC163_fnc_normalizePairState;
                    _pairPTTDown = false;
                };

                if (!_pairPTTDown) then {
                    if (
                        _channelA isEqualType 0 &&
                        {_channelA >= 0}
                    ) then {
                        [_radioA,_channelA] call _setCurrentChannelIfChanged;
                    };

                    if (
                        _channelB isEqualType 0 &&
                        {_channelB >= 0}
                    ) then {
                        [_radioB,_channelB] call _setCurrentChannelIfChanged;
                    };

                    private _currentPairRadio = toLower (
                        [] call acre_api_fnc_getCurrentRadio
                    );

                    if (_currentPairRadio isEqualTo _radioB) then {
                        [
                            _radioA
                        ] call acre_api_fnc_setCurrentRadio;
                    };
                };

                {
                    [
                        _x,
                        "prc163SelectedLine",
                        _selectedLine
                    ] call _setStateIfChanged;
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
