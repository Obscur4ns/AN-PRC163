params [
    ["_radioId","",[""]],
    ["_line",0,[0]],
    ["_channel",0,[0]]
];

_radioId = toLower _radioId;

if (
    _radioId find "acre_prc163_id_" != 0 ||
    {!(_line in [0,1])}
) exitWith {false};

private _pair = [
    _radioId,
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
) exitWith {false};

private _pairRadios = [_radioA,_radioB];
private _targetRadioId = _pairRadios select _line;

private _channels = [
    _targetRadioId,
    "getState",
    "channels"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channels" ||
    {_channels isEqualTo []}
) exitWith {false};

private _presetCount = (count _channels) min 99;
if (_presetCount < 1) exitWith {false};

_channel = floor _channel;

if (
    _channel < 0 ||
    {_channel >= _presetCount}
) exitWith {false};

private _stateName = [
    "prc163ChannelA",
    "prc163ChannelB"
] select _line;

private _physicalCurrent = [
    _targetRadioId,
    "getCurrentChannel"
] call acre_sys_data_fnc_dataEvent;

if !(
    _physicalCurrent isEqualType 0 &&
    {_physicalCurrent isEqualTo _channel}
) then {
    [
        _targetRadioId,
        "setCurrentChannel",
        _channel
    ] call acre_sys_data_fnc_dataEvent;
};

{
    private _current = [
        _x,
        "getState",
        _stateName
    ] call acre_sys_data_fnc_dataEvent;

    if (
        isNil "_current" ||
        {!(_current isEqualTo _channel)}
    ) then {
        [
            _x,
            "setState",
            [_stateName,_channel]
        ] call acre_sys_data_fnc_dataEvent;
    };
} forEach _pairRadios;

true
