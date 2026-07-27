{
    private _presetData = ["ACRE_PRC152",_x] call acre_api_fnc_getPresetData;
    if (!isNil "_presetData") then {["ACRE_PRC163",_x,_presetData] call acre_sys_data_fnc_registerRadioPreset;};
} forEach ["default","default2","default3","default4"];
true