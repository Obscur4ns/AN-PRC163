params [["_force",false,[false]]];

if (!hasInterface || {isNull player}) exitWith {false};

private _records = [] call UKSF_PRC163_fnc_getBatteryRecords;
if (_records isEqualTo []) exitWith {false};

private _cache = _records apply {+_x};

missionNamespace setVariable [
    "UKSF_PRC163_lastBatteryLoad",
    [_cache,true]
];

private _lastSent = missionNamespace getVariable [
    "UKSF_PRC163_lastBatterySent",
    []
];

private _dirty = missionNamespace getVariable [
    "UKSF_PRC163_batteryLocalDirty",
    false
];

private _pendingId = missionNamespace getVariable [
    "UKSF_PRC163_batteryPendingRequestId",
    -1
];

private _pendingAt = missionNamespace getVariable [
    "UKSF_PRC163_batteryPendingAt",
    -100
];

/*
    Do not manufacture a server save just because the 60-second persistence
    tick fired. Send only new/dirty state, forced shutdown state, or a retry
    after an unacknowledged request timeout.
*/
if (
    !_force &&
    {!_dirty} &&
    {_records isEqualTo _lastSent} &&
    {_pendingId < 0}
) exitWith {true};

if (
    !_force &&
    {_records isEqualTo _lastSent} &&
    {_pendingId >= 0} &&
    {diag_tickTime - _pendingAt < 5}
) exitWith {true};

private _requestId = (
    missionNamespace getVariable [
        "UKSF_PRC163_batteryRequestId",
        0
    ]
) + 1;

missionNamespace setVariable [
    "UKSF_PRC163_batteryRequestId",
    _requestId
];

missionNamespace setVariable [
    "UKSF_PRC163_batteryPendingRequestId",
    _requestId
];

missionNamespace setVariable [
    "UKSF_PRC163_batteryPendingAt",
    diag_tickTime
];

missionNamespace setVariable [
    "UKSF_PRC163_lastBatterySent",
    _cache
];

/* Remain dirty until the matching server ACK confirms this exact state. */
missionNamespace setVariable [
    "UKSF_PRC163_batteryLocalDirty",
    true
];

missionNamespace setVariable [
    "UKSF_PRC163_lastBatterySaveRequest",
    [diag_tickTime,_cache,_force,_requestId]
];

[
    player,
    _records,
    _requestId
] remoteExecCall [
    "UKSF_PRC163_fnc_serverSaveBatteryRecords",
    2
];

true
