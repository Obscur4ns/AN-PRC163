params [
    ["_unit",player,[objNull]]
];

if (isNull _unit) exitWith {
    []
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

private _sorted = _radioIds apply {
    [
        parseNumber (
            _x select [
                count _prefix
            ]
        ),
        _x
    ]
};

_sorted sort true;

private _records = [];
private _recordedSlots = [];

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

if (_pilotEnabled) then {
    {
        _x params [
            "_number",
            "_radioId"
        ];

        if (_number > 0) then {
            private _slot = [
                _radioId,
                _unit
            ] call UKSF_PRC163_fnc_getBatterySlot;

            if (
                _slot > 0 &&
                {!(_slot in _recordedSlots)}
            ) then {
                private _record = [
                    _radioId
                ] call UKSF_PRC163_fnc_getBatteryRecord;

                if ((count _record) isEqualTo 5) then {
                    _records pushBack _record;
                    _recordedSlots pushBack _slot;
                };
            };
        };
    } forEach _sorted;
} else {
    {
        _x params [
            "_number",
            "_radioId"
        ];

        if (
            _number > 0 &&
            {(_number mod 2) isEqualTo 1}
        ) then {
            private _companion = format [
                "%1%2",
                _prefix,
                _number + 1
            ];

            if (_companion in _radioIds) then {
                private _slot = [
                    _radioId,
                    _unit
                ] call UKSF_PRC163_fnc_getBatterySlot;

                if (
                    _slot > 0 &&
                    {!(_slot in _recordedSlots)}
                ) then {
                    private _record = [
                        _radioId
                    ] call UKSF_PRC163_fnc_getBatteryRecord;

                    if ((count _record) isEqualTo 5) then {
                        _records pushBack _record;
                        _recordedSlots pushBack _slot;
                    };
                };
            };
        };
    } forEach _sorted;
};

_records
