params [
    ["_radioId","",[""]],
    "_event",
    "_spatial",
    "_extra"
];

private _prefix = "acre_prc163_id_";
_radioId = toLower _radioId;

if (
    _radioId find _prefix != 0 ||
    {
        !(
            _spatial isEqualType 0 ||
            {_spatial isEqualType ""}
        )
    }
) exitWith {
    false
};

private _spatialValue = -99;

if (_spatial isEqualType 0) then {
    if (_spatial in [-1,0,1]) then {
        _spatialValue = _spatial;
    };
} else {
    switch (toUpper _spatial) do {
        case "LEFT": {
            _spatialValue = -1;
        };

        case "RIGHT": {
            _spatialValue = 1;
        };

        case "CENTER";
        case "CENTRE";
        case "BOTH": {
            _spatialValue = 0;
        };
    };
};

if !(_spatialValue in [-1,0,1]) exitWith {
    false
};

private _pair = [
    _radioId,
    player,
    false
] call UKSF_PRC163_fnc_resolvePair;

_pair params [
    ["_radioA","",[""]],
    ["_radioB","",[""]],
    ["_line",-1,[0]]
];

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""} ||
    {!(_line in [0,1])}
) exitWith {
    false
};

private _targetRadio = [
    _radioA,
    _radioB
] select _line;

[
    _targetRadio,
    _event,
    _spatialValue,
    _extra
] call acre_sys_prc152_fnc_setSpatial;

private _actualSpatial = [
    _targetRadio,
    "getState",
    "ACRE_INTERNAL_RADIOSPATIALIZATION"
] call acre_sys_data_fnc_dataEvent;

if (
    !(_actualSpatial isEqualType 0) ||
    {!(_actualSpatial isEqualTo _spatialValue)}
) exitWith {
    false
};

private _stateName = [
    "prc163SpatialA",
    "prc163SpatialB"
] select _line;

{
    [
        _x,
        "setState",
        [
            _stateName,
            _spatialValue
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

true
