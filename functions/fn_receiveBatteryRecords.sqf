params [
    ["_records",[],[[]]],
    ["_isSaveAck",false,[false]],
    ["_requestId",-1,[0]]
];
if (!hasInterface) exitWith {false};
if (remoteExecutedOwner > 2 && {remoteExecutedOwner != clientOwner}) exitWith {false};

private _clean = [];
{
    if (_x isEqualType [] && {count _x >= 5}) then {
        private _slot = floor (_x param [0,-1,[0]]);
        private _installed = _x param [1,0,[0]];
        private _serial = _x param [2,"",[""]];
        private _charge = _x param [3,0,[0]];
        private _health = _x param [4,1,[0]];
        if (_slot >= 1 && {_slot <= 16}) then {
            _installed = if (_installed isEqualTo 0) then {0} else {1};
            _charge = (_charge max 0) min 1;
            _health = (_health max 0) min 1;
            if (_installed isEqualTo 0) then {_serial = ""; _charge = 0};
            private _record = [_slot,_installed,_serial,_charge,_health];
            private _index = _clean findIf {(_x select 0) isEqualTo _slot};
            if (_index < 0) then {_clean pushBack _record} else {_clean set [_index,_record]};
        };
    };
} forEach _records;
_clean sort true;

private _local = [] call UKSF_PRC163_fnc_getBatteryRecords;
private _dirty = missionNamespace getVariable ["UKSF_PRC163_batteryLocalDirty",false];

if (_isSaveAck) exitWith {
    private _pendingId = missionNamespace getVariable ["UKSF_PRC163_batteryPendingRequestId",-2];
    if (_requestId isNotEqualTo _pendingId) exitWith {true};

    if (_clean isEqualTo _local) then {
        missionNamespace setVariable ["UKSF_PRC163_batteryLocalDirty",false];
        missionNamespace setVariable ["UKSF_PRC163_batteryPendingRequestId",-1];
        missionNamespace setVariable ["UKSF_PRC163_lastBatteryLoad",[_clean,true]];
        true
    } else {
        missionNamespace setVariable ["UKSF_PRC163_batteryPendingRequestId",-1];
        [true] call UKSF_PRC163_fnc_saveBatteryRecords;
        false
    }
};

if (_dirty) exitWith {
    missionNamespace setVariable ["UKSF_PRC163_lastBatteryLoad",[_local,_local isNotEqualTo []]];
    _local isNotEqualTo []
};

private _applied = if (_clean isEqualTo []) then {false} else {[_clean] call UKSF_PRC163_fnc_applyBatteryRecords};
missionNamespace setVariable ["UKSF_PRC163_lastBatteryLoad",[_clean,_applied]];
_applied
