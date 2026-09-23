params [
    ["_direction",1,[0]]
];

if !(_direction in [-1,1]) exitWith {false};

private _sourceRadio = toLower (
    [] call UKSF_PRC163_fnc_getTargetRadio
);

if (
    _sourceRadio isEqualTo "" ||
    {_sourceRadio find "acre_prc163_id_" != 0}
) exitWith {false};

private _pair = [
    _sourceRadio,
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

private _selectedLine = [
    _radioA,
    "getState",
    "prc163SelectedLine"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_selectedLine" ||
    {!(_selectedLine isEqualType 0)} ||
    {!(_selectedLine in [0,1])}
) then {
    [_radioA] call UKSF_PRC163_fnc_initializeState;

    _selectedLine = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;
};

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

private _targetRadio = [_radioA,_radioB] select _selectedLine;
private _stateName = [
    "prc163ChannelA",
    "prc163ChannelB"
] select _selectedLine;

private _channels = [
    _targetRadio,
    "getState",
    "channels"
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channels" ||
    {!(_channels isEqualType [])} ||
    {_channels isEqualTo []}
) exitWith {false};

private _presetCount = (count _channels) min 99;
if (_presetCount < 1) exitWith {false};

private _channel = [
    _radioA,
    "getState",
    _stateName
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_channel" ||
    {!(_channel isEqualType 0)}
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
) then {
    _channel = 0;
};

private _newChannel = (
    floor _channel +
    _direction +
    _presetCount
) % _presetCount;

if !(
    [
        _radioA,
        _selectedLine,
        _newChannel
    ] call UKSF_PRC163_fnc_setLineChannel
) exitWith {false};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _targetRadio
];

uiNamespace setVariable [
    "UKSF_PRC163_guiRadio",
    _radioA
];

private _radioType = [
    _targetRadio
] call acre_sys_radio_fnc_getRadioBaseClassname;

private _typeName = getText (
    configFile >>
    "CfgAcreComponents" >>
    _radioType >>
    "name"
);

if (_typeName isEqualTo "") then {
    _typeName = getText (
        configFile >>
        "CfgWeapons" >>
        "ACRE_PRC163" >>
        "displayName"
    );
};

private _listInfo = [
    _targetRadio,
    "getListInfo"
] call acre_sys_data_fnc_dataEvent;

private _switchColor = missionNamespace getVariable [
    "acre_sys_list_SwitchChannelColor",
    [1,0.8,0,1]
];

[
    "acre_switchChannel",
    _typeName,
    _listInfo,
    "",
    0.5,
    _switchColor
] call acre_sys_list_fnc_displayHint;

[
    "Acre_GenericClick",
    [0,0,0],
    [0,0,0],
    1,
    false
] call acre_sys_sounds_fnc_playSound;

true
