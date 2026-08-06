params [
    ["_radioA","",[""]],
    ["_radioB","",[""]],
    ["_unit",objNull,[objNull]],
    ["_requireAvailable",true,[true]]
];

if (isNull _unit) then {_unit = player};

private _prefix = "acre_prc163_id_";
_radioA = toLower _radioA;
_radioB = toLower _radioB;

if (
    isNull _unit ||
    {_radioA find _prefix != 0} ||
    {_radioB find _prefix != 0} ||
    {_radioA isEqualTo _radioB} ||
    {isNil "acre_sys_radio_fnc_radioExists"} ||
    {!([_radioA] call acre_sys_radio_fnc_radioExists)} ||
    {!([_radioB] call acre_sys_radio_fnc_radioExists)}
) exitWith {false};

private _gear = ([_unit] call acre_sys_core_fnc_getGear) apply {toLower _x};
if !(_radioA in _gear) exitWith {false};

if (missionNamespace getVariable ["UKSF_PRC163_SingleInstancePilot",false]) then {
    private _map = missionNamespace getVariable ["UKSF_PRC163_endpointMap",createHashMap];
    private _entry = _map getOrDefault [_radioA,[]];
    private _mappedB = toLower (_entry param [0,"",[""]]);
    private _rackId = toLower (_entry param [1,"",[""]]);

    if (
        _mappedB isNotEqualTo _radioB ||
        {_rackId isEqualTo ""} ||
        {isNil "acre_sys_rack_fnc_getMountedRadio"} ||
        {toLower ([_rackId] call acre_sys_rack_fnc_getMountedRadio) isNotEqualTo _radioB}
    ) exitWith {false};
} else {
    if !(_radioB in _gear) exitWith {false};
};

if (!_requireAvailable) exitWith {true};
if (isNil "acre_api_fnc_getCurrentRadioList") exitWith {false};

private _available = ([] call acre_api_fnc_getCurrentRadioList) apply {toLower _x};
_radioA in _available && {_radioB in _available}
