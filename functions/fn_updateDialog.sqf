params [
    ["_display",displayNull,[displayNull]]
];

if (isNull _display) then {
    _display = uiNamespace getVariable [
        "UKSF_PRC163_display",
        displayNull
    ];
};

if (isNull _display) exitWith {
    false
};

private _selectedColor = [
    0.78,
    0.92,
    0.72,
    1
];

private _unselectedColor = [
    0.38,
    0.48,
    0.36,
    1
];

private _inactiveColor = [
    0.35,
    0.45,
    0.34,
    1
];

private _receiveColor = [
    1,
    0.85,
    0.2,
    1
];

private _transmitColor = [
    1,
    0.35,
    0.2,
    1
];

private _warningColor = [
    1,
    0.75,
    0.2,
    1
];

private _criticalColor = [
    1,
    0.35,
    0.2,
    1
];

private _setText = {
    params [
        "_idc",
        "_text",
        "_color"
    ];

    private _control = _display displayCtrl _idc;

    if !(isNull _control) then {
        _control ctrlSetText _text;
        _control ctrlSetTextColor _color;
    };
};

private _dynamicControls = [
    16310,
    16311,
    16312,
    16313,
    16314,
    16315,
    16317,
    16320,
    16321,
    16322,
    16323,
    16324,
    16325,
    16327,
    16330,
    16331
];

{
    [
        _x,
        "",
        _inactiveColor
    ] call _setText;
} forEach _dynamicControls;

private _radio = [] call UKSF_PRC163_fnc_getTargetRadio;

if (_radio isEqualTo "") exitWith {
    [
        16302,
        "RADIO: NOT AVAILABLE",
        _criticalColor
    ] call _setText;

    false
};

private _state = [
    _radio
] call UKSF_PRC163_fnc_getDisplayState;

if ((count _state) isEqualTo 0) exitWith {
    [
        16302,
        "RADIO: STATE UNAVAILABLE",
        _criticalColor
    ] call _setText;

    false
};

private _hmiState = [
    _radio
] call UKSF_PRC163_fnc_getHMIState;

private _physicalSlot = _state getOrDefault [
    "physicalSlot",
    -1
];

private _radioDisplayName = if (
    _physicalSlot >= 1
) then {
    format [
        "AN/PRC-163 %1",
        _physicalSlot
    ]
} else {
    "AN/PRC-163"
};

private _power = _state getOrDefault [
    "power",
    0
];

private _isPowered = (
    _power isEqualTo 1 ||
    {_power isEqualTo true}
);

private _powerText = if (_isPowered) then {
    "ON"
} else {
    "OFF"
};

private _modeText = _state getOrDefault [
    "modeText",
    "SINGLE"
];

private _batteryInstalled = _state getOrDefault [
    "batteryInstalled",
    0
];

_batteryInstalled = if (
    _batteryInstalled isEqualTo 0
) then {
    0
} else {
    1
};

private _batterySerial = _state getOrDefault [
    "batterySerial",
    ""
];

private _batteryChargePercent = _state getOrDefault [
    "batteryChargePercent",
    0
];

private _batteryHealthPercent = _state getOrDefault [
    "batteryHealthPercent",
    0
];

private _batteryText = _state getOrDefault [
    "batteryText",
    "NO BAT"
];

private _batteryStatus = _state getOrDefault [
    "batteryStatus",
    "NO BATTERY"
];

private _selectedLine = _state getOrDefault [
    "selectedLine",
    0
];

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

private _selectedLineName = [
    "R/T 1",
    "R/T 2"
] select _selectedLine;

private _channelA = _state getOrDefault [
    "channelADisplay",
    1
];

private _channelB = _state getOrDefault [
    "channelBDisplay",
    1
];

private _frequencyA = _state getOrDefault [
    "frequencyAText",
    "---.---"
];

private _frequencyB = _state getOrDefault [
    "frequencyBText",
    "---.---"
];

private _spatialA = toUpper (
    _state getOrDefault [
        "spatialAText",
        "BOTH"
    ]
);

private _spatialB = toUpper (
    _state getOrDefault [
        "spatialBText",
        "BOTH"
    ]
);

if (_spatialA in ["CENTER","CENTRE"]) then {
    _spatialA = "BOTH";
};

if (_spatialB in ["CENTER","CENTRE"]) then {
    _spatialB = "BOTH";
};

private _volumeA = _state getOrDefault [
    "volumeAPercent",
    100
];

