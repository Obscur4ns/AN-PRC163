params [
    ["_radioId","",[""]],
    "_event",
    ["_requestedState",0,[0,false]],
    "_radioData"
];

private _prefix = "acre_prc163_id_";
private _sourceRadioId = toLower _radioId;

if (_sourceRadioId find _prefix != 0) exitWith {
    false
};

private _pair = [
    _sourceRadioId,
    player,
    false
] call UKSF_PRC163_fnc_resolvePair;

_pair params [
    ["_radioA","",[""]],
    ["_radioB","",[""]]
];

if (
    _radioA isEqualTo "" ||
    {_radioB isEqualTo ""}
) exitWith {
    false
};

_requestedState = if (
    _requestedState isEqualTo 1 ||
    {_requestedState isEqualTo true}
) then {
    1
} else {
    if (
        _requestedState isEqualType 0 &&
        {abs (_requestedState - 0.5) < 0.001}
    ) then {
        0.5
    } else {
        0
    }
};

private _guardName = format [
    "UKSF_PRC163_powerSync_%1",
    _radioA
];

if (
    missionNamespace getVariable [
        _guardName,
        false
    ]
) exitWith {
    private _baseArguments = +_this;

    _baseArguments set [
        2,
        _requestedState
    ];

    _baseArguments call acre_sys_prc152_fnc_setOnOffState;
    true
};

private _applyPairPower = {
    params [
        ["_state",0,[0]]
    ];

    missionNamespace setVariable [
        _guardName,
        true
    ];

    private _successA = [
        _radioA,
        "setOnOffState",
        _state
    ] call acre_sys_data_fnc_dataEvent;

    private _successB = [
        _radioB,
        "setOnOffState",
        _state
    ] call acre_sys_data_fnc_dataEvent;

    missionNamespace setVariable [
        _guardName,
        false
    ];

    (
        !(_successA isEqualTo false) &&
        {!(_successB isEqualTo false)}
    )
};

if (
    _requestedState isEqualTo 1 &&
    {
        !(
            [
                _radioA
            ] call UKSF_PRC163_fnc_hasUsableBattery
        )
    }
) exitWith {
    [
        0
    ] call _applyPairPower;

    private _physicalSlot = [
        _radioA
    ] call UKSF_PRC163_fnc_getBatterySlot;

    private _radioName = if (
        _physicalSlot >= 1
    ) then {
        format [
            "AN/PRC-163 %1",
            _physicalSlot
        ]
    } else {
        "AN/PRC-163"
    };

    [
        format [
            "<t align='center'>%1<br/>BATTERY UNAVAILABLE</t>",
            _radioName
        ],
        1.5,
        player,
        10
    ] call UKSF_PRC163_fnc_notifyStatus;

    false
};

private _bootName = format [
    "UKSF_PRC163_powerBoot_%1",
    _radioA
];

private _bootTokenName = format [
    "UKSF_PRC163_powerBootToken_%1",
    _radioA
];

private _bootControlIds = [
    16610,
    16611,
    16612,
    16613
];

private _clearBootControls = {
    disableSerialization;

    private _display = uiNamespace getVariable [
        "UKSF_PRC163_display",
        displayNull
    ];

    if !(isNull _display) then {
        {
            private _control = _display displayCtrl _x;

            if !(isNull _control) then {
                ctrlDelete _control;
            };
        } forEach _bootControlIds;
    };
};

if (_requestedState isEqualTo 0) exitWith {
    [
        _radioA,
        player,
        false
    ] call UKSF_PRC163_fnc_normalizePairState;

    missionNamespace setVariable [
        _bootName,
        false
    ];

    missionNamespace setVariable [
        _bootTokenName,
        (
            missionNamespace getVariable [
                _bootTokenName,
                0
            ]
        ) + 1
    ];

    call _clearBootControls;

    [
        0
    ] call _applyPairPower
};

if (_requestedState isEqualTo 0.5) exitWith {
    [
        0.5
    ] call _applyPairPower
};

private _currentPower = [
    _radioA,
    "getOnOffState"
] call acre_sys_data_fnc_dataEvent;

