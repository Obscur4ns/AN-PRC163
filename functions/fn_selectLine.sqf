params [
    ["_radioId","",[""]],
    ["_line",0,[0]]
];

_radioId = toLower _radioId;
if (_radioId find "acre_prc163_id_" != 0 || {!(_line in [0,1])}) exitWith {false};

private _pair = [_radioId,player,false] call UKSF_PRC163_fnc_resolvePair;
_pair params [["_radioA","",[""]],["_radioB","",[""]]];
if (_radioA isEqualTo "" || {_radioB isEqualTo ""}) exitWith {false};
private _pairRadios = [_radioA,_radioB];

private _broadcast = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
private _coreDown = missionNamespace getVariable ["acre_sys_core_pttKeyDown",false];
if (_coreDown && {_broadcast in _pairRadios}) exitWith {false};

private _remembered = toLower (missionNamespace getVariable ["UKSF_PRC163_pttRadio",""]);
private _stale = _remembered in _pairRadios;
if (!_stale) then {
    _stale = (_pairRadios findIf {([_x,"getState","prc163PTTDown"] call acre_sys_data_fnc_dataEvent) isEqualTo 1}) >= 0;
};
if (_stale) then {[_radioA,player,true] call UKSF_PRC163_fnc_normalizePairState};

private _available = ([] call acre_api_fnc_getCurrentRadioList) apply {toLower _x};
if !(_radioA in _available) exitWith {false};
if !([_radioA] call acre_api_fnc_setCurrentRadio) exitWith {false};

private _initialized = [_radioA,"getState","prc163Initialized"] call acre_sys_data_fnc_dataEvent;
if !(_initialized isEqualTo true) then {
    if !([_radioA] call UKSF_PRC163_fnc_initializeState) exitWith {false};
};

private _previousLine = [_radioA,"getState","prc163SelectedLine"] call acre_sys_data_fnc_dataEvent;
if !(_previousLine in [0,1]) then {_previousLine = 0};
private _channelA = [_radioA,"getState","prc163ChannelA"] call acre_sys_data_fnc_dataEvent;
private _channelB = [_radioA,"getState","prc163ChannelB"] call acre_sys_data_fnc_dataEvent;
if (!(_channelA isEqualType 0) || {_channelA < 0} || {!(_channelB isEqualType 0)} || {_channelB < 0}) exitWith {false};

[_radioA,"setCurrentChannel",_channelA] call acre_sys_data_fnc_dataEvent;
[_radioB,"setCurrentChannel",_channelB] call acre_sys_data_fnc_dataEvent;
{
    [_x,"setState",["prc163SelectedLine",_line]] call acre_sys_data_fnc_dataEvent;
} forEach _pairRadios;

missionNamespace setVariable ["UKSF_PRC163_activeRadio",_radioA];
private _gui = toLower (uiNamespace getVariable ["UKSF_PRC163_guiRadio",""]);
if (_gui in _pairRadios) then {uiNamespace setVariable ["UKSF_PRC163_guiRadio",_radioA]};

if !(_previousLine isEqualTo _line) then {
    private _displayRadio = _pairRadios select _line;
    private _radioType = [_displayRadio] call acre_sys_radio_fnc_getRadioBaseClassname;
    private _typeName = getText (configFile >> "CfgAcreComponents" >> _radioType >> "name");
    if (_typeName isEqualTo "") then {_typeName = getText (configFile >> "CfgWeapons" >> "ACRE_PRC163" >> "displayName")};
    if (_typeName isEqualTo "") then {_typeName = "AN/PRC-163"};
    private _listInfo = [_displayRadio,"getListInfo"] call acre_sys_data_fnc_dataEvent;
    private _cycleColor = missionNamespace getVariable ["acre_sys_list_CycleRadiosColor",[1,0.8,0,1]];
    ["acre_cycleRadio",format ["%1 R/T %2",_typeName,_line + 1],_listInfo,"",1,_cycleColor] call acre_sys_list_fnc_displayHint;
};
true
