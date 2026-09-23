params [
    ["_radioId","",[""]],
    ["_elapsedSeconds",0,[0]]
];

private _enabled = missionNamespace getVariable [
    "UKSF_PRC163_BatteriesEnabled",
    true
];

if (!_enabled) exitWith {0};

private _sourceRadioId = toLower _radioId;
if (
    _sourceRadioId isEqualTo "" ||
    {_sourceRadioId find "acre_prc163_id_" != 0} ||
    {_elapsedSeconds <= 0}
) exitWith {0};

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
) exitWith {0};

if !([_radioA] call UKSF_PRC163_fnc_hasUsableBattery) exitWith {0};

private _powerA = [
    _radioA,
    "getOnOffState"
] call acre_sys_data_fnc_dataEvent;

private _powerB = [
    _radioB,
    "getOnOffState"
] call acre_sys_data_fnc_dataEvent;

if !(
    _powerA isEqualTo 1 ||
    {_powerA isEqualTo true} ||
    {_powerB isEqualTo 1} ||
    {_powerB isEqualTo true}
) exitWith {0};

private _readState = {
    params ["_radio","_name","_default"];

    private _value = [
        _radio,
        "getState",
        _name
    ] call acre_sys_data_fnc_dataEvent;

    if (isNil "_value") then {_default} else {_value}
};

private _setStateIfChanged = {
    params ["_radio","_name","_desired"];

    private _current = [
        _radio,
        "getState",
        _name
    ] call acre_sys_data_fnc_dataEvent;

    if (
        !isNil "_current" &&
        {_current isEqualTo _desired}
    ) exitWith {false};

    [
        _radio,
        "setState",
        [_name,_desired]
    ] call acre_sys_data_fnc_dataEvent;

    true
};

private _chargeA = [_radioA,"prc163BatteryCharge",0] call _readState;
private _chargeB = [_radioB,"prc163BatteryCharge",_chargeA] call _readState;
private _healthA = [_radioA,"prc163BatteryHealth",1] call _readState;
private _healthB = [_radioB,"prc163BatteryHealth",_healthA] call _readState;

private _charge = ((_chargeA min _chargeB) max 0) min 1;
private _health = ((_healthA min _healthB) max 0.05) min 1;

private _baseLifeHours = missionNamespace getVariable [
    "UKSF_PRC163_BatteryLifeHours",
    12
];

private _dualWatchExtra = missionNamespace getVariable [
    "UKSF_PRC163_BatteryDualWatchExtra",
    0.25
];

private _receiveExtra = missionNamespace getVariable [
    "UKSF_PRC163_BatteryReceiveExtra",
    0.5
];

private _transmitExtra = missionNamespace getVariable [
    "UKSF_PRC163_BatteryTransmitExtra",
    5
];

private _lowThreshold = missionNamespace getVariable [
    "UKSF_PRC163_BatteryLowThreshold",
    0.1
];

private _criticalThreshold = missionNamespace getVariable [
    "UKSF_PRC163_BatteryCriticalThreshold",
    0.05
];

if (_baseLifeHours <= 0) then {
    _baseLifeHours = 12;
};

_lowThreshold = (_lowThreshold max 0) min 1;
_criticalThreshold = (_criticalThreshold max 0) min _lowThreshold;

private _multiplier = 1;

private _dualWatch = [_radioA,"prc163DualWatch",0] call _readState;
if (_dualWatch isEqualTo 1) then {
    _multiplier = _multiplier + _dualWatchExtra;
};

private _receivingA = [_radioA,"prc163ReceivingA",0] call _readState;
private _receivingB = [_radioA,"prc163ReceivingB",0] call _readState;

if (_receivingA isEqualTo 1) then {
    _multiplier = _multiplier + _receiveExtra;
};

if (_receivingB isEqualTo 1) then {
    _multiplier = _multiplier + _receiveExtra;
};

private _transmittingA = [_radioA,"prc163TransmittingA",0] call _readState;
private _transmittingB = [_radioA,"prc163TransmittingB",0] call _readState;

if (
    _transmittingA isEqualTo 1 ||
    {_transmittingB isEqualTo 1}
) then {
    _multiplier = _multiplier + _transmitExtra;
};

private _effectiveLifeSeconds = _baseLifeHours * 3600 * _health;
private _drain = (_elapsedSeconds / _effectiveLifeSeconds) * _multiplier;
private _newCharge = (_charge - _drain) max 0;

if (abs (_newCharge - _charge) > 0.0000001) then {
    missionNamespace setVariable [
        "UKSF_PRC163_batteryLocalDirty",
        true
    ];
};

private _lowWarnedA = [_radioA,"prc163BatteryLowWarned",0] call _readState;
private _lowWarnedB = [_radioB,"prc163BatteryLowWarned",0] call _readState;
private _criticalWarnedA = [_radioA,"prc163BatteryCriticalWarned",0] call _readState;
private _criticalWarnedB = [_radioB,"prc163BatteryCriticalWarned",0] call _readState;

private _lowWarned = _lowWarnedA max _lowWarnedB;
private _criticalWarned = _criticalWarnedA max _criticalWarnedB;

if (_newCharge > _lowThreshold) then {
    _lowWarned = 0;
    _criticalWarned = 0;
};

if (
    _newCharge <= _lowThreshold &&
    {_newCharge > _criticalThreshold} &&
    {_lowWarned isEqualTo 0}
) then {
    [
        "Acre_GenericBeepLow",
        [0,0,0],
        [0,0,0],
        0.7,
        false
    ] call acre_sys_sounds_fnc_playSound;

    _lowWarned = 1;
};

if (
    _newCharge <= _criticalThreshold &&
    {_newCharge > 0} &&
    {_criticalWarned isEqualTo 0}
) then {
    [
        "Acre_GenericBeepLow",
        [0,0,0],
        [0,0,0],
        0.7,
        false
    ] call acre_sys_sounds_fnc_playSound;

    [{
        [
            "Acre_GenericBeepLow",
            [0,0,0],
            [0,0,0],
            0.7,
            false
        ] call acre_sys_sounds_fnc_playSound;
    },[],0.3] call CBA_fnc_waitAndExecute;

    [{
        [
            "Acre_GenericBeepLow",
            [0,0,0],
            [0,0,0],
            0.7,
            false
        ] call acre_sys_sounds_fnc_playSound;
    },[],0.6] call CBA_fnc_waitAndExecute;

    _lowWarned = 1;
    _criticalWarned = 1;
};

{
    [_x,"prc163BatteryCharge",_newCharge] call _setStateIfChanged;
    [_x,"prc163BatteryHealth",_health] call _setStateIfChanged;
    [_x,"prc163BatteryLowWarned",_lowWarned] call _setStateIfChanged;
    [_x,"prc163BatteryCriticalWarned",_criticalWarned] call _setStateIfChanged;
} forEach [_radioA,_radioB];

missionNamespace setVariable [
    "UKSF_PRC163_lastBatteryDrain",
    [
        _radioA,
        _radioB,
        _elapsedSeconds,
        _multiplier,
        _drain,
        _charge,
        _newCharge
    ]
];

_drain
