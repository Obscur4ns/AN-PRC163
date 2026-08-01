#include "\a3\ui_f\hpp\defineDIKCodes.inc"

[
    "AN/PRC-163",
    "UKSF_PRC163_SelectLineA",
    [
        "Select R/T 1",
        "Select AN/PRC-163 R/T 1 for standard ACRE PTT."
    ],
    {
        private _radio = [] call UKSF_PRC163_fnc_getTargetRadio;

        if (_radio isEqualTo "") exitWith {
            false
        };

        if !(
            [
                _radio
            ] call acre_api_fnc_setCurrentRadio
        ) exitWith {
            false
        };

        [
            _radio,
            0
        ] call UKSF_PRC163_fnc_selectLine
    },
    {},
    [
        DIK_NONE,
        [
            false,
            false,
            false
        ]
    ]
] call CBA_fnc_addKeybind;

[
    "AN/PRC-163",
    "UKSF_PRC163_SelectLineB",
    [
        "Select R/T 2",
        "Select AN/PRC-163 R/T 2 for standard ACRE PTT."
    ],
    {
        private _radio = [] call UKSF_PRC163_fnc_getTargetRadio;

        if (_radio isEqualTo "") exitWith {
            false
        };

        if !(
            [
                _radio
            ] call acre_api_fnc_setCurrentRadio
        ) exitWith {
            false
        };

        [
            _radio,
            1
        ] call UKSF_PRC163_fnc_selectLine
    },
    {},
    [
        DIK_NONE,
        [
            false,
            false,
            false
        ]
    ]
] call CBA_fnc_addKeybind;

[
    "AN/PRC-163",
    "UKSF_PRC163_ToggleDualWatch",
    [
        "Toggle Dual Watch",
        "Switch the selected AN/PRC-163 between single-R/T and Dual Watch operation."
    ],
    {
        [] call UKSF_PRC163_fnc_toggleDualWatch
    },
    {},
    [
        DIK_NONE,
        [
            false,
            false,
            false
        ]
    ]
] call CBA_fnc_addKeybind;

true
