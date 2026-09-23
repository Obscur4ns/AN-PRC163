params [
    ["_radioId","",[""]]
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find _prefix != 0}
) exitWith {
    _this call acre_sys_prc152_fnc_getSpatial
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
    _this call acre_sys_prc152_fnc_getSpatial
};

private _stateName = [
    "prc163SpatialA",
    "prc163SpatialB"
] select _line;

private _spatial = [
    _radioA,
    "getState",
    _stateName
] call acre_sys_data_fnc_dataEvent;

if (
    isNil "_spatial" ||
    {!(_spatial isEqualType 0)}
) exitWith {
    _this call acre_sys_prc152_fnc_getSpatial
};

if !(_spatial in [-1,0,1]) then {
    _spatial = 0;
};

_spatial
