params [["_radioId","",[""]]];
private _source = toLower _radioId;
private _remembered = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
private _candidate = if (_remembered find "acre_prc163_id_" isEqualTo 0) then {_remembered} else {_source};
if (_candidate find "acre_prc163_id_" != 0) exitWith {false};

private _pair = [_candidate,player,false] call UKSF_PRC163_fnc_resolvePair;
_pair params [["_radioA","",[""]],["_radioB","",[""]]];
private _pairRadios = [_radioA,_radioB] select {_x find "acre_prc163_id_" isEqualTo 0};

private _releaseRadios = [];
{
    private _id = toLower _x;
    if (_id find "acre_prc163_id_" isEqualTo 0 && {!(_id in _releaseRadios)}) then {_releaseRadios pushBack _id};
} forEach [_remembered,_source];

private _released = false;
{
    if ([_x] call acre_sys_prc152_fnc_handlePTTUp) then {_released = true};
} forEach _releaseRadios;

private _stateRadios = +_releaseRadios;
{if !(_x in _stateRadios) then {_stateRadios pushBack _x}} forEach _pairRadios;
{
    [_x,"setState",["prc163PTTDown",0]] call acre_sys_data_fnc_dataEvent;
    [_x,"setState",["prc163TransmittingA",0]] call acre_sys_data_fnc_dataEvent;
    [_x,"setState",["prc163TransmittingB",0]] call acre_sys_data_fnc_dataEvent;
} forEach _stateRadios;

missionNamespace setVariable ["UKSF_PRC163_pttHeld",false];
missionNamespace setVariable ["UKSF_PRC163_pttRadio",nil];
missionNamespace setVariable ["UKSF_PRC163_pttLine",-1];
missionNamespace setVariable ["UKSF_PRC163_pttPrimary",nil];

if (_radioA isNotEqualTo "" && {_radioB isNotEqualTo ""}) then {
    private _channelA = [_radioA,"getState","prc163ChannelA"] call acre_sys_data_fnc_dataEvent;
    private _channelB = [_radioA,"getState","prc163ChannelB"] call acre_sys_data_fnc_dataEvent;
    if (_channelA isEqualType 0 && {_channelA >= 0}) then {[_radioA,"setCurrentChannel",_channelA] call acre_sys_data_fnc_dataEvent};
    if (_channelB isEqualType 0 && {_channelB >= 0}) then {[_radioB,"setCurrentChannel",_channelB] call acre_sys_data_fnc_dataEvent};
    missionNamespace setVariable ["UKSF_PRC163_activeRadio",_radioA];
    private _gui = toLower (uiNamespace getVariable ["UKSF_PRC163_guiRadio",""]);
    if (_gui in _pairRadios) then {uiNamespace setVariable ["UKSF_PRC163_guiRadio",_radioA]};
    private _available = ([] call acre_api_fnc_getCurrentRadioList) apply {toLower _x};
    if (_radioA in _available) then {[_radioA] call acre_api_fnc_setCurrentRadio};
};

private _clearBlocked = {
    params ["_radios"];
    if (isNil "ACRE_BLOCKED_TRANSMITTING_RADIOS") exitWith {};
    private _active = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
    private _clear = _radios select {_x isNotEqualTo _active};
    ACRE_BLOCKED_TRANSMITTING_RADIOS = ACRE_BLOCKED_TRANSMITTING_RADIOS - _clear;
};
[_stateRadios] call _clearBlocked;
[_clearBlocked,[+_stateRadios],0.1] call CBA_fnc_waitAndExecute;
_released || {_releaseRadios isNotEqualTo []}
