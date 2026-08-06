params [
    ["_radioId","",[""]],
    ["_unit",objNull,[objNull]],
    ["_requireAvailable",true,[true]]
];

if (isNull _unit) then {_unit = player};

private _prefix = "acre_prc163_id_";
_radioId = toLower _radioId;

if (isNull _unit || {_radioId find _prefix != 0}) exitWith {["","",-1]};

private _radioA = "";
private _radioB = "";

if (missionNamespace getVariable ["UKSF_PRC163_SingleInstancePilot",false]) then {
    private _map = missionNamespace getVariable ["UKSF_PRC163_endpointMap",createHashMap];
    private _keys = keys _map;
    private _entry = _map getOrDefault [_radioId,[]];

    if (_entry isNotEqualTo []) then {
        _radioA = _radioId;
    } else {
        private _statePrimary = [_radioId,"getState","prc163PrimaryRadio"] call acre_sys_data_fnc_dataEvent;
        if (!isNil "_statePrimary" && {_statePrimary isEqualType ""}) then {
            _statePrimary = toLower _statePrimary;
            if (_statePrimary in _keys) then {
                _radioA = _statePrimary;
                _entry = _map getOrDefault [_radioA,[]];
            };
        };

        if (_radioA isEqualTo "") then {
            private _index = _keys findIf {
                private _candidate = _map getOrDefault [_x,[]];
                toLower (_candidate param [0,"",[""]]) isEqualTo _radioId
            };
            if (_index >= 0) then {
                _radioA = toLower (_keys select _index);
                _entry = _map getOrDefault [_radioA,[]];
            };
        };
    };

    _radioA = toLower _radioA;
    _radioB = toLower (_entry param [0,"",[""]]);
} else {
    private _gear = ([_unit] call acre_sys_core_fnc_getGear) apply {toLower _x};
    if (_radioId in _gear) then {
        private _number = parseNumber (_radioId select [count _prefix]);
        if (_number >= 1) then {
            private _aNumber = if ((_number mod 2) isEqualTo 1) then {_number} else {_number - 1};
            _radioA = format ["%1%2",_prefix,_aNumber];
            _radioB = format ["%1%2",_prefix,_aNumber + 1];
        };
    };
};

if !([_radioA,_radioB,_unit,_requireAvailable] call UKSF_PRC163_fnc_isPairHealthy) exitWith {["","",-1]};

private _line = [_radioA,_radioB] find _radioId;
if !(_line in [0,1]) exitWith {["","",-1]};
[_radioA,_radioB,_line]
