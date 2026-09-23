params [
    ["_radioId","",[""]]
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    _this call acre_sys_prc152_fnc_getVolume
};

private _pair = [
    _sourceRadioId,
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
    _this call acre_sys_prc152_fnc_getVolume
};

private _stateName = [
    "prc163VolumeA",
    "prc163VolumeB"
] select _line;

private _volume = [
    _radioA,
    "getState",
    _stateName
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_volume" ||
    {!(_volume isEqualType 0)}
) exitWith {
    _this call acre_sys_prc152_fnc_getVolume
};

_volume = (_volume max 0) min 1;

/* Preserve the established PRC-163 loudness curve expected by ACRE. */
_volume ^ 3