private _volumeB = _state getOrDefault [
    "volumeBPercent",
    100
];

private _txPowerA = _state getOrDefault [
    "txPowerA",
    5000
];

private _txPowerB = _state getOrDefault [
    "txPowerB",
    5000
];

private _txPowerAText = _state getOrDefault [
    "txPowerAText",
    "5 W"
];

private _txPowerBText = _state getOrDefault [
    "txPowerBText",
    "5 W"
];

private _selectedTxPower = _state getOrDefault [
    "selectedTxPower",
    [
        _txPowerA,
        _txPowerB
    ] select _selectedLine
];

private _selectedTxPowerText = _state getOrDefault [
    "selectedTxPowerText",
    [
        _txPowerAText,
        _txPowerBText
    ] select _selectedLine
];

private _receivingA = _state getOrDefault [
    "receivingA",
    0
];

private _receivingB = _state getOrDefault [
    "receivingB",
    0
];

private _transmittingA = _state getOrDefault [
    "transmittingA",
    0
];

private _transmittingB = _state getOrDefault [
    "transmittingB",
    0
];

private _dualWatch = _state getOrDefault [
    "dualWatch",
    0
];

private _page = _hmiState getOrDefault [
    "page",
    "HOME"
];

_page = toUpper _page;

private _cursor = _hmiState getOrDefault [
    "cursor",
    0
];

if !(_cursor isEqualType 0) then {
    _cursor = 0;
};

_cursor = floor (
    (_cursor max 0) min 7
);

private _inputBuffer = _hmiState getOrDefault [
    "inputBuffer",
    ""
];

if !(_inputBuffer isEqualType "") then {
    _inputBuffer = "";
};

private _formatPreset = {
    params ["_preset"];

    if (
        !(_preset isEqualType 0) ||
        {_preset < 1} ||
        {_preset > 99}
    ) exitWith {
        "P --"
    };

    if (_preset < 10) then {
        format [
            "P 0%1",
            _preset
        ]
    } else {
        format [
            "P %1",
            _preset
        ]
    }
};

private _channelAText = [
    _channelA
] call _formatPreset;

private _channelBText = [
    _channelB
] call _formatPreset;

private _selectedChannelText = [
    _channelAText,
    _channelBText
] select _selectedLine;

private _selectedFrequency = [
    _frequencyA,
    _frequencyB
] select _selectedLine;

private _selectedVolume = [
    _volumeA,
    _volumeB
] select _selectedLine;

private _selectedSpatial = [
    _spatialA,
    _spatialB
] select _selectedLine;

private _batteryDisplayText = switch (
    _batteryStatus
) do {
    case "LOW": {
        format [
            "%1 LOW",
            _batteryText
        ]
    };

    case "CRITICAL": {
        format [
            "%1 CRITICAL",
            _batteryText
        ]
    };

    case "EMPTY": {
        "BAT EMPTY"
    };

    case "UNSERVICEABLE": {
        "BAT UNSERVICEABLE"
    };

    case "NO BATTERY": {
        "NO BAT"
    };

    default {
        _batteryText
    };
};

private _batteryChargeDisplay = if (
    _batteryInstalled isEqualTo 1
) then {
    format [
        "%1%2",
        _batteryChargePercent,
        "%"
    ]
} else {
    "--"
};

private _batteryHealthDisplay = if (
    _batteryInstalled isEqualTo 1
) then {
    format [
        "%1%2",
        _batteryHealthPercent,
        "%"
    ]
} else {
    "--"
};

private _statusColor = switch (
    _batteryStatus
) do {
    case "NO BATTERY";
    case "UNSERVICEABLE";
    case "EMPTY";
    case "CRITICAL": {
        _criticalColor
    };

    case "LOW": {
        _warningColor
    };

    default {
        if (_isPowered) then {
            _unselectedColor
        } else {
            _inactiveColor
        }
    };
};

private _batteryStateColor = switch (
    _batteryStatus
) do {
    case "NO BATTERY";
    case "UNSERVICEABLE";
    case "EMPTY";
    case "CRITICAL": {
        _criticalColor
    };

    case "LOW": {
        _warningColor
    };

    default {
        _selectedColor
    };
};

private _lineAColor = if (
    _selectedLine isEqualTo 0
) then {
    _selectedColor
} else {
    _unselectedColor
};

private _lineBColor = if (
    _selectedLine isEqualTo 1
) then {
    _selectedColor
} else {
    _unselectedColor
};

