params [
    ["_radioId","",[""]],
    ["_line",-1,[0]]
];

private _prefix = "acre_prc163_id_";

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {-1};

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
) exitWith {-1};

if (_line isEqualTo -1) then {
    _line = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;
};

if !(_line in [0,1]) exitWith {-1};

private _targetRadio = [_radioA,_radioB] select _line;
private _channelStateName = [
    "prc163ChannelA",
    "prc163ChannelB"
] select _line;

private _channel = [
    _radioA,
    "getState",
    _channelStateName
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channel" ||
    {!(_channel isEqualType 0)} ||
    {_channel < 0}
) then {
    _channel = [
        _targetRadio,
        "getCurrentChannel"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    isNil "_channel" ||
    {!(_channel isEqualType 0)} ||
    {_channel < 0}
) exitWith {-1};

private _channelData = [
    _targetRadio,
    "getChannelData",
    floor _channel
] call acre_sys_data_fnc_dataEvent;

if (isNil "_channelData") exitWith {-1};

private _power = _channelData getVariable ["power",-1];

if (
    !(_power isEqualType 0) ||
    {_power < 0}
) exitWith {-1};

_power
