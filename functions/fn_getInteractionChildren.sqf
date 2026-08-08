params [
    ["_target",objNull,[objNull]],
    ["_player",objNull,[objNull]]
];

if (isNull _target) then {
    _target = player;
};

if (isNull _player) then {
    _player = player;
};

/*
    ACRE keeps ownership of its radio-list generator. This wrapper is called
    only by ACRE_Interact.insertChildren and never replaces ACRE's function.
*/
private _nativeChildren = [];
if (!isNil "acre_ace_interact_fnc_radioListChildrenActions") then {
    _nativeChildren = [_target] call acre_ace_interact_fnc_radioListChildrenActions;
};

if !(_nativeChildren isEqualType []) then {
    _nativeChildren = [];
};

private _insertPRC163 = missionNamespace getVariable [
    "UKSF_PRC163_interactionChildren",
    objNull
];

/* Fail open: if PRC-163 interaction generation is unavailable, return ACRE. */
if !(_insertPRC163 isEqualType {}) exitWith {
    _nativeChildren
};

private _prcChildren = [
    _target,
    _player
] call _insertPRC163;

if !(_prcChildren isEqualType []) exitWith {
    _nativeChildren
};

/*
    If no healthy PRC-163 pair was produced, do not filter anything from ACRE.
    This prevents a transient pair-state failure from removing native actions.
*/
if (_prcChildren isEqualTo []) exitWith {
    _nativeChildren
};

private _prefix = "acre_prc163_id_";
private _children = _nativeChildren select {
    private _action = _x param [0,[]];
    private _actionName = toLower (_action param [0,""]);
    _actionName find _prefix isNotEqualTo 0
};

_children append _prcChildren;
_children
