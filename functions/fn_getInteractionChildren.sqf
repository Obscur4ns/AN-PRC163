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
private _nativeChildren = [
    _target
] call acre_ace_interact_fnc_radioListChildrenActions;
private _insertPRC163 = missionNamespace getVariable [
    "UKSF_PRC163_interactionChildren",
    objNull
];
if !(_insertPRC163 isEqualType {}) exitWith {
    _nativeChildren
};
private _prefix = "acre_prc163_id_";
private _healthyPairs = [];
private _healthyEndpoints = [];
private _pilotEnabled = missionNamespace getVariable [
    "UKSF_PRC163_SingleInstancePilot",
    false
];
if (_pilotEnabled) then {
    private _endpointMap = missionNamespace getVariable [
        "UKSF_PRC163_endpointMap",
        createHashMap
    ];
    {
        private _radioA = toLower _x;
        private _entry = _endpointMap getOrDefault [
            _x,
            []
        ];
        private _radioB = toLower (
            _entry param [
                0,
                "",
                [""]
            ]
        );
        if (
            [
                _radioA,
                _radioB,
                _player
            ] call UKSF_PRC163_fnc_isPairHealthy
        ) then {
            _healthyPairs pushBackUnique _radioA;
            _healthyEndpoints pushBackUnique _radioA;
            _healthyEndpoints pushBackUnique _radioB;
        };
    } forEach (
        keys _endpointMap
    );
} else {
    private _gearRadios = (
        [_player] call acre_sys_core_fnc_getGear
    ) apply {
        toLower _x
    };
    {
        private _radioA = _x;

        if (_radioA find _prefix isEqualTo 0) then {
            private _number = parseNumber (
                _radioA select [
                    count _prefix
                ]
            );
            if (
                _number > 0 &&
                {(_number mod 2) isEqualTo 1}
            ) then {
                private _radioB = format [
                    "%1%2",
                    _prefix,
                    _number + 1
                ];
                if (
                    [
                        _radioA,
                        _radioB,
                        _player
                    ] call UKSF_PRC163_fnc_isPairHealthy
                ) then {
                    _healthyPairs pushBackUnique _radioA;
                    _healthyEndpoints pushBackUnique _radioA;
                    _healthyEndpoints pushBackUnique _radioB;
                };
            };
        };
    } forEach _gearRadios;
};
if (_healthyPairs isEqualTo []) exitWith {
    _nativeChildren
};
private _children = _nativeChildren select {
    private _action = _x param [
        0,
        []
    ];
    private _actionName = toLower (
        _action param [
            0,
            ""
        ]
    );
    !(_actionName in _healthyEndpoints)
};
private _picture = getText (
    configFile >>
    "CfgWeapons" >>
    "ACRE_PRC163" >>
    "picture"
);
private _prc163Action = [
    "UKSF_PRC163_Radios",
    [
        "AN/PRC-163",
        "AN/PRC-163 Radios"
    ] select (count _healthyPairs > 1),
    _picture,
    {},
    {true},
    {
        params [
            "_target",
            "_player"
        ];
        private _insert = missionNamespace getVariable [
            "UKSF_PRC163_interactionChildren",
            objNull
        ];
        if !(_insert isEqualType {}) exitWith {
            []
        };
        [
            _target,
            _player
        ] call _insert
    }
] call ace_interact_menu_fnc_createAction;
_children pushBack [
    _prc163Action,
    [],
    _target
];
_children