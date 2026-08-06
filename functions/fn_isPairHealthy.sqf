params [
    ["_radioA","",[""]],
    ["_radioB","",[""]],
    ["_unit",objNull,[objNull]],
    ["_requireAvailable",true,[true]]
];

private _prefix = "acre_prc163_id_";

_radioA = toLower _radioA;
_radioB = toLower _radioB;

if (isNull _unit) then {
    _unit = player;
};

if (
    isNull _unit ||
    {_radioA find _prefix != 0} ||
    {_radioB find _prefix != 0} ||
    {_radioA isEqualTo _radioB} ||
    {isNil "acre_sys_radio_fnc_radioExists"} ||
    {!([_radioA] call acre_sys_radio_fnc_radioExists)} ||
    {!([_radioB] call acre_sys_radio_fnc_radioExists)}
) exitWith {
    false
};

private _gear = (
    [_unit] call acre_sys_core_fnc_getGear
) apply {
    toLower _x
};

if !(_radioA in _gear) exitWith {
    false
};

private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];

if (_pilotEnabled) then {
    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];

    private _entry = _endpointMap getOrDefault [
        _radioA,
        []
    ];

    private _mappedRadioB = toLower (
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

    if (
        _mappedRadioB isNotEqualTo _radioB ||
        {_rackId isEqualTo ""} ||
        {isNil "acre_sys_rack_fnc_getMountedRadio"} ||
        {isNil "acre_sys_rack_fnc_getVehicleFromRack"}
    ) exitWith {
        false
    };

    private _rackIds = _unit getVariable [
        "acre_sys_rack_vehicleRacks",
        []
    ];

    private _rackPresent = (
        _rackIds findIf {
            toLower _x isEqualTo _rackId
        }
    ) >= 0;

    if (!_rackPresent) exitWith {
        false
    };

    private _mountedRadio = toLower (
        [
            _rackId
        ] call acre_sys_rack_fnc_getMountedRadio
    );

    private _rackOwner = [
        _rackId
    ] call acre_sys_rack_fnc_getVehicleFromRack;

    if (
        _mountedRadio isNotEqualTo _radioB ||
        {!(_rackOwner isEqualTo _unit)}
    ) exitWith {
        false
    };

    private _manpackRadios = if (
        isNil "ACRE_EXTERNALLY_USED_MANPACK_RADIOS"
    ) then {
        []
    } else {
        ACRE_EXTERNALLY_USED_MANPACK_RADIOS apply {
            toLower _x
        }
    };

    if !(_radioB in _manpackRadios) exitWith {
        false
    };

    private _unstableLists = [];

    {
        private _listValue = missionNamespace getVariable [
            _x,
            []
        ];

        if (_listValue isEqualType []) then {
            _unstableLists append (
                _listValue apply {
                    toLower _x
                }
            );
        };
    } forEach [
        "ACRE_ACCESSIBLE_RACK_RADIOS",
        "ACRE_HEARABLE_RACK_RADIOS",
        "ACRE_ACTIVE_EXTERNAL_RADIOS",
        "ACRE_EXTERNALLY_USED_PERSONAL_RADIOS"
    ];

    if (_radioB in _unstableLists) exitWith {
        false
    };
} else {
    if !(_radioB in _gear) exitWith {
        false
    };
};

if (!_requireAvailable) exitWith {
    true
};

if (isNil "acre_api_fnc_getCurrentRadioList") exitWith {
    false
};

private _availableValue = [] call acre_api_fnc_getCurrentRadioList;

if !(_availableValue isEqualType []) exitWith {
    false
};

private _available = _availableValue apply {
    toLower _x
};

_radioA in _available && {
    _radioB in _available
}
