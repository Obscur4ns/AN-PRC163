params [
    ["_unit",player,[objNull]]
];

if (isNull _unit) exitWith {[]};

private _prefix = "acre_prc163_id_";
private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

private _radioIds = if (_pilotEnabled) then {
    keys (
        missionNamespace getVariable [
            "UKSF_PRC163_endpointMap",
            createHashMap
        ]
    )
} else {
    (
        ([_unit] call acre_sys_core_fnc_getGear) select {
            toLower _x find _prefix isEqualTo 0
        }
    ) apply {toLower _x}
};

private _sorted = _radioIds apply {
    private _id = toLower _x;
    [
        parseNumber (_id select [count _prefix]),
        _id
    ]
};

_sorted sort true;

private _records = [];
private _recordedSlots = [];

if (_pilotEnabled) then {
    {
        _x params ["_number","_radioA"];

        if (_number > 0) then {
            private _record = [
                _radioA
            ] call UKSF_PRC163_fnc_getBatteryRecord;

            if ((count _record) isEqualTo 5) then {
                private _slot = _record param [0,-1,[0]];

                if (
                    _slot > 0 &&
                    {!(_slot in _recordedSlots)}
                ) then {
                    _records pushBack _record;
                    _recordedSlots pushBack _slot;
                };
            };
        };
    } forEach _sorted;
} else {
    {
        _x params ["_number","_radioA"];

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
                private _record = [
                    _radioA
                ] call UKSF_PRC163_fnc_getBatteryRecord;

                if ((count _record) isEqualTo 5) then {
                    private _slot = _record param [0,-1,[0]];

                    if (
                        _slot > 0 &&
                        {!(_slot in _recordedSlots)}
                    ) then {
                        _records pushBack _record;
                        _recordedSlots pushBack _slot;
                    };
                };
            };
        };
    } forEach _sorted;
};

_records
