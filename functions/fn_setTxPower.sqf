params [
    ["_radioId","",[""]],
    ["_line",-1,[0]],
    ["_powerMilliwatts",-1,[0]]
];

private _validPowers = [250,500,1000,2500,5000];

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

_radioId = toLower _radioId;

if (
    _radioId find "acre_prc163_id_" != 0 ||
    {!(_powerMilliwatts in _validPowers)}
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

private _initialized = [
    _radioA,
    "getState",
    "prc163Initialized"
] call acre_sys_data_fnc_dataEvent;

if !(_initialized isEqualTo true) then {
    if !([_radioA] call UKSF_PRC163_fnc_initializeState) exitWith {false};
};

if (_line isEqualTo -1) then {
    _line = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;
};

if !(_line in [0,1]) exitWith {false};

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

private _channels = [
    _targetRadio,
    "getState",
    "channels"
] call acre_sys_data_fnc_dataEvent;

if (isNil "_channels") then {_channels = []};

private _presetCount = (count _channels) min 99;

if (
    !(_channel isEqualType 0) ||
    {_channel < 0} ||
    {_channel >= _presetCount}
) then {
    _channel = [
        _targetRadio,
        "getCurrentChannel"
    ] call acre_sys_data_fnc_dataEvent;
};

if (
    isNil "_channel" ||
    {!(_channel isEqualType 0)} ||
    {_channel < 0} ||
    {_channel >= _presetCount}
) exitWith {false};

_channel = floor _channel;

private _channelData = _channels param [_channel,objNull];
if (isNull _channelData) exitWith {false};

private _currentPower = _channelData getVariable ["power",-1];
if (_currentPower isEqualTo _powerMilliwatts) exitWith {true};

_channelData setVariable ["power",_powerMilliwatts];
_channels set [_channel,_channelData];

[
    _targetRadio,
    "setState",
    ["channels",_channels]
] call acre_sys_data_fnc_dataEvent;

private _verifyData = [
    _targetRadio,
    "getChannelData",
    _channel
] call acre_sys_data_fnc_dataEvent;

if (isNil "_verifyData") exitWith {false};

(_verifyData getVariable ["power",-1]) isEqualTo _powerMilliwatts
