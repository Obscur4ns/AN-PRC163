params [["_unit",objNull,[objNull]]];
if (!isServer || {isNull _unit}) exitWith {false};
private _callerOwner = remoteExecutedOwner;
if (_callerOwner > 0 && {owner _unit != _callerOwner}) exitWith {false};
private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") exitWith {false};
private _store = profileNamespace getVariable ["UKSF_PRC163_BatteryStore",[1,[]]];
if !(_store isEqualType [] && {count _store >= 2}) then {_store = [1,[]]};
private _version = _store param [0,1,[0]];
private _players = _store param [1,[],[[]]];
private _records = [];
if (_version isEqualTo 1) then {
    private _index = _players findIf {(_x param [0,"",[""]]) isEqualTo _uid};
    if (_index >= 0) then {_records = (_players select _index) param [1,[],[[]]]};
};
if (local _unit && {hasInterface}) then {
    [_records,false,-1] call UKSF_PRC163_fnc_receiveBatteryRecords;
} else {
    [_records,false,-1] remoteExecCall ["UKSF_PRC163_fnc_receiveBatteryRecords",owner _unit];
};
true
