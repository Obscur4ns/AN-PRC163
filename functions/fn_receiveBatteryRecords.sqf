params [
    ["_records",[],[[]]]
];

if (!hasInterface) exitWith {false};

if (
    remoteExecutedOwner > 2 &&
    {remoteExecutedOwner != clientOwner}
) exitWith {false};

private _cleanRecords = [];

{
    if (
        _x isEqualType [] &&
        {count _x >= 5}
    ) then {
        private _slot = floor (
            _x param [0,-1,[0]]
        );

        private _installed = _x param [1,0,[0]];
        private _serial = _x param [2,"",[""]];
        private _charge = _x param [3,0,[0]];
        private _health = _x param [4,1,[0]];

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

            _charge = (_charge max 0) min 1;
            _health = (_health max 0) min 1;

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
                (_x select 0) isEqualTo _slot
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

private _applied = if (
    _cleanRecords isEqualTo []
) then {
    false
} else {
    [
        _cleanRecords
    ] call UKSF_PRC163_fnc_applyBatteryRecords
};

missionNamespace setVariable [
    "UKSF_PRC163_lastBatteryLoad",
    [
        _cleanRecords,
        _applied
    ]
];

_applied