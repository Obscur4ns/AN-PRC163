params [["_radioId","",[""]]];
if (_radioId isEqualTo "") then {_radioId = [] call UKSF_PRC163_fnc_getTargetRadio};
_radioId = toLower _radioId;
if (_radioId find "acre_prc163_id_" != 0) exitWith {false};

private _pair = [_radioId,player,false] call UKSF_PRC163_fnc_resolvePair;
_pair params [["_radioA","",[""]],["_radioB","",[""]]];
if (_radioA isEqualTo "" || {_radioB isEqualTo ""}) exitWith {false};

private _broadcast = toLower (missionNamespace getVariable ["ACRE_BROADCASTING_RADIOID",""]);
if ((missionNamespace getVariable ["acre_sys_core_pttKeyDown",false]) && {_broadcast in [_radioA,_radioB]}) exitWith {false};

private _enabled = [_radioA,"getState","prc163DualWatch"] call acre_sys_data_fnc_dataEvent;
if !(_enabled in [0,1]) then {
    if !([_radioA] call UKSF_PRC163_fnc_initializeState) exitWith {false};
    _enabled = [_radioA,"getState","prc163DualWatch"] call acre_sys_data_fnc_dataEvent;
};
if !(_enabled in [0,1]) then {_enabled = 1};
private _newEnabled = 1 - _enabled;
{
    [_x,"setState",["prc163DualWatch",_newEnabled]] call acre_sys_data_fnc_dataEvent;
} forEach [_radioA,_radioB];

missionNamespace setVariable ["UKSF_PRC163_activeRadio",_radioA];
private _gui = toLower (uiNamespace getVariable ["UKSF_PRC163_guiRadio",""]);
if (_gui in [_radioA,_radioB]) then {uiNamespace setVariable ["UKSF_PRC163_guiRadio",_radioA]};
if (isNull (findDisplay 16300)) then {
    [format ["<t align='center'>Dual Watch: %1</t>",["OFF","ON"] select _newEnabled],1.5,player,5] call UKSF_PRC163_fnc_notifyStatus;
};
true
