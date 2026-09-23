params [
    ["_radioId","",[""]],
    ["_record",[],[[]]]
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    false
};

private _pair = [
    _sourceRadioId,
    player,
    false
] call UKSF_PRC163_fnc_resolvePair;

_pair params [
    ["_radioA","",[""]],
    ["_radioB","",[""]]
];

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""}
) exitWith {
    false
};

private _slot = [
    _radioA
] call UKSF_PRC163_fnc_getBatterySlot;

if (_slot < 1) exitWith {
    false
};

private _installed = _record param [
    0,
    1,
    [0]
];

private _serial = _record param [
    1,
    "",
    [""]
];

private _charge = _record param [
    2,
    1,
    [0]
];

private _health = _record param [
    3,
    1,
    [0]
];

_installed = if (_installed isEqualTo 0) then {
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

if (
    _serial isEqualTo "" &&
    {_installed isEqualTo 1}
) then {
    private _uid = getPlayerUID player;

    if (_uid isEqualTo "") then {
        _uid = profileName;
    };

    private _slotText = str _slot;

    while {
        count _slotText < 3
    } do {
        _slotText = "0" + _slotText;
    };

    _serial = format [
        "BAT-%1-%2",
        _uid,
        _slotText
    ];
};

{
    [
        _x,
        "setState",
        [
            "prc163BatterySlot",
            _slot
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryInstalled",
            _installed
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatterySerial",
            _serial
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryCharge",
            _charge
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryHealth",
            _health
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryLowWarned",
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryCriticalWarned",
            0
        ]
    ] call acre_sys_data_fnc_dataEvent;

    [
        _x,
        "setState",
        [
            "prc163BatteryInitialized",
            true
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

true
