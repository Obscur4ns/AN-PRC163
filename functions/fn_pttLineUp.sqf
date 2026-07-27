if !(
    missionNamespace getVariable [
        "UKSF_PRC163_pttHeld",
        false
    ]
) exitWith {
    true
};

[] call acre_sys_core_fnc_handleMultiPttKeyPressUp;

missionNamespace setVariable [
    "UKSF_PRC163_pttHeld",
    false
];

missionNamespace setVariable [
    "UKSF_PRC163_pttLine",
    -1
];

true
