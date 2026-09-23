params [["_radioId","",[""]]];
private _source = toLower _radioId;
if (_source find "acre_prc163_id_" != 0) exitWith {false};

private _pair = [_source,player,false] call UKSF_PRC163_fnc_resolvePair;
_pair params [["_radioA","",[""]],["_radioB","",[""]],["_sourceLine",-1,[0]]];
if (_radioA isEqualTo "" || {_radioB isEqualTo ""} || {!(_sourceLine in [0,1])}) exitWith {false};
private _pairRadios = [_radioA,_radioB];

private _setStateIfChanged = {
    params ["_radio","_name","_desired"];

    private _current = [
        _radio,
        "getState",
        _name
    ] call acre_sys_data_fnc_dataEvent;

    if (
        !isNil "_current" &&
        {_current isEqualTo _desired}
    ) exitWith {false};

    [
        _radio,
        "setState",
        [_name,_desired]
    ] call acre_sys_data_fnc_dataEvent;

    true
};

private _setChannelIfChanged = {
    params ["_radio",["_desired",-1,[0]]];
    if (_desired < 0) exitWith {false};

    private _current = [
        _radio,
        "getCurrentChannel"
    ] call acre_sys_data_fnc_dataEvent;

    if (
        _current isEqualType 0 &&
        {_current isEqualTo _desired}
    ) exitWith {false};

    [
        _radio,
        "setCurrentChannel",
        _desired
    ] call acre_sys_data_fnc_dataEvent;

    true
};

private _activePTT = missionNamespace getVariable ["ACRE_ACTIVE_PTTKEY",-2];
private _logicalLine = _sourceLine;
if (_source isEqualTo _radioA && {_activePTT isEqualTo -1}) then {
    _logicalLine = [_radioA,"getState","prc163SelectedLine"] call acre_sys_data_fnc_dataEvent;
    if !(_logicalLine in [0,1]) then {_logicalLine = 0};
};

private _channelState = ["prc163ChannelA","prc163ChannelB"] select _logicalLine;
private _txChannel = [_radioA,"getState",_channelState] call acre_sys_data_fnc_dataEvent;
if (!(_txChannel isEqualType 0) || {_txChannel < 0}) exitWith {false};

/* ACRE core owns real PTT release. Never call native PTT-up from PTT-down. */
private _previous = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
private _previousConflict = false;
if (_previous in _pairRadios && {_previous isNotEqualTo _source}) then {
    private _previousNativeDown = [_previous,"PTTDown",false] call acre_sys_data_fnc_getScratchData;
    private _previousDown = _previousNativeDown isEqualTo true || {_previousNativeDown isEqualTo 1};
    private _coreDown = missionNamespace getVariable ["acre_sys_core_pttKeyDown",false];

    if (_previousDown && {_coreDown}) then {
        _previousConflict = true;
    } else {
        if (_previousDown) then {
            [_previous,"PTTDown",false] call acre_sys_data_fnc_setScratchData;
        };
    };
};
if (_previousConflict) exitWith {false};

private _restorePowerShadow = {
    params [["_radio","",[""]]];
    if (_radio isEqualTo "") exitWith {};

    private _restore = [_radio,"prc163TxPowerRestore",[]] call acre_sys_data_fnc_getScratchData;
    if !(_restore isEqualType [] && {count _restore >= 2}) exitWith {
        [_radio,"prc163TxPowerRestore",[]] call acre_sys_data_fnc_setScratchData;
    };

    private _restoreChannel = _restore param [0,-1,[0]];
    private _restorePower = _restore param [1,-1,[0]];
    if (_restoreChannel >= 0 && {_restorePower >= 0}) then {
        private _channels = [_radio,"getState","channels"] call acre_sys_data_fnc_dataEvent;
        if (_channels isEqualType [] && {_restoreChannel < count _channels}) then {
            private _channelData = _channels param [_restoreChannel,locationNull];
            if !(isNull _channelData) then {
                _channelData setVariable ["power",_restorePower];
                _channels set [_restoreChannel,_channelData];
                [_radio,"setState",["channels",_channels]] call acre_sys_data_fnc_dataEvent;
            };
        };
    };

    [_radio,"prc163TxPowerRestore",[]] call acre_sys_data_fnc_setScratchData;
};

/* Repair any completed/stale shadow before preparing the next real transmission. */
{
    private _nativeDown = [_x,"PTTDown",false] call acre_sys_data_fnc_getScratchData;
    if !(_nativeDown isEqualTo true || {_nativeDown isEqualTo 1}) then {
        [_x] call _restorePowerShadow;
    };
} forEach _pairRadios;

