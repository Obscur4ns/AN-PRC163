params [
    ["_unit",objNull,[objNull]],
    ["_records",[],[[]]]
];

if (!isServer || {isNull _unit}) exitWith {false};

private _callerOwner = remoteExecutedOwner;

if (
    _callerOwner > 0 &&
    {owner _unit != _callerOwner}
) exitWith {false};

private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") exitWith {false};

private _cleanRecords = [];

{
    if (_x isEqualType [] && {(count _x) >= 5}) then {
        private _slot = _x param [0,-1,[0]];
        private _installed = _x param [1,0,[0]];
        private _serial = _x param [2,"",[""]];
        private _charge = _x param [3,0,[0]];
        private _health = _x param [4,1,[0]];

        if (_slot >= 1 && {_slot <= 16}) then {
            _slot = floor _slot;
            _installed = if (_installed isEqualTo 0) then {0} else {1};
            _charge = (_charge max 0) min 1;
            _health = (_health max 0) min 1;

            if (_installed isEqualTo 0) then {
                _serial = "";
                _charge = 0;
            };

            private _record = [
                _slot,
                _installed,
                _serial,
                _charge,
                _health
            ];

            private _existing = _cleanRecords findIf {
                (_x select 0) isEqualTo _slot
            };

            if (_existing < 0) then {
                _cleanRecords pushBack _record;
            } else {
                _cleanRecords set [_existing,_record];
            };
        };
    };
} forEach _records;

_cleanRecords sort true;

private _store = profileNamespace getVariable [
    "UKSF_PRC163_BatteryStore",
    [1,[]]
];

if !(_store isEqualType [] && {(count _store) >= 2}) then {
    _store = [1,[]];
};

private _version = _store param [0,1,[0]];
private _players = _store param [1,[],[[]]];

if (_version != 1) then {
    _version = 1;
    _players = [];
};

private _playerIndex = _players findIf {
    (_x param [0,"",[""]]) isEqualTo _uid
};

private _playerRecord = [
    _uid,
    _cleanRecords
];

if (_playerIndex < 0) then {
    _players pushBack _playerRecord;
} else {
    _players set [_playerIndex,_playerRecord];
};

profileNamespace setVariable [
    "UKSF_PRC163_BatteryStore",
    [_version,_players]
];

saveProfileNamespace;

missionNamespace setVariable [
    "UKSF_PRC163_lastBatterySave",
    [_uid,_cleanRecords]
];

true