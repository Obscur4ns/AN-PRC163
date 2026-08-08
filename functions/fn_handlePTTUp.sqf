params [["_radioId","",[""]]];

private _source = toLower _radioId;
private _remembered = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
private _broadcast = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
private _prefix = "acre_prc163_id_";

private _candidate = if (_remembered find _prefix isEqualTo 0) then {
    _remembered
} else {
    if (_broadcast find _prefix isEqualTo 0) then {_broadcast} else {_source}
};
if (_candidate find _prefix != 0) exitWith {false};

private _pair = [_candidate,player,false] call UKSF_PRC163_fnc_resolvePair;
_pair params [["_radioA","",[""]],["_radioB","",[""]]];
if (
    (_radioA isEqualTo "" || {_radioB isEqualTo ""}) &&
    {_source find _prefix isEqualTo 0} &&
    {_source isNotEqualTo _candidate}
) then {
    _pair = [_source,player,false] call UKSF_PRC163_fnc_resolvePair;
    _pair params [["_radioA","",[""]],["_radioB","",[""]]];
};

private _pairRadios = [_radioA,_radioB] select {_x find _prefix isEqualTo 0};
if (_pairRadios isEqualTo []) exitWith {false};

private _releaseCandidates = [];
{
    private _id = toLower _x;
    if (_id in _pairRadios && {!(_id in _releaseCandidates)}) then {
        _releaseCandidates pushBack _id;
    };
} forEach [_broadcast,_remembered,_source,_radioA,_radioB];

/* Native PRC-152 PTT-up plays ClickOff. Call it only for a genuinely-down endpoint. */
private _releaseRadio = "";
{
    private _nativeDown = [_x,"PTTDown",false] call acre_sys_data_fnc_getScratchData;
    if (_nativeDown isEqualTo true || {_nativeDown isEqualTo 1}) exitWith {
        _releaseRadio = _x;
    };
} forEach _releaseCandidates;

private _released = false;
if (_releaseRadio isNotEqualTo "") then {
    _released = [_releaseRadio] call acre_sys_prc152_fnc_handlePTTUp;
};

/* Any second stale endpoint is repaired silently: one physical release, one click. */
{
    private _nativeDown = [_x,"PTTDown",false] call acre_sys_data_fnc_getScratchData;
    if (_nativeDown isEqualTo true || {_nativeDown isEqualTo 1}) then {
        [_x,"PTTDown",false] call acre_sys_data_fnc_setScratchData;
    };

    [_x,"setState",["prc163PTTDown",0]] call acre_sys_data_fnc_dataEvent;
    [_x,"setState",["prc163TransmittingA",0]] call acre_sys_data_fnc_dataEvent;
    [_x,"setState",["prc163TransmittingB",0]] call acre_sys_data_fnc_dataEvent;
} forEach _pairRadios;

missionNamespace setVariable ["UKSF_PRC163_pttHeld",false];
missionNamespace setVariable ["UKSF_PRC163_pttRadio",nil];
missionNamespace setVariable ["UKSF_PRC163_pttLine",-1];
missionNamespace setVariable ["UKSF_PRC163_pttPrimary",nil];

if (_radioA isNotEqualTo "" && {_radioB isNotEqualTo ""}) then {
    private _channelA = [_radioA,"getState","prc163ChannelA"] call acre_sys_data_fnc_dataEvent;
    private _channelB = [_radioA,"getState","prc163ChannelB"] call acre_sys_data_fnc_dataEvent;

    if (_channelA isEqualType 0 && {_channelA >= 0}) then {
        [_radioA,"setCurrentChannel",_channelA] call acre_sys_data_fnc_dataEvent;
    };
    if (_channelB isEqualType 0 && {_channelB >= 0}) then {
        [_radioB,"setCurrentChannel",_channelB] call acre_sys_data_fnc_dataEvent;
    };

    missionNamespace setVariable ["UKSF_PRC163_activeRadio",_radioA];
    private _gui = toLower (uiNamespace getVariable ["UKSF_PRC163_guiRadio",""]);
    if (_gui in _pairRadios) then {uiNamespace setVariable ["UKSF_PRC163_guiRadio",_radioA]};

    private _available = ([] call acre_api_fnc_getCurrentRadioList) apply {toLower _x};
    if (_radioA in _available) then {[_radioA] call acre_api_fnc_setCurrentRadio};
};

private _clearBlocked = {
    params [["_radios",[],[[]]]];
    if (isNil "ACRE_BLOCKED_TRANSMITTING_RADIOS") exitWith {};

    private _active = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
    private _clear = _radios select {_x isNotEqualTo _active};
    ACRE_BLOCKED_TRANSMITTING_RADIOS = ACRE_BLOCKED_TRANSMITTING_RADIOS - _clear;
};

[+_pairRadios] call _clearBlocked;
[
    {
        params ["_radios"];
        if (missionNamespace getVariable ["acre_sys_core_pttKeyDown",false]) exitWith {};
        if (missionNamespace getVariable ["UKSF_PRC163_pttHeld",false]) exitWith {};
        if (isNil "ACRE_BLOCKED_TRANSMITTING_RADIOS") exitWith {};

        private _active = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
        private _clear = _radios select {_x isNotEqualTo _active};
        ACRE_BLOCKED_TRANSMITTING_RADIOS = ACRE_BLOCKED_TRANSMITTING_RADIOS - _clear;
    },
    [+_pairRadios],
    0.1
] call CBA_fnc_waitAndExecute;

/* ACRE owns ACRE_BROADCASTING_RADIOID and TeamSpeak stop lifecycle. */
_released || {_pairRadios isNotEqualTo []}
