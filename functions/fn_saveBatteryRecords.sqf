params [["_force",false,[false]]];

if (!hasInterface || {isNull player}) exitWith {false};

private _records = [] call UKSF_PRC163_fnc_getBatteryRecords;

if (_records isEqualTo []) exitWith {false};

private _lastSent = missionNamespace getVariable [
    "UKSF_PRC163_lastBatterySent",
    []
];

if (!_force && {_records isEqualTo _lastSent}) exitWith {true};

[
    player,
    _records
] remoteExecCall [
    "UKSF_PRC163_fnc_serverSaveBatteryRecords",
    2
];

private _cachedRecords = _records apply {+_x};

missionNamespace setVariable [
    "UKSF_PRC163_lastBatterySent",
    _cachedRecords
];

missionNamespace setVariable [
    "UKSF_PRC163_lastBatterySaveRequest",
    [
        diag_tickTime,
        _cachedRecords,
        _force
    ]
];

true