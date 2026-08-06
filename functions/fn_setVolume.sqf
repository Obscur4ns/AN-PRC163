params [
    ["_radioId","",[""]],
    "_event",
    ["_volume",1,[0]],
    "_radioData"
];

private _prefix = "acre_prc163_id_";
_radioId = toLower _radioId;

if (_radioId find _prefix != 0) exitWith {
    false
};

private _pair = [
    _radioId,
    player,
    false
] call UKSF_PRC163_fnc_resolvePair;

_pair params [
    ["_radioA","",[""]],
    ["_radioB","",[""]],
    ["_line",-1,[0]]
];

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""} ||
    {!(_line in [0,1])}
) exitWith {
    false
};

_volume = (
    (_volume max 0) min 1
);

private _targetRadio = [
    _radioA,
    _radioB
] select _line;

[
    _targetRadio,
    _event,
    _volume,
    _radioData
] call acre_sys_prc152_fnc_setVolume;

private _stateName = [
    "prc163VolumeA",
    "prc163VolumeB"
] select _line;

{
    [
        _x,
        "setState",
        [
            _stateName,
            _volume
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

true
