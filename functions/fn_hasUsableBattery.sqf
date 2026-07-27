params [["_radioId","",[""]]];

private _enabled = missionNamespace getVariable [
    "UKSF_PRC163_BatteriesEnabled",
    true
];

if (!_enabled) exitWith {true};

if (_radioId isEqualTo "") then {
    _radioId = [] call UKSF_PRC163_fnc_getTargetRadio;
};

_radioId = toLower _radioId;

if (
    _radioId isEqualTo "" ||
    {_radioId find "acre_prc163_id_" != 0}
) exitWith {false};

private _record = [
    _radioId
] call UKSF_PRC163_fnc_getBatteryRecord;

if ((count _record) != 5) exitWith {false};

private _installed = _record select 1;
private _charge = _record select 3;
private _health = _record select 4;

(
    _installed isEqualTo 1 &&
    {_charge > 0} &&
    {_health > 0}
)