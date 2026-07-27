#include "\a3\ui_f\hpp\defineDIKCodes.inc"

["AN/PRC-163","UKSF_PRC163_SelectLineA",["Select Line A","Select AN/PRC-163 Line A"],{
    private _radio = [] call UKSF_PRC163_fnc_getTargetRadio;
    if (_radio isEqualTo "") exitWith {false};
    if !([_radio] call acre_api_fnc_setCurrentRadio) exitWith {false};
    [_radio,0] call UKSF_PRC163_fnc_selectLine
},{},[DIK_NONE,[false,false,false]]] call CBA_fnc_addKeybind;

["AN/PRC-163","UKSF_PRC163_SelectLineB",["Select Line B","Select AN/PRC-163 Line B"],{
    private _radio = [] call UKSF_PRC163_fnc_getTargetRadio;
    if (_radio isEqualTo "") exitWith {false};
    if !([_radio] call acre_api_fnc_setCurrentRadio) exitWith {false};
    [_radio,1] call UKSF_PRC163_fnc_selectLine
},{},[DIK_NONE,[false,false,false]]] call CBA_fnc_addKeybind;

["AN/PRC-163","UKSF_PRC163_PTTLineA",["PTT Line A","Optional direct PTT for AN/PRC-163 Line A"],{
    [0] call UKSF_PRC163_fnc_pttLineDown
},{
    [] call UKSF_PRC163_fnc_pttLineUp
},[DIK_NONE,[false,false,false]],false,0] call CBA_fnc_addKeybind;

["AN/PRC-163","UKSF_PRC163_PTTLineB",["PTT Line B","Optional direct PTT for AN/PRC-163 Line B"],{
    [1] call UKSF_PRC163_fnc_pttLineDown
},{
    [] call UKSF_PRC163_fnc_pttLineUp
},[DIK_NONE,[false,false,false]],false,0] call CBA_fnc_addKeybind;

["AN/PRC-163","UKSF_PRC163_ToggleDualWatch",["Toggle Dual Watch","Switch between single-line and dual-line monitoring"],{
    [] call UKSF_PRC163_fnc_toggleDualWatch
},{},[DIK_NONE,[false,false,false]]] call CBA_fnc_addKeybind;

true