if !(
    _currentPower isEqualTo 1 ||
    {_currentPower isEqualTo true}
) then {
    [
        _radioA,
        player,
        false
    ] call UKSF_PRC163_fnc_normalizePairState;
};

if (
    _currentPower isEqualTo 1 ||
    {_currentPower isEqualTo true}
) exitWith {
    [
        1
    ] call _applyPairPower
};

if (
    missionNamespace getVariable [
        _bootName,
        false
    ]
) exitWith {
    true
};

disableSerialization;

private _display = uiNamespace getVariable [
    "UKSF_PRC163_display",
    displayNull
];

private _guiRadio = toLower (
    uiNamespace getVariable [
        "UKSF_PRC163_guiRadio",
        ""
    ]
);

private _useBootSequence = (
    hasInterface &&
    {!isNull _display} &&
    {
        _guiRadio isEqualTo "" ||
        {_guiRadio isEqualTo _radioA}
    }
);

if (!_useBootSequence) exitWith {
    [
        1
    ] call _applyPairPower
};

call _clearBootControls;

private _bootToken = (
    missionNamespace getVariable [
        _bootTokenName,
        0
    ]
) + 1;

missionNamespace setVariable [
    _bootTokenName,
    _bootToken
];

missionNamespace setVariable [
    _bootName,
    true
];

private _loadingApplied = [
    0.5
] call _applyPairPower;

if (!_loadingApplied) exitWith {
    missionNamespace setVariable [
        _bootName,
        false
    ];

    false
};

