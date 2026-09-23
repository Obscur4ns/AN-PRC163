params [
    ["_radioId","",[""]]
];

private _prefix = "acre_prc163_id_";

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    createHashMap
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
    createHashMap
};

private _readAnchorState = {
    params [
        "_name",
        "_default"
    ];

    private _value = [
        _radioA,
        "getState",
        _name
    ] call acre_sys_data_fnc_dataEvent;

    if (isNil "_value") then {
        _default
    } else {
        _value
    }
};

private _selectedLine = private _targetRadio = [
    _radioA,
    _radioB
] select _selectedLine;

private _physicalSlot = [
    _radioA
] call UKSF_PRC163_fnc_getBatterySlot;

private _state = createHashMap;

_state set [
    "radioId",
    _targetRadio
];

_state set [
    "radioA",
    _radioA
];

_state set [
    "radioB",
    _radioB
];

_state set [
    "physicalSlot",
    _physicalSlot
];

_state set [
    "selectedLine",
    _selectedLine
];

_state set [
    "selectedLineName",
    [
        "R/T 1",
        "R/T 2"
    ] select _selectedLine
];

_state set [
    "page",
    _page
];

_state set [
    "cursor",
    _cursor
];

_state set [
    "inputBuffer",
    _inputBuffer
];

_state set [
    "editing",
    _editing
];

_state set [
    "isEditing",
    _editing isEqualTo 1
];

_state
