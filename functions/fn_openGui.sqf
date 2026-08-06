params [
    ["_radioId","",[""]]
];

_radioId = toLower _radioId;

private _pair = [
    _radioId,
    player,
    true
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

private _selectedLine = [
    _radioA,
    "getState",
    "prc163SelectedLine"
] call acre_sys_data_fnc_dataEvent;

private _stateReady = true;

if !(_selectedLine in [0,1]) then {
    _stateReady = [
        _radioA
    ] call UKSF_PRC163_fnc_initializeState;

    _selectedLine = [
        _radioA,
        "getState",
        "prc163SelectedLine"
    ] call acre_sys_data_fnc_dataEvent;
};

if (!_stateReady) exitWith {
    false
};

if !(_selectedLine in [0,1]) then {
    _selectedLine = 0;
};

private _targetRadioId = [
    _radioA,
    _radioB
] select _selectedLine;

private _display = uiNamespace getVariable [
    "UKSF_PRC163_display",
    displayNull
];

private _storedGuiValue = uiNamespace getVariable [
    "UKSF_PRC163_guiRadio",
    ""
];

private _storedGuiRadio = if (
    _storedGuiValue isEqualType ""
) then {
    toLower _storedGuiValue
} else {
    ""
};

if (!(isNull _display) && {!(_storedGuiRadio in [_radioA,_radioB])}) then {
    closeDialog 0;
    _display = displayNull;
};

if (
    isNull _display &&
    {!([_targetRadioId] call acre_sys_radio_fnc_canOpenRadio)}
) exitWith {
    false
};

{
    [
        _x,
        "setState",
        [
            "prc163SelectedLine",
            _selectedLine
        ]
    ] call acre_sys_data_fnc_dataEvent;
} forEach [
    _radioA,
    _radioB
];

if !(
    [
        _targetRadioId
    ] call acre_api_fnc_setCurrentRadio
) exitWith {
    false
};

missionNamespace setVariable [
    "UKSF_PRC163_activeRadio",
    _targetRadioId
];

uiNamespace setVariable [
    "UKSF_PRC163_guiRadio",
    _targetRadioId
];

if !(isNull _display) exitWith {
    [
        _display
    ] call UKSF_PRC163_fnc_updateDialog;

    [
        _targetRadioId,
        true
    ] call acre_sys_radio_fnc_setRadioOpenState;

    true
};

if !(createDialog "UKSF_PRC163_RadioDialog") exitWith {
    uiNamespace setVariable [
        "UKSF_PRC163_guiRadio",
        ""
    ];

    false
};

private _newDisplay = findDisplay 16300;

if (isNull _newDisplay) exitWith {
    uiNamespace setVariable [
        "UKSF_PRC163_guiRadio",
        ""
    ];

    false
};

private _initDisplayCurator = uiNamespace getVariable [
    "CBA_events_fnc_initDisplayCurator",
    {}
];

_newDisplay call _initDisplayCurator;

[
    _newDisplay
] call acre_api_fnc_addDisplayPassthroughKeys;

[
    _newDisplay
] call UKSF_PRC163_fnc_updateDialog;

[
    _targetRadioId,
    true
] call acre_sys_radio_fnc_setRadioOpenState;

true