[
    16302,
    format [
        "RADIO: %1",
        _radioDisplayName
    ],
    _selectedColor
] call _setText;

if (
    !_isPowered &&
    {_page isEqualTo "HOME"}
) exitWith {
    [
        16310,
        ">",
        _inactiveColor
    ] call _setText;

    [
        16311,
        "RADIO",
        _inactiveColor
    ] call _setText;

    [
        16312,
        "OFF",
        _criticalColor
    ] call _setText;

    [
        16317,
        _batteryDisplayText,
        _statusColor
    ] call _setText;

    [
        16320,
        "BAT",
        _inactiveColor
    ] call _setText;

    [
        16321,
        _batteryChargeDisplay,
        _batteryStateColor
    ] call _setText;

    [
        16322,
        "STATE",
        _inactiveColor
    ] call _setText;

    [
        16323,
        _batteryStatus,
        _batteryStateColor
    ] call _setText;

    [
        16330,
        "POWER OFF",
        _criticalColor
    ] call _setText;

    [
        16331,
        "P2 MENU | CLR CLOSE",
        _inactiveColor
    ] call _setText;

    {
        private _control = _display displayCtrl _x;

        if !(isNull _control) then {
            _control ctrlSetTextColor _inactiveColor;
        };
    } forEach [
        16316,
        16326
    ];

    true
};