[
    _radioA,
    _radioB,
    _guardName,
    _bootName,
    _bootTokenName,
    _bootToken,
    _display,
    _bootControlIds
] spawn {
    disableSerialization;

    params [
        "_radioA",
        "_radioB",
        "_guardName",
        "_bootName",
        "_bootTokenName",
        "_bootToken",
        "_display",
        "_bootControlIds"
    ];

    private _bootValid = {
        (
            missionNamespace getVariable [
                _bootName,
                false
            ]
        ) &&
        {
            (
                missionNamespace getVariable [
                    _bootTokenName,
                    -1
                ]
            ) isEqualTo _bootToken
        }
    };

    private _deleteControls = {
        if !(isNull _display) then {
            {
                private _control = _display displayCtrl _x;

                if !(isNull _control) then {
                    ctrlDelete _control;
                };
            } forEach _bootControlIds;
        };
    };

    private _applyFinalPairPower = {
        params [
            ["_state",0,[0]]
        ];

        missionNamespace setVariable [
            _guardName,
            true
        ];

        private _successA = [
            _radioA,
            "setOnOffState",
            _state
        ] call acre_sys_data_fnc_dataEvent;

        private _successB = [
            _radioB,
            "setOnOffState",
            _state
        ] call acre_sys_data_fnc_dataEvent;

        missionNamespace setVariable [
            _guardName,
            false
        ];

        (
            !(_successA isEqualTo false) &&
            {!(_successB isEqualTo false)}
        )
    };

    private _uiSize = 1.25 * safeZoneH;
    private _uiY = 0.5 - (_uiSize / 2);
    private _aspect = pixelW / pixelH;
    private _imageWidth = _uiSize * _aspect;
    private _imageX = 0.5 - (_imageWidth / 2);

    private _imgX = {
        params ["_px"];
        _imageX + ((_px / 2048) * _imageWidth)
    };

    private _imgW = {
        params ["_px"];
        (_px / 2048) * _imageWidth
    };

    private _imgY = {
        params ["_px"];
        _uiY + ((_px / 2048) * _uiSize)
    };

    private _imgH = {
        params ["_px"];
        (_px / 2048) * _uiSize
    };

    private _lcdDark = [
        0.141176471,
        0.141176471,
        0.141176471,
        0.96
    ];

    private _logoPath = "\UKSF_PRC163\data\ui\l3harris_logo.paa";
    private _logoExists = fileExists _logoPath;
    private _logo = controlNull;
    private _logoFallback = controlNull;

    if !(isNull _display) then {
        if (_logoExists) then {
            _logo = _display ctrlCreate [
                "RscPicture",
                16610
            ];
            _logo ctrlSetPosition [
                [850] call _imgX,
                [854] call _imgY,
                [348] call _imgW,
                [116] call _imgH
            ];
            _logo ctrlSetTextColor [1,1,1,1];
            _logo ctrlSetText _logoPath;
            _logo ctrlShow true;
            _logo ctrlCommit 0;
        } else {
            _logoFallback = _display ctrlCreate [
                "UKSF_PRC163_RscLCDTextCentre",
                16612
            ];
            _logoFallback ctrlSetText "L3HARRIS";
            _logoFallback ctrlSetFontHeight (0.024 * safeZoneH);
            _logoFallback ctrlSetTextColor _lcdDark;
            _logoFallback ctrlSetPosition [
                [850] call _imgX,
                [870] call _imgY,
                [348] call _imgW,
                [84] call _imgH
            ];
            _logoFallback ctrlShow true;
            _logoFallback ctrlCommit 0;
            diag_log format [
                "[UKSF_PRC163] Startup logo not found: %1",
                _logoPath
            ];
        };
    };

    private _logoEnd = diag_tickTime + 3;

    waitUntil {
        uiSleep 0.05;
        diag_tickTime >= _logoEnd ||
        {!(call _bootValid)}
    };

    if !(call _bootValid) exitWith {
        call _deleteControls;
    };

    if !(isNull _logo) then {
        ctrlDelete _logo;
    };

    if !(isNull _logoFallback) then {
        ctrlDelete _logoFallback;
    };

    private _title = controlNull;
    private _progressTrack = controlNull;
    private _progress = controlNull;

    private _progressX = [884] call _imgX;
    private _progressY = [930] call _imgY;
    private _progressWidth = [280] call _imgW;
    private _progressHeight = [14] call _imgH;

    if !(isNull _display) then {
        _title = _display ctrlCreate [
            "UKSF_PRC163_RscLCDTextCentre",
            16611
        ];
        _title ctrlSetText "FALCON IV";
        _title ctrlSetFontHeight (0.019 * safeZoneH);
        _title ctrlSetTextColor _lcdDark;
        _title ctrlSetPosition [
            [860] call _imgX,
            [866] call _imgY,
            [328] call _imgW,
            [34] call _imgH
        ];
        _title ctrlCommit 0;


        _progressTrack = _display ctrlCreate [
            "RscText",
            16612
        ];
        _progressTrack ctrlSetBackgroundColor [
            0.141176471,
            0.141176471,
            0.141176471,
            0.2
        ];
        _progressTrack ctrlSetPosition [
            _progressX,
            _progressY,
            _progressWidth,
            _progressHeight
        ];
        _progressTrack ctrlShow true;
        _progressTrack ctrlCommit 0;

        _progress = _display ctrlCreate [
            "RscText",
            16613
        ];
        _progress ctrlSetBackgroundColor _lcdDark;
        _progress ctrlSetPosition [
            _progressX,
            _progressY,
            0,
            _progressHeight
        ];
        _progress ctrlShow true;
        _progress ctrlCommit 0;
    };

    private _barStart = diag_tickTime;
    private _stageEnd = _barStart + 5.25;

    waitUntil {
        uiSleep 0.05;

        if !(isNull _progress) then {
            private _progressValue = (
                (diag_tickTime - _barStart) / 5
            ) max 0 min 1;

            _progress ctrlSetPosition [
                _progressX,
                _progressY,
                _progressWidth * _progressValue,
                _progressHeight
            ];
            _progress ctrlCommit 0;
        };

        diag_tickTime >= _stageEnd ||
        {!(call _bootValid)}
    };

    if !(call _bootValid) exitWith {
        call _deleteControls;
    };

    if !(isNull _progress) then {
        _progress ctrlSetPosition [
            _progressX,
            _progressY,
            _progressWidth,
            _progressHeight
        ];
        _progress ctrlCommit 0;
    };

    call _deleteControls;

    missionNamespace setVariable [
        _bootName,
        false
    ];

    [
        1
    ] call _applyFinalPairPower;
};

true