{
    [_x,"prc163PTTDown",0] call _setStateIfChanged;
    [_x,"prc163TransmittingA",0] call _setStateIfChanged;
    [_x,"prc163TransmittingB",0] call _setStateIfChanged;
} forEach _pairRadios;
missionNamespace setVariable ["UKSF_PRC163_pttHeld",false];
missionNamespace setVariable ["UKSF_PRC163_pttRadio",nil];
missionNamespace setVariable ["UKSF_PRC163_pttLine",-1];
missionNamespace setVariable ["UKSF_PRC163_pttPrimary",nil];

if (_source isEqualTo _radioB && {!isNil "ACRE_BLOCKED_TRANSMITTING_RADIOS"}) then {
    ACRE_BLOCKED_TRANSMITTING_RADIOS = ACRE_BLOCKED_TRANSMITTING_RADIOS - [_radioB];
};

private _channelA = [_radioA,"getState","prc163ChannelA"] call acre_sys_data_fnc_dataEvent;
private _channelB = [_radioA,"getState","prc163ChannelB"] call acre_sys_data_fnc_dataEvent;
if (_channelA isEqualType 0 && {_channelA >= 0}) then {
    [_radioA,_channelA] call _setChannelIfChanged;
};
if (_channelB isEqualType 0 && {_channelB >= 0}) then {
    [_radioB,_channelB] call _setChannelIfChanged;
};

private _logicalEndpoint = _pairRadios select _logicalLine;

/*
    Standard ACRE PTT is physically anchored on RT1. When RT2 is the selected
    logical line, ACRE will therefore ask RT1 for getCurrentChannelData during
    signal calculation. Mirror only RT2's selected-channel TX power onto the
    actual broadcaster for the duration of this key so ACRE's native signal
    model receives the correct milliwatt value.
*/
if (_source isNotEqualTo _logicalEndpoint) then {
    private _logicalData = [_logicalEndpoint,"getChannelData",_txChannel] call acre_sys_data_fnc_dataEvent;
    private _logicalPower = if (isNil "_logicalData") then {-1} else {
        _logicalData getVariable ["power",-1]
    };

    private _sourceChannels = [_source,"getState","channels"] call acre_sys_data_fnc_dataEvent;
    if (
        _logicalPower isEqualType 0 &&
        {_logicalPower >= 0} &&
        {_sourceChannels isEqualType []} &&
        {_txChannel < count _sourceChannels}
    ) then {
        private _sourceChannelData = _sourceChannels param [_txChannel,locationNull];
        if !(isNull _sourceChannelData) then {
            private _sourcePower = _sourceChannelData getVariable ["power",-1];
            if (_sourcePower isEqualType 0 && {_sourcePower >= 0}) then {
                [_source,"prc163TxPowerRestore",[_txChannel,_sourcePower]] call acre_sys_data_fnc_setScratchData;
                _sourceChannelData setVariable ["power",_logicalPower];
                _sourceChannels set [_txChannel,_sourceChannelData];
                [_source,"setState",["channels",_sourceChannels]] call acre_sys_data_fnc_dataEvent;
            };
        };
    };
};

[_source,_txChannel] call _setChannelIfChanged;
private _result = [_source] call acre_sys_prc152_fnc_handlePTTDown;
if (!_result) exitWith {
    [_source] call _restorePowerShadow;
    if (_channelA isEqualType 0 && {_channelA >= 0}) then {[_radioA,_channelA] call _setChannelIfChanged};
    if (_channelB isEqualType 0 && {_channelB >= 0}) then {[_radioB,_channelB] call _setChannelIfChanged};
    false
};

{
    [_x,"prc163PTTDown",1] call _setStateIfChanged;
    [
        _x,
        "prc163TransmittingA",
        if (_logicalLine isEqualTo 0) then {1} else {0}
    ] call _setStateIfChanged;
    [
        _x,
        "prc163TransmittingB",
        if (_logicalLine isEqualTo 1) then {1} else {0}
    ] call _setStateIfChanged;
} forEach _pairRadios;

missionNamespace setVariable ["UKSF_PRC163_pttHeld",true];
missionNamespace setVariable ["UKSF_PRC163_pttRadio",_source];
missionNamespace setVariable ["UKSF_PRC163_pttLine",_logicalLine];
missionNamespace setVariable ["UKSF_PRC163_pttPrimary",_radioA];
missionNamespace setVariable ["UKSF_PRC163_activeRadio",_radioA];
true