switch (_page) do {
    case "MENU": {
        private _menuLabels = [
            "R/T SEL",
            "PRESET",
            "VOLUME",
            "AUDIO",
            "DUAL",
            "STATUS",
            "POWER",
            "TX PWR"
        ];

        private _menuSlots = [
            [16310,16311],
            [16312,16313],
            [16314,16315],
            [16320,16321],
            [16322,16323],
            [16324,16325]
        ];

        private _menuStart = (
            (_cursor - 5) max 0
        ) min 2;

        for "_slotIndex" from 0 to 5 do {
            private _itemIndex = _menuStart + _slotIndex;
            private _slot = _menuSlots select _slotIndex;
            private _arrowIDC = _slot select 0;
            private _labelIDC = _slot select 1;
            private _isSelected = (
                _cursor isEqualTo _itemIndex
            );

            private _itemEnabled = if (_isPowered) then {
                true
            } else {
                _itemIndex in [5,6]
            };

            private _itemColor = if (
                !_itemEnabled
            ) then {
                _inactiveColor
            } else {
                if (_isSelected) then {
                    _selectedColor
                } else {
                    _unselectedColor
                }
            };

            [
                _arrowIDC,
                if (_isSelected) then {
                    ">"
                } else {
                    ""
                },
                _itemColor
            ] call _setText;

            [
                _labelIDC,
                _menuLabels select _itemIndex,
                _itemColor
            ] call _setText;
        };

        private _menuDetailBlocked = (
            !_isPowered &&
            {!(_cursor in [5,6])}
        );

        private _menuDetail = if (
            _menuDetailBlocked
        ) then {
            "POWER OFF"
        } else {
            switch (
                _cursor
            ) do {
                case 0: {
                    format [
                        "R/T SELECT: %1",
                        _selectedLineName
                    ]
                };

                case 1: {
                    format [
                        "PRESET: %1 %2",
                        _selectedLineName,
                        _selectedChannelText
                    ]
                };

                case 2: {
                    format [
                        "VOLUME: %1 %2%3",
                        _selectedLineName,
                        _selectedVolume,
                        "%"
                    ]
                };

                case 3: {
                    format [
                        "AUDIO: %1 %2",
                        _selectedLineName,
                        _selectedSpatial
                    ]
                };

                case 4: {
                    format [
                        "DUAL WATCH: %1",
                        if (_dualWatch isEqualTo 1) then {
                            "ON"
                        } else {
                            "OFF"
                        }
                    ]
                };

                case 5: {
                    format [
                        "STATUS: %1 | %2",
                        _powerText,
                        _batteryDisplayText
                    ]
                };

                case 6: {
                    format [
                        "POWER: %1 | %2",
                        _powerText,
                        _batteryDisplayText
                    ]
                };

                case 7: {
                    format [
                        "TX PWR: %1 %2",
                        _selectedLineName,
                        _selectedTxPowerText
                    ]
                };

                default {
                    ""
                };
            }
        };

        private _menuDetailColor = if (
            _menuDetailBlocked
        ) then {
            _inactiveColor
        } else {
            _selectedColor
        };

        [
            16317,
            _menuDetail,
            _menuDetailColor
        ] call _setText;

        [
            16327,
            format [
                "%1 | ITEM %2/8",
                _selectedLineName,
                _cursor + 1
            ],
            _unselectedColor
        ] call _setText;

        [
            16330,
            "MENU",
            _selectedColor
        ] call _setText;

        [
            16331,
            "UP/DOWN | ENT | CLR",
            _unselectedColor
        ] call _setText;
    };

    case "PRESET": {
        private _entryText = switch (
            count _inputBuffer
        ) do {
            case 0: {
                "__"
            };

            case 1: {
                format [
                    "%1_",
                    _inputBuffer
                ]
            };

            default {
                _inputBuffer
            };
        };

        [
            16310,
            ">",
            _selectedColor
        ] call _setText;

        [
            16311,
            _selectedLineName,
            _selectedColor
        ] call _setText;

        [
            16312,
            _selectedChannelText,
            _selectedColor
        ] call _setText;

        [
            16313,
            format [
                "%1 MHz",
                _selectedFrequency
            ],
            _unselectedColor
        ] call _setText;

        [
            16320,
            "ENTRY",
            _unselectedColor
        ] call _setText;

        [
            16321,
            _entryText,
            _selectedColor
        ] call _setText;

        [
            16322,
            "RANGE",
            _unselectedColor
        ] call _setText;

        [
            16323,
            "01-99",
            _unselectedColor
        ] call _setText;

        [
            16327,
            format [
                "%1 CURRENT %2",
                _selectedLineName,
                _selectedChannelText
            ],
            _unselectedColor
        ] call _setText;

        [
            16330,
            "PRESET ENTRY",
            _selectedColor
        ] call _setText;

        [
            16331,
            "DIGITS/ARROWS | ENT | CLR",
            _unselectedColor
        ] call _setText;
    };

    case "VOLUME": {
        private _volumeSteps = round (
            (
                (
                    _selectedVolume max 0
                ) min 100
            ) / 10
        );

        private _volumeBar = "";

        for "_index" from 1 to 10 do {
            _volumeBar = _volumeBar + (
                if (_index <= _volumeSteps) then {
                    "|"
                } else {
                    "."
                }
            );
        };

        [
            16310,
            ">",
            _selectedColor
        ] call _setText;

        [
            16311,
            _selectedLineName,
            _selectedColor
        ] call _setText;

        [
            16312,
            "VOL",
            _selectedColor
        ] call _setText;

        [
            16313,
            format [
                "%1%2",
                _selectedVolume,
                "%"
            ],
            _selectedColor
        ] call _setText;

        [
            16317,
            _volumeBar,
            _selectedColor
        ] call _setText;

        [
            16320,
            "R/T 1",
            _lineAColor
        ] call _setText;

        [
            16321,
            format [
                "%1%2",
                _volumeA,
                "%"
            ],
            _lineAColor
        ] call _setText;

        [
            16322,
            "R/T 2",
            _lineBColor
        ] call _setText;

        [
            16323,
            format [
                "%1%2",
                _volumeB,
                "%"
            ],
            _lineBColor
        ] call _setText;

        [
            16327,
            format [
                "%1 VOLUME %2%3",
                _selectedLineName,
                _selectedVolume,
                "%"
            ],
            _selectedColor
        ] call _setText;

        [
            16330,
            "VOLUME",
            _selectedColor
        ] call _setText;

        [
            16331,
            "LEFT/RIGHT OR UP/DOWN | ENT",
            _unselectedColor
        ] call _setText;
    };

    case "AUDIO": {
        private _setAudioOption = {
            params [
                "_option",
                "_arrowIDC",
                "_labelIDC"
            ];

            private _isSelected = (
                _selectedSpatial isEqualTo _option
            );

            private _optionColor = if (
                _isSelected
            ) then {
                _selectedColor
            } else {
                _unselectedColor
            };

            [
                _arrowIDC,
                if (_isSelected) then {
                    ">"
                } else {
                    ""
                },
                _optionColor
            ] call _setText;

            [
                _labelIDC,
                _option,
                _optionColor
            ] call _setText;
        };

        [
            "LEFT",
            16310,
            16311
        ] call _setAudioOption;

        [
            "BOTH",
            16312,
            16313
        ] call _setAudioOption;

        [
            "RIGHT",
            16314,
            16315
        ] call _setAudioOption;

        [
            16320,
            "R/T 1",
            _lineAColor
        ] call _setText;

        [
            16321,
            _spatialA,
            _lineAColor
        ] call _setText;

        [
            16322,
            "R/T 2",
            _lineBColor
        ] call _setText;

        [
            16323,
            _spatialB,
            _lineBColor
        ] call _setText;

        [
            16327,
            format [
                "%1 AUDIO %2",
                _selectedLineName,
                _selectedSpatial
            ],
            _selectedColor
        ] call _setText;

        [
            16330,
            "AUDIO ROUTING",
            _selectedColor
        ] call _setText;

        [
            16331,
            "LEFT/RIGHT OR UP/DOWN | ENT",
            _unselectedColor
        ] call _setText;
    };

    case "TXPOWER": {
        private _powerLevels = [
            [250,"0.25 W"],
            [500,"0.5 W"],
            [1000,"1 W"],
            [2500,"2.5 W"],
            [5000,"5 W"]
        ];

        private _powerSlots = [
            [16310,16311],
            [16312,16313],
            [16314,16315],
            [16320,16321],
            [16322,16323]
        ];

        for "_powerIndex" from 0 to 4 do {
            private _powerLevel = _powerLevels select _powerIndex;
            private _powerValue = _powerLevel select 0;
            private _powerLabel = _powerLevel select 1;
            private _slot = _powerSlots select _powerIndex;
            private _arrowIDC = _slot select 0;
            private _labelIDC = _slot select 1;
            private _isSelected = (
                _selectedTxPower isEqualTo _powerValue
            );

            private _optionColor = if !(_isPowered) then {
                _inactiveColor
            } else {
                if (_isSelected) then {
                    _selectedColor
                } else {
                    _unselectedColor
                }
            };

            [
                _arrowIDC,
                if (_isSelected) then {
                    ">"
                } else {
                    ""
                },
                _optionColor
            ] call _setText;

            [
                _labelIDC,
                _powerLabel,
                _optionColor
            ] call _setText;
        };

        [
            16317,
            if (_isPowered) then {
                format [
                    "%1 CURRENT %2",
                    _selectedLineName,
                    _selectedTxPowerText
                ]
            } else {
                "POWER OFF"
            },
            if (_isPowered) then {
                _selectedColor
            } else {
                _inactiveColor
            }
        ] call _setText;

        [
            16324,
            "R/T 1",
            _lineAColor
        ] call _setText;

        [
            16325,
            _txPowerAText,
            _lineAColor
        ] call _setText;

        [
            16327,
            format [
                "R/T 2 | %1",
                _txPowerBText
            ],
            _lineBColor
        ] call _setText;

        [
            16330,
            "TX PWR",
            if (_isPowered) then {
                _selectedColor
            } else {
                _inactiveColor
            }
        ] call _setText;

        [
            16331,
            "LEFT/RIGHT OR UP/DOWN | ENT",
            _unselectedColor
        ] call _setText;
    };

    case "STATUS": {
        [
            16310,
            ">",
            _selectedColor
        ] call _setText;

        [
            16311,
            _selectedLineName,
            _selectedColor
        ] call _setText;

        [
            16312,
            "MODE",
            _unselectedColor
        ] call _setText;

        [
            16313,
            _modeText,
            _selectedColor
        ] call _setText;

        [
            16314,
            "PWR",
            _unselectedColor
        ] call _setText;

        [
            16315,
            _powerText,
            if (_isPowered) then {
                _selectedColor
            } else {
                _inactiveColor
            }
        ] call _setText;

        [
            16320,
            "BAT",
            _unselectedColor
        ] call _setText;

        [
            16321,
            _batteryChargeDisplay,
            _batteryStateColor
        ] call _setText;

        [
            16322,
            "HLTH",
            _unselectedColor
        ] call _setText;

        [
            16323,
            _batteryHealthDisplay,
            _batteryStateColor
        ] call _setText;

        [
            16324,
            "STATE",
            _unselectedColor
        ] call _setText;

        [
            16325,
            _batteryStatus,
            _batteryStateColor
        ] call _setText;

        [
            16317,
            if (
                _batterySerial isEqualTo ""
            ) then {
                "SERIAL: --"
            } else {
                format [
                    "SERIAL: %1",
                    _batterySerial
                ]
            },
            _unselectedColor
        ] call _setText;

        [
            16327,
            format [
                "SLOT %1 | DW %2",
                if (_physicalSlot >= 1) then {
                    _physicalSlot
                } else {
                    "-"
                },
                if (_dualWatch isEqualTo 1) then {
                    "ON"
                } else {
                    "OFF"
                }
            ],
            _unselectedColor
        ] call _setText;

        [
            16330,
            "STATUS",
            _selectedColor
        ] call _setText;

        [
            16331,
            "ENT HOME | CLR MENU",
            _unselectedColor
        ] call _setText;
    };

    default {
        private _audioAText = format [
            "%1 | VOL %2%3",
            _spatialA,
            _volumeA,
            "%"
        ];

        private _audioBText = format [
            "%1 | VOL %2%3",
            _spatialB,
            _volumeB,
            "%"
        ];

        private _statusText = format [
            "POWER: %1 | MODE: %2 | %3",
            _powerText,
            _modeText,
            _batteryDisplayText
        ];

        private _selectedAText = if (
            _selectedLine isEqualTo 0
        ) then {
            ">"
        } else {
            ""
        };

        private _selectedBText = if (
            _selectedLine isEqualTo 1
        ) then {
            ">"
        } else {
            ""
        };

        private _receiveAText = if (
            _receivingA isEqualTo 1
        ) then {
            "RX"
        } else {
            "RX --"
        };

        private _receiveBText = if (
            _receivingB isEqualTo 1
        ) then {
            "RX"
        } else {
            "RX --"
        };

        private _transmitAText = if (
            _transmittingA isEqualTo 1
        ) then {
            "TX"
        } else {
            "TX --"
        };

        private _transmitBText = if (
            _transmittingB isEqualTo 1
        ) then {
            "TX"
        } else {
            "TX --"
        };

        private _receiveAColor = if (
            _receivingA isEqualTo 1
        ) then {
            _receiveColor
        } else {
            _inactiveColor
        };

        private _receiveBColor = if (
            _receivingB isEqualTo 1
        ) then {
            _receiveColor
        } else {
            _inactiveColor
        };

        private _transmitAColor = if (
            _transmittingA isEqualTo 1
        ) then {
            _transmitColor
        } else {
            _inactiveColor
        };

        private _transmitBColor = if (
            _transmittingB isEqualTo 1
        ) then {
            _transmitColor
        } else {
            _inactiveColor
        };

        private _dualWatchColor = if (
            _dualWatch isEqualTo 1
        ) then {
            _selectedColor
        } else {
            _unselectedColor
        };

        [
            16310,
            _selectedAText,
            _lineAColor
        ] call _setText;

        [
            16311,
            "R/T 1",
            _lineAColor
        ] call _setText;

        [
            16312,
            _channelAText,
            _lineAColor
        ] call _setText;

        [
            16313,
            format [
                "%1 MHz",
                _frequencyA
            ],
            _lineAColor
        ] call _setText;

        [
            16314,
            _receiveAText,
            _receiveAColor
        ] call _setText;

        [
            16315,
            _transmitAText,
            _transmitAColor
        ] call _setText;

        [
            16317,
            _audioAText,
            _lineAColor
        ] call _setText;

        [
            16320,
            _selectedBText,
            _lineBColor
        ] call _setText;

        [
            16321,
            "R/T 2",
            _lineBColor
        ] call _setText;

        [
            16322,
            _channelBText,
            _lineBColor
        ] call _setText;

        [
            16323,
            format [
                "%1 MHz",
                _frequencyB
            ],
            _lineBColor
        ] call _setText;

        [
            16324,
            _receiveBText,
            _receiveBColor
        ] call _setText;

        [
            16325,
            _transmitBText,
            _transmitBColor
        ] call _setText;

        [
            16327,
            _audioBText,
            _lineBColor
        ] call _setText;

        [
            16330,
            if (_dualWatch isEqualTo 1) then {
                "DUAL WATCH: ON"
            } else {
                "DUAL WATCH: OFF"
            },
            _dualWatchColor
        ] call _setText;

        [
            16331,
            _statusText,
            _statusColor
        ] call _setText;
    };
};

{
    private _control = _display displayCtrl _x;

    if !(isNull _control) then {
        _control ctrlSetTextColor _lineAColor;
    };
} forEach [
    16316
];

{
    private _control = _display displayCtrl _x;

    if !(isNull _control) then {
        _control ctrlSetTextColor _lineBColor;
    };
} forEach [
    16326
];

true
