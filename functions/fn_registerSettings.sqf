missionNamespace setVariable [
    "UKSF_PRC163_SingleInstancePilot",
    true
];
private _category = [
    "UKSF AN/PRC-163",
    "Battery"
];
[
    "UKSF_PRC163_BatteriesEnabled",
    "CHECKBOX",
    [
        "Enable Battery System",
        "Enables battery drain, warning tones, replacement and battery-dependent radio power."
    ],
    _category,
    true,
    1
] call CBA_fnc_addSetting;
[
    "UKSF_PRC163_BatteryLifeHours",
    "SLIDER",
    [
        "Base Battery Life",
        "Approximate operating life in hours while powered on in single-R/T idle operation."
    ],
    _category,
    [1,24,12,1],
    1
] call CBA_fnc_addSetting;
[
    "UKSF_PRC163_BatteryDualWatchExtra",
    "SLIDER",
    [
        "Dual Watch Additional Drain",
        "Additional battery consumption while Dual Watch is enabled."
    ],
    _category,
    [0,1,0.25,0,true],
    1
] call CBA_fnc_addSetting;
[
    "UKSF_PRC163_BatteryReceiveExtra",
    "SLIDER",
    [
        "Receiving Additional Drain",
        "Additional battery consumption for each R/T actively receiving."
    ],
    _category,
    [0,2,0.5,0,true],
    1
] call CBA_fnc_addSetting;
[
    "UKSF_PRC163_BatteryTransmitExtra",
    "SLIDER",
    [
        "Transmitting Additional Drain",
        "Additional battery consumption while transmitting."
    ],
    _category,
    [0,10,5,0,true],
    1
] call CBA_fnc_addSetting;
[
    "UKSF_PRC163_BatteryLowThreshold",
    "SLIDER",
    [
        "Low Battery Threshold",
        "Charge level at which the single low-battery tone is played."
    ],
    _category,
    [0.05,0.25,0.1,0,true],
    1
] call CBA_fnc_addSetting;
[
    "UKSF_PRC163_BatteryCriticalThreshold",
    "SLIDER",
    [
        "Critical Battery Threshold",
        "Charge level at which the three-tone critical warning is played."
    ],
    _category,
    [0.01,0.1,0.05,0,true],
    1
] call CBA_fnc_addSetting;