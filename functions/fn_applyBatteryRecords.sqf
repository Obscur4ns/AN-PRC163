params [
    ["_records",[],[[]]],
    ["_unit",player,[objNull]]
];

if (isNull _unit) exitWith {
    false
};

private _prefix = "acre_prc163_id_";

private _radioIds = (
    (
        [_unit] call acre_sys_core_fnc_getGear
    ) select {
        toLower _x find _prefix isEqualTo 0
    }
) apply {
    toLower _x
};

private _radioEntries = _radioIds apply {
    [
        parseNumber (
            _x select [
                count _prefix
            ]
        ),
        _x
    ]
};

_radioEntries sort true;

private _cleanRecords = [];

{
    if (
        _x isEqualType [] &&
        {count _x >= 5}
    ) then {
        private _slot = floor (
            _x param [
                0,
                -1,
                [0]
            ]
        );

        private _installed = _x param [
            1,
            0,
            [0]
        ];

        private _serial = _x param [
            2,
            "",
            [""]
        ];

        private _charge = _x param [
            3,
            0,
            [0]
        ];

        private _health = _x param [
            4,
            1,
            [0]
        ];

        if (
            _slot >= 1 &&
            {_slot <= 16}
        ) then {
            _installed = if (
                _installed isEqualTo 0
            ) then {
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

            private _cleanRecord = [
                _slot,
                _installed,
                _serial,
                _charge,
                _health
            ];

            private _existingIndex = _cleanRecords findIf {
                (
                    _x select 0
                ) isEqualTo _slot
            };

            if (_existingIndex < 0) then {
                _cleanRecords pushBack _cleanRecord;
            } else {
                _cleanRecords set [
                    _existingIndex,
                    _cleanRecord
                ];
            };
        };
    };
} forEach _records;

_cleanRecords sort true;

private _applied = 0;

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

if (_pilotEnabled) then {
    {
        _x params [
            "_number",
            "_radioA"
        ];

        if (_number > 0) then {
            private _slot = [
                _radioA,
                _unit
            ] call UKSF_PRC163_fnc_getBatterySlot;

            private _recordIndex = _cleanRecords findIf {
                (
                    _x select 0
                ) isEqualTo _slot
            };

            if (_recordIndex >= 0) then {
                private _record = (
                    _cleanRecords select _recordIndex
                );

                private _result = [
                    _radioA,
                    [
                        _record select 1,
                        _record select 2,
                        _record select 3,
                        _record select 4
                    ]
                ] call UKSF_PRC163_fnc_initializeBatteryState;

                if (_result) then {
                    _applied = _applied + 1;
                };
            };
        };
    } forEach _radioEntries;
} else {
    {
        _x params [
            "_number",
            "_radioA"
        ];

        if (
            _number > 0 &&
            {(_number mod 2) isEqualTo 1}
        ) then {
            private _radioB = format [
                "%1%2",
                _prefix,
                _number + 1
            ];

            if (_radioB in _radioIds) then {
                private _slot = [
                    _radioA,
                    _unit
                ] call UKSF_PRC163_fnc_getBatterySlot;

                private _recordIndex = _cleanRecords findIf {
                    (
                        _x select 0
                    ) isEqualTo _slot
                };

                if (_recordIndex >= 0) then {
                    private _record = (
                        _cleanRecords select _recordIndex
                    );

                    private _result = [
                        _radioA,
                        [
                            _record select 1,
                            _record select 2,
                            _record select 3,
                            _record select 4
                        ]
                    ] call UKSF_PRC163_fnc_initializeBatteryState;

                    if (_result) then {
                        _applied = _applied + 1;
                    };
                };
            };
        };
    } forEach _radioEntries;
};

_applied > 0
