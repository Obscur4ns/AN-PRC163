params [
    ["_line",0,[0]]
];

if !(_line in [0,1]) exitWith {
    false
};

private _prefix = "acre_prc163_id_";

if (
    missionNamespace getVariable [
        "UKSF_PRC163_pttHeld",
        false
    ]
) exitWith {
    private _heldRadio = toLower (
        missionNamespace getVariable [
            "UKSF_PRC163_pttRadio",
            ""
        ]
    );

    private _heldLine = missionNamespace getVariable [
        "UKSF_PRC163_pttLine",
        -1
    ];

    _heldRadio find _prefix isEqualTo 0 &&
    {_heldLine isEqualTo _line}
};

private _sourceRadio = toLower (
    [] call UKSF_PRC163_fnc_getTargetRadio
);

if (
    _sourceRadio isEqualTo "" ||
    {_sourceRadio find _prefix != 0}
) exitWith {
    false
};

if !(
    [
        _sourceRadio,
        _line
    ] call UKSF_PRC163_fnc_selectLine
) exitWith {
    false
};

private _targetRadio = toLower (
    [] call acre_api_fnc_getCurrentRadio
);

if (
    _targetRadio isEqualTo "" ||
    {_targetRadio find _prefix != 0}
) exitWith {
    false
};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _targetRadio
];

missionNamespace setVariable [
    "UKSF_PRC163_pttRadio",
    _targetRadio
];

missionNamespace setVariable [
    "UKSF_PRC163_pttLine",
    _line
];

[
    -1
] call acre_sys_core_fnc_handleMultiPttKeyPress;

private _pttDown = [
    _targetRadio,
    "getState",
    "prc163PTTDown"
] call acre_sys_data_fnc_dataEvent;

if !(_pttDown isEqualTo 1) exitWith {
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

    false
};

missionNamespace setVariable [
    "UKSF_PRC163_pttHeld",
    true
];

true
