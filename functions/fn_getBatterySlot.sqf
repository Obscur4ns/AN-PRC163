params [
    ["_radioId","",[""]],
    ["_unit",player,[objNull]]
];

if (isNull _unit) exitWith {-1};

private _prefix = "acre_prc163_id_";
_radioId = toLower _radioId;

if (_radioId isEqualTo "") then {
    _radioId = toLower ([] call UKSF_PRC163_fnc_getTargetRadio);
};

if (
    _radioId isEqualTo "" ||
    {_radioId find _prefix != 0}
) exitWith {-1};

if (missionNamespace getVariable ["UKSF_PRC163_SingleInstancePilot",false]) then {
    private _pair = [
        _radioId,
        _unit,
        false
    ] call UKSF_PRC163_fnc_resolvePair;

    private _radioA = _pair param [0,"",[""]];
    if (_radioA isEqualTo "") exitWith {-1};

    /*
        Slot ordering has historically followed PRC-163 unique-ID order, not
        physical container position. Reproduce that ordering from endpointMap
        without rescanning player gear.
    */
    private _map = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _entries = (keys _map) apply {
        private _id = toLower _x;
        [
            parseNumber (_id select [count _prefix]),
            _id
        ]
    };

    _entries sort true;

    private _slotIndex = _entries findIf {
        (_x select 1) isEqualTo _radioA
    };

    if (_slotIndex < 0) exitWith {-1};
    _slotIndex + 1
} else {
    private _radios = (
        [_unit] call acre_sys_core_fnc_getGear
    ) apply {toLower _x};

    private _number = parseNumber (
        _radioId select [count _prefix]
    );

    if (_number < 1) exitWith {-1};

    private _radioANumber = if (
        (_number mod 2) isEqualTo 1
    ) then {
        _number
    } else {
        _number - 1
    };

    private _radioA = format ["%1%2",_prefix,_radioANumber];
    private _radioB = format ["%1%2",_prefix,_radioANumber + 1];

    if (
        !(_radioA in _radios) ||
        {!(_radioB in _radios)}
    ) exitWith {-1};

    ((_radioANumber - 1) / 2) + 1
}
