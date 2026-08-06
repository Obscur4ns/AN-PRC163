params [
    ["_target",objNull,[objNull]],
    ["_player",objNull,[objNull]]
];
if (isNull _target) then {_target = player};
if (isNull _player) then {_player = player};

private _native = missionNamespace getVariable ["UKSF_PRC163_nativeRadioListChildrenActions",objNull];
private _children = [];
if (_native isEqualType {}) then {
    _children = [_target] call _native;
};
if !(_children isEqualType []) then {_children = []};

private _prefix = "acre_prc163_id_";
_children = _children select {
    private _action = _x param [0,[]];
    private _name = toLower (_action param [0,""]);
    _name find _prefix != 0
};

private _insert = missionNamespace getVariable ["UKSF_PRC163_interactionChildren",objNull];
if (_insert isEqualType {}) then {
    private _prcChildren = [_target,_player] call _insert;
    if (_prcChildren isEqualType []) then {_children append _prcChildren};
};
_children
