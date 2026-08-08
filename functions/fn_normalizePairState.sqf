params [
    ["_radioId","",[""]],
    ["_unit",objNull,[objNull]],
    ["_restoreCurrent",true,[true]],
    ["_radioBHint","",[""]]
];

if (isNull _unit) then {_unit = player};
_radioId = toLower _radioId;
_radioBHint = toLower _radioBHint;

private _pair = [_radioId,_unit,false] call UKSF_PRC163_fnc_resolvePair;
_pair params [["_radioA","",[""]],["_radioB","",[""]]];

if (
    (_radioA isEqualTo "" || {_radioB isEqualTo ""}) &&
    {_radioId find "acre_prc163_id_" isEqualTo 0} &&
    {_radioBHint find "acre_prc163_id_" isEqualTo 0} &&
    {_radioId isNotEqualTo _radioBHint}
) then {
    _radioA = _radioId;
    _radioB = _radioBHint;
};
if (_radioA isEqualTo "" || {_radioB isEqualTo ""}) exitWith {false};

private _pairRadios = [_radioA,_radioB];
private _currentBefore = toLower ([] call acre_api_fnc_getCurrentRadio);
private _broadcast = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
private _remembered = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
private _pairOwnsBroadcast = _broadcast in _pairRadios;
private _coreDown = missionNamespace getVariable ["acre_sys_core_pttKeyDown",false];

private _nativeDownRadios = _pairRadios select {
    private _value = [_x,"PTTDown",false] call acre_sys_data_fnc_getScratchData;
    _value isEqualTo true || {_value isEqualTo 1}
};
private _customDown = (_pairRadios findIf {
    ([_x,"getState","prc163PTTDown"] call acre_sys_data_fnc_dataEvent) isEqualTo 1
}) >= 0;
private _customTransmit = (_pairRadios findIf {
    (([_x,"getState","prc163TransmittingA"] call acre_sys_data_fnc_dataEvent) isEqualTo 1) ||
    {([_x,"getState","prc163TransmittingB"] call acre_sys_data_fnc_dataEvent) isEqualTo 1}
}) >= 0;
private _rememberedPair = _remembered in _pairRadios;
private _held = missionNamespace getVariable ["UKSF_PRC163_pttHeld",false];
private _heldForPair = _held && {_rememberedPair || {_pairOwnsBroadcast}};
private _hasPairPTTState = _nativeDownRadios isNotEqualTo [] || {_customDown} || {_customTransmit} || {_rememberedPair} || {_heldForPair};

/* A broadcast ID by itself after key-up is normal ACRE state, not corruption. */
if (!_coreDown && {!_hasPairPTTState}) exitWith {true};

if (_coreDown && {_pairOwnsBroadcast}) then {
    if !(isNil "acre_sys_core_fnc_doHandleMultiPttKeyPressUp") then {
        [[_broadcast,true]] call acre_sys_core_fnc_doHandleMultiPttKeyPressUp;
    } else {
        [_broadcast] call UKSF_PRC163_fnc_handlePTTUp;
        if !(isNil "acre_sys_rpc_fnc_callRemoteProcedure") then {
            ["stopRadioSpeaking",","] call acre_sys_rpc_fnc_callRemoteProcedure;
        };
        missionNamespace setVariable ["acre_sys_core_pttKeyDown",false];
    };
    missionNamespace setVariable ["ACRE_ACTIVE_PTTKEY",-2];
} else {
    /* Core is not transmitting this pair: repair stale endpoint flags silently. */
    {
        [_x,"PTTDown",false] call acre_sys_data_fnc_setScratchData;
    } forEach _nativeDownRadios;
};

{
    private _target = _x;
    {
        [_target,"setState",[_x,0]] call acre_sys_data_fnc_dataEvent;
    } forEach [
        "prc163PTTDown",
        "prc163ReceivingA",
        "prc163ReceivingB",
        "prc163TransmittingA",
        "prc163TransmittingB"
    ];
} forEach _pairRadios;

missionNamespace setVariable ["UKSF_PRC163_pttHeld",false];
missionNamespace setVariable ["UKSF_PRC163_pttRadio",nil];
missionNamespace setVariable ["UKSF_PRC163_pttLine",-1];
missionNamespace setVariable ["UKSF_PRC163_pttPrimary",nil];
missionNamespace setVariable ["UKSF_PRC163_pttRestoreRadio",nil];
missionNamespace setVariable ["UKSF_PRC163_pttRestoreChannel",nil];

if !(isNil "ACRE_BLOCKED_TRANSMITTING_RADIOS") then {
    ACRE_BLOCKED_TRANSMITTING_RADIOS = ACRE_BLOCKED_TRANSMITTING_RADIOS - _pairRadios;
};

private _channelA = [_radioA,"getState","prc163ChannelA"] call acre_sys_data_fnc_dataEvent;
private _channelB = [_radioA,"getState","prc163ChannelB"] call acre_sys_data_fnc_dataEvent;
if (_channelA isEqualType 0 && {_channelA >= 0}) then {[_radioA,"setCurrentChannel",_channelA] call acre_sys_data_fnc_dataEvent};
if (_channelB isEqualType 0 && {_channelB >= 0}) then {[_radioB,"setCurrentChannel",_channelB] call acre_sys_data_fnc_dataEvent};

missionNamespace setVariable ["UKSF_PRC163_activeRadio",_radioA];
private _gui = toLower (uiNamespace getVariable ["UKSF_PRC163_guiRadio",""]);
if (_gui in _pairRadios) then {uiNamespace setVariable ["UKSF_PRC163_guiRadio",_radioA]};

if (_restoreCurrent) then {
    private _available = ([] call acre_api_fnc_getCurrentRadioList) apply {toLower _x};
    private _restoreRadio = _currentBefore;
    if (_restoreRadio isEqualTo _radioB) then {_restoreRadio = _radioA};
    if !(_restoreRadio in _available) then {
        _restoreRadio = if (_currentBefore in _pairRadios && {_radioA in _available}) then {_radioA} else {""};
    };
    if !(_restoreRadio isEqualTo "") then {[_restoreRadio] call acre_api_fnc_setCurrentRadio};
};
true
