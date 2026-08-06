params [
    ["_radioId","",[""]],
    ["_unit",objNull,[objNull]],
    ["_showNotification",true,[false]]
];
if (isNull _unit) then {_unit = player};
_radioId = toLower _radioId;
if (isNull _unit || {_radioId find "acre_prc163_id_" != 0}) exitWith {false};

private _pair = [_radioId,_unit,false] call UKSF_PRC163_fnc_resolvePair;
_pair params [["_radioA","",[""]],["_radioB","",[""]]];
if (_radioA isEqualTo "" || {_radioB isEqualTo ""}) exitWith {false};
private _pairRadios = [_radioA,_radioB];
private _slot = [_radioA,_unit] call UKSF_PRC163_fnc_getBatterySlot;
if (_slot < 1) exitWith {false};
private _batteryClass = "UKSF_PRC163_Battery";
if !(_batteryClass in items _unit) exitWith {
    if (_showNotification) then {["<t align='center'>AN/PRC-163<br/>NO SPARE BATTERY</t>",1.5,_unit,10] call UKSF_PRC163_fnc_notifyStatus};
    false
};

private _old = [_radioA] call UKSF_PRC163_fnc_getBatteryRecord;
if (count _old < 5) exitWith {false};
private _currentBefore = toLower ([] call acre_api_fnc_getCurrentRadio);
[_radioA,_unit,false] call UKSF_PRC163_fnc_normalizePairState;
[_radioA,"setOnOffState",0] call acre_sys_data_fnc_dataEvent;

private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") then {_uid = profileName};
private _counter = (missionNamespace getVariable ["UKSF_PRC163_batterySerialCounter",0]) + 1;
missionNamespace setVariable ["UKSF_PRC163_batterySerialCounter",_counter];
private _serial = format ["BAT-%1-%2-%3-%4",_uid,_slot,floor (diag_tickTime * 1000),_counter];

private _restoreOld = {
    [_radioA,[_old select 1,_old select 2,_old select 3,_old select 4]] call UKSF_PRC163_fnc_initializeBatteryState;
};

if !([_radioA,[1,_serial,1,1]] call UKSF_PRC163_fnc_initializeBatteryState) exitWith {
    call _restoreOld;
    false
};

private _new = [_radioA] call UKSF_PRC163_fnc_getBatteryRecord;
private _verified = count _new >= 5 && {(_new select 0) isEqualTo _slot} && {(_new select 1) isEqualTo 1} && {(_new select 2) isEqualTo _serial} && {abs ((_new select 3) - 1) < 0.001} && {abs ((_new select 4) - 1) < 0.001};
if (!_verified) exitWith {call _restoreOld; false};

private _before = {_x isEqualTo _batteryClass} count items _unit;
_unit removeItem _batteryClass;
private _after = {_x isEqualTo _batteryClass} count items _unit;
if (_after >= _before) exitWith {call _restoreOld; false};

{
    [_x,"setState",["prc163BatteryShutdownWarned",0]] call acre_sys_data_fnc_dataEvent;
} forEach _pairRadios;
missionNamespace setVariable ["UKSF_PRC163_batteryLocalDirty",true];
if !([true] call UKSF_PRC163_fnc_saveBatteryRecords) exitWith {
    call _restoreOld;
    _unit addItem _batteryClass;
    false
};

missionNamespace setVariable ["UKSF_PRC163_activeRadio",_radioA];
private _gui = toLower (uiNamespace getVariable ["UKSF_PRC163_guiRadio",""]);
if (_gui in _pairRadios) then {uiNamespace setVariable ["UKSF_PRC163_guiRadio",_radioA]};
private _available = ([] call acre_api_fnc_getCurrentRadioList) apply {toLower _x};
private _restoreRadio = _currentBefore;
if (_restoreRadio isEqualTo _radioB) then {_restoreRadio = _radioA};
if !(_restoreRadio in _available) then {_restoreRadio = ""};
if !(_restoreRadio isEqualTo "") then {[_restoreRadio] call acre_api_fnc_setCurrentRadio};
private _display = uiNamespace getVariable ["UKSF_PRC163_display",displayNull];
if !(isNull _display) then {[_display] call UKSF_PRC163_fnc_updateDialog};
if (_showNotification) then {[format ["<t align='center'>AN/PRC-163 %1<br/>BATTERY REPLACED: 100%2</t>",_slot,"%"],1.5,_unit,10] call UKSF_PRC163_fnc_notifyStatus};
true
