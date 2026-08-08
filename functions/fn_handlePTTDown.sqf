params [["_radioId","",[""]]];
private _source = toLower _radioId;
if (_source find "acre_prc163_id_" != 0) exitWith {false};

private _pair = [_source,player,false] call UKSF_PRC163_fnc_resolvePair;
_pair params [["_radioA","",[""]],["_radioB","",[""]],["_sourceLine",-1,[0]]];
if (_radioA isEqualTo "" || {_radioB isEqualTo ""} || {!(_sourceLine in [0,1])}) exitWith {false};
private _pairRadios = [_radioA,_radioB];

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

{
    [_x,"setState",["prc163PTTDown",0]] call acre_sys_data_fnc_dataEvent;
    [_x,"setState",["prc163TransmittingA",0]] call acre_sys_data_fnc_dataEvent;
    [_x,"setState",["prc163TransmittingB",0]] call acre_sys_data_fnc_dataEvent;
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
    [_radioA,"setCurrentChannel",_channelA] call acre_sys_data_fnc_dataEvent;
};
if (_channelB isEqualType 0 && {_channelB >= 0}) then {
    [_radioB,"setCurrentChannel",_channelB] call acre_sys_data_fnc_dataEvent;
};

[_source,"setCurrentChannel",_txChannel] call acre_sys_data_fnc_dataEvent;
private _result = [_source] call acre_sys_prc152_fnc_handlePTTDown;
if (!_result) exitWith {
    if (_channelA isEqualType 0 && {_channelA >= 0}) then {[_radioA,"setCurrentChannel",_channelA] call acre_sys_data_fnc_dataEvent};
    if (_channelB isEqualType 0 && {_channelB >= 0}) then {[_radioB,"setCurrentChannel",_channelB] call acre_sys_data_fnc_dataEvent};
    false
};

{
    [_x,"setState",["prc163PTTDown",1]] call acre_sys_data_fnc_dataEvent;
    [_x,"setState",["prc163TransmittingA",if (_logicalLine isEqualTo 0) then {1} else {0}]] call acre_sys_data_fnc_dataEvent;
    [_x,"setState",["prc163TransmittingB",if (_logicalLine isEqualTo 1) then {1} else {0}]] call acre_sys_data_fnc_dataEvent;
} forEach _pairRadios;

missionNamespace setVariable ["UKSF_PRC163_pttHeld",true];
missionNamespace setVariable ["UKSF_PRC163_pttRadio",_source];
missionNamespace setVariable ["UKSF_PRC163_pttLine",_logicalLine];
missionNamespace setVariable ["UKSF_PRC163_pttPrimary",_radioA];
missionNamespace setVariable ["UKSF_PRC163_activeRadio",_radioA];
true
