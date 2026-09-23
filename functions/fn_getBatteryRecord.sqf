params [
    ["_radioId","",[""]]
];

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

private _pair = [
    toLower _radioId,
    player,
    false
] call UKSF_PRC163_fnc_resolvePair;

private _radioA = _pair param [0,"",[""]];
if (_radioA isEqualTo "") exitWith {[]};

private _slot = [
    _radioA,
    player
] call UKSF_PRC163_fnc_getBatterySlot;

if (_slot < 1) exitWith {[]};

private _installed = [
    _radioA,
    "getState",
    "prc163BatteryInstalled"
] call acre_sys_data_fnc_dataEvent;

private _serial = [
    _radioA,
    "getState",
    "prc163BatterySerial"
] call acre_sys_data_fnc_dataEvent;

private _charge = [
    _radioA,
    "getState",
    "prc163BatteryCharge"
] call acre_sys_data_fnc_dataEvent;

private _health = [
    _radioA,
    "getState",
    "prc163BatteryHealth"
] call acre_sys_data_fnc_dataEvent;

if (isNil "_installed") then {_installed = 0};
if (isNil "_serial") then {_serial = ""};
if (isNil "_charge") then {_charge = 0};
if (isNil "_health") then {_health = 1};

_installed = if (_installed isEqualTo 0) then {0} else {1};
_charge = (_charge max 0) min 1;
_health = (_health max 0) min 1;

if (_installed isEqualTo 0) then {
    _serial = "";
    _charge = 0;
};

[_slot,_installed,_serial,_charge,_health]
