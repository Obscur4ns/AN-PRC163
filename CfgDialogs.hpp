class RscText;
class RscButton;
class RscPicture;

#define PRC163_UI_SCALE 1.25
#define PRC163_UI_SIZE (PRC163_UI_SCALE * safeZoneH)
#define PRC163_UI_X (0.5 - (PRC163_UI_SIZE / 2))
#define PRC163_UI_Y (0.5 - (PRC163_UI_SIZE / 2))
#define PRC163_X(PX) (PRC163_UI_X + (((PX) / 2048.0) * PRC163_UI_SIZE))
#define PRC163_Y(PY) (PRC163_UI_Y + (((PY) / 2048.0) * PRC163_UI_SIZE))
#define PRC163_W(PW) (((PW) / 2048.0) * PRC163_UI_SIZE)
#define PRC163_H(PH) (((PH) / 2048.0) * PRC163_UI_SIZE)
#define PRC163_IMG_X(PX) (0.5 - ((PRC163_UI_SIZE * (pixelW / pixelH)) / 2) + (((PX) / 2048.0) * PRC163_UI_SIZE * (pixelW / pixelH)))
#define PRC163_IMG_W(PW) (((PW) / 2048.0) * PRC163_UI_SIZE * (pixelW / pixelH))
#define PRC163_LCD_DARK 0.141176471

class UKSF_PRC163_RscPicture: RscPicture {
    type = 0;
    style = 2096;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
};

class UKSF_PRC163_RscCalibrationHotspot: RscButton {
    type = 1;
    style = 2;
    text = "";
    font = "RobotoCondensed";
    sizeEx = 0;
    shadow = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    borderSize = 0.002;
    colorText[] = {0,0,0,0};
    colorTextActive[] = {0,0,0,0};
    colorDisabled[] = {0,0,0,0};
    colorBackground[] = {1,0,0,0.12};
    colorBackgroundActive[] = {1,0,0,0.22};
    colorBackgroundDisabled[] = {0,0,0,0};
    colorFocused[] = {1,0,0,0.16};
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {1,0,0,0.9};
    tooltipColorShade[] = {0.1,0.1,0.1,0.8};
    tooltipColorText[] = {1,1,1,1};
    tooltipColorBox[] = {0,0,0,0};
    soundEnter[] = {"",0.2,1};
    soundPush[] = {"",0.2,1};
    soundClick[] = {"",0.2,1};
    soundEscape[] = {"",0.2,1};
};


class UKSF_PRC163_RscHotspot: RscButton {
    type = 1;
    style = 2;
    text = "";
    font = "RobotoCondensed";
    sizeEx = 0;
    shadow = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    borderSize = 0;
    colorText[] = {0,0,0,0};
    colorTextActive[] = {0,0,0,0};
    colorDisabled[] = {0,0,0,0};
    colorBackground[] = {0,0,0,0};
    colorBackgroundActive[] = {1,1,1,0};
    colorBackgroundDisabled[] = {0,0,0,0};
    colorFocused[] = {0,0,0,0};
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {0,0,0,0};
    tooltipColorShade[] = {0.5,0.5,0.5,0.25};
    tooltipColorText[] = {1,1,1,0.9};
    tooltipColorBox[] = {0.5,0.5,0.5,0};
    soundEnter[] = {"",0.2,1};
    soundPush[] = {"",0.2,1};
    soundClick[] = {"",0.2,1};
    soundEscape[] = {"",0.2,1};
};


class UKSF_PRC163_RscLCDText: RscText {
    type = 0;
    style = 0;
    font = "PixelSplitterBold";
    sizeEx = 0.0135 * safeZoneH;
    shadow = 0;
    colorText[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
    colorBackground[] = {0,0,0,0};
};

class UKSF_PRC163_RscLCDPicture: UKSF_PRC163_RscPicture {
    colorText[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
};

class UKSF_PRC163_RscLCDTextCentre: UKSF_PRC163_RscLCDText {
    style = 2;
};

class UKSF_PRC163_RscLCDProgress {
    type = 8;
    style = 0;
    colorFrame[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
    colorBar[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
    texture = "#(argb,8,8,3)color(1,1,1,1)";
    tooltip = "";
};

class UKSF_PRC163_RscLCDFrame: RscText {
    type = 0;
    style = 64;
    text = "";
    colorText[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
    colorBackground[] = {0,0,0,0};
};

class UKSF_PRC163_RscLCDLine: RscText {
    type = 0;
    style = 0;
    text = "";
    colorText[] = {0,0,0,0};
    colorBackground[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
};

class UKSF_PRC163_RadioDialog {
    idd = 16300;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = "private _display = _this select 0; uiNamespace setVariable ['UKSF_PRC163_display',_display]; uiNamespace setVariable ['UKSF_PRC163_view','FRONT']; private _frontBaseControls = [16303,16304,16343,16344,16345,16346,16347,16350,16351,16352,16353,16354,16355,16356,16357,16358,16359,16360,16370,16391,16392,16399,16417]; private _homeControls = [16394,16395,16410,16411,16412,16418,16419,16420,16421,16422,16423,16424,16425,16426,16427,16428,16429,16430,16431,16432,16433,16434,16435,16436,16437,16438,16439,16440,16441,16442,16443,16444,16445,16446]; private _menuControls = [16450,16451,16452,16453,16454,16455,16456,16457,16458,16459,16460,16461,16462,16463,16464,16465]; private _rtSelectControls = [16570,16571,16572,16573,16574,16575,16576,16577,16578,16579,16580,16581,16582,16583,16584,16585,16586]; private _presetControls = [16470,16471,16472,16473,16474,16475,16476,16477,16478,16479,16480,16481,16482,16483,16484]; private _volumeControls = [16490,16491,16492,16493,16494,16495,16496,16497,16498,16499,16500,16501,16502]; private _audioControls = [16510,16511,16512,16513,16514,16515,16516,16517,16518,16519,16520,16521,16522,16523,16524,16525,16526]; private _statusControls = [16530,16531,16532,16533,16534,16535,16536,16537,16538,16539,16540,16541,16542]; private _txPowerControls = [16550,16551,16552,16553,16554,16555,16556,16557,16558,16559,16560,16561,16562,16563,16564,16565]; private _frontControls = _frontBaseControls + _homeControls + _menuControls + _rtSelectControls + _presetControls + _volumeControls + _audioControls + _statusControls + _txPowerControls; private _sideControls = [16371,16400,16401,16402]; private _lcdControls = []; uiNamespace setVariable ['UKSF_PRC163_frontViewControls',_frontControls]; uiNamespace setVariable ['UKSF_PRC163_frontBaseControls',_frontBaseControls]; uiNamespace setVariable ['UKSF_PRC163_homeLCDControls',_homeControls]; uiNamespace setVariable ['UKSF_PRC163_menuLCDControls',_menuControls]; uiNamespace setVariable ['UKSF_PRC163_rtSelectLCDControls',_rtSelectControls]; uiNamespace setVariable ['UKSF_PRC163_presetLCDControls',_presetControls]; uiNamespace setVariable ['UKSF_PRC163_volumeLCDControls',_volumeControls]; uiNamespace setVariable ['UKSF_PRC163_audioLCDControls',_audioControls]; uiNamespace setVariable ['UKSF_PRC163_statusLCDControls',_statusControls]; uiNamespace setVariable ['UKSF_PRC163_txPowerLCDControls',_txPowerControls]; uiNamespace setVariable ['UKSF_PRC163_sideViewControls',_sideControls]; uiNamespace setVariable ['UKSF_PRC163_lcdControls',_lcdControls]; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow true; _ctrl ctrlEnable true;} forEach _frontBaseControls; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow false; _ctrl ctrlEnable false;} forEach (_homeControls + _menuControls + _rtSelectControls + _presetControls + _volumeControls + _audioControls + _statusControls + _txPowerControls + _sideControls + _lcdControls); {(_display displayCtrl _x) ctrlSetText '';} forEach [16391,16392,16410,16411]; private _updateTopStatus = {params ['_display']; if (isNull _display) exitWith {}; private _radio = uiNamespace getVariable ['UKSF_PRC163_guiRadio','']; if (_radio isEqualTo '') then {_radio = [] call UKSF_PRC163_fnc_getTargetRadio;}; private _powerState = if (_radio isEqualTo '') then {0} else {[_radio] call acre_api_fnc_getRadioOnOffState}; private _isPowered = _powerState isEqualTo 1 || {_powerState isEqualTo true}; private _dualWatch = false; if !(_radio isEqualTo '') then {_dualWatch = [_radio,'getState','prc163DualWatch'] call acre_sys_data_fnc_dataEvent;}; (_display displayCtrl 16391) ctrlSetText (if (_dualWatch isEqualTo true || {_dualWatch isEqualTo 1}) then {'DW:ON'} else {'DW:OFF'}); private _missionSeconds = floor (daytime * 3600); private _hours = floor (_missionSeconds / 3600) mod 24; private _minutes = floor ((_missionSeconds mod 3600) / 60); private _seconds = _missionSeconds mod 60; private _padTime = {params ['_value']; if (_value < 10) then {format ['0%1',_value]} else {str _value};}; (_display displayCtrl 16392) ctrlSetText format ['%1:%2:%3',[_hours] call _padTime,[_minutes] call _padTime,[_seconds] call _padTime]; private _selectedLine = 0; if !(_radio isEqualTo '') then {_selectedLine = [_radio,'getState','prc163SelectedLine'] call acre_sys_data_fnc_dataEvent;}; if !(_selectedLine in [0,1]) then {_selectedLine = 0;}; private _frontView = (uiNamespace getVariable ['UKSF_PRC163_view','FRONT']) isEqualTo 'FRONT'; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow (_frontView && {_isPowered}); _ctrl ctrlEnable false;} forEach [16391,16392,16417]; private _hmiState = if (_radio isEqualTo '') then {createHashMap} else {[_radio] call UKSF_PRC163_fnc_getHMIState}; private _page = toUpper (_hmiState getOrDefault ['page','HOME']); private _cursor = _hmiState getOrDefault ['cursor',0]; if !(_cursor isEqualType 0) then {_cursor = 0;}; _cursor = floor ((_cursor max 0) min 7); private _inputBuffer = _hmiState getOrDefault ['inputBuffer','']; if !(_inputBuffer isEqualType '') then {_inputBuffer = '';}; private _homeView = _frontView && {_isPowered} && {_page isEqualTo 'HOME'}; private _menuView = _frontView && {_isPowered} && {_page isEqualTo 'MENU'}; private _rtSelectView = _frontView && {_isPowered} && {_page isEqualTo 'RTSELECT'}; private _presetView = _frontView && {_isPowered} && {_page isEqualTo 'PRESET'}; private _volumeView = _frontView && {_isPowered} && {_page isEqualTo 'VOLUME'}; private _audioView = _frontView && {_isPowered} && {_page isEqualTo 'AUDIO'}; private _statusView = _frontView && {_isPowered} && {_page isEqualTo 'STATUS'}; private _txPowerView = _frontView && {_isPowered} && {_page isEqualTo 'TXPOWER'}; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _homeView; _ctrl ctrlEnable _homeView;} forEach (uiNamespace getVariable ['UKSF_PRC163_homeLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _menuView; _ctrl ctrlEnable _menuView;} forEach (uiNamespace getVariable ['UKSF_PRC163_menuLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _rtSelectView; _ctrl ctrlEnable _rtSelectView;} forEach (uiNamespace getVariable ['UKSF_PRC163_rtSelectLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _presetView; _ctrl ctrlEnable _presetView;} forEach (uiNamespace getVariable ['UKSF_PRC163_presetLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _volumeView; _ctrl ctrlEnable _volumeView;} forEach (uiNamespace getVariable ['UKSF_PRC163_volumeLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _audioView; _ctrl ctrlEnable _audioView;} forEach (uiNamespace getVariable ['UKSF_PRC163_audioLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _statusView; _ctrl ctrlEnable _statusView;} forEach (uiNamespace getVariable ['UKSF_PRC163_statusLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _txPowerView; _ctrl ctrlEnable _txPowerView;} forEach (uiNamespace getVariable ['UKSF_PRC163_txPowerLCDControls',[]]); if (_menuView) then {private _items = ['R/T SELECT','PRESET','VOLUME','AUDIO','DUAL WATCH','STATUS','POWER OFF','TX POWER']; private _visible = 5; private _maxStart = ((count _items) - _visible) max 0; private _start = ((_cursor - 2) max 0) min _maxStart; private _rowIds = [16456,16457,16458,16459,16460]; {private _row = _display displayCtrl _x; private _itemIndex = _start + _forEachIndex; private _valid = _itemIndex < count _items; private _selected = _valid && {_itemIndex isEqualTo _cursor}; private _itemText = if (_valid) then {_items select _itemIndex} else {''}; private _marker = if (_selected) then {'>'} else {' '}; _row ctrlSetText (if (_valid) then {format ['%1 %2',_marker,_itemText]} else {''}); _row ctrlSetBackgroundColor (if (_selected) then {[0.141176471,0.141176471,0.141176471,0.96]} else {[0,0,0,0]}); _row ctrlSetTextColor (if (_selected) then {[0.31372549,0.321568627,0.258823529,1]} else {[0.141176471,0.141176471,0.141176471,0.96]}); _row ctrlCommit 0;} forEach _rowIds; (_display displayCtrl 16463) ctrlSetText format ['%1/%2',_cursor + 1,count _items]; private _trackPos = ctrlPosition (_display displayCtrl 16461); private _thumb = _display displayCtrl 16462; private _thumbPos = ctrlPosition _thumb; private _trackY = _trackPos select 1; private _trackH = _trackPos select 3; private _thumbH = _trackH * (_visible / count _items); private _thumbY = _trackY; if (_maxStart > 0) then {_thumbY = _trackY + ((_trackH - _thumbH) * (_start / _maxStart));}; _thumb ctrlSetPosition [_thumbPos select 0,_thumbY,_thumbPos select 2,_thumbH]; _thumb ctrlCommit 0;}; if (_rtSelectView) then {private _rtRadioA = _hmiState getOrDefault ['radioA',_radio]; private _rtRadioB = _hmiState getOrDefault ['radioB','']; private _rtRadios = [_rtRadioA,_rtRadioB]; private _rtChannelStates = ['prc163ChannelA','prc163ChannelB']; private _rtHeaderIDs = [16577,16580]; private _rtNameIDs = [16578,16581]; for '_rtLine' from 0 to 1 do {private _rtChannel = 0; if !(_radio isEqualTo '') then {_rtChannel = [_radio,'getState',_rtChannelStates select _rtLine] call acre_sys_data_fnc_dataEvent;}; if !(_rtChannel isEqualType 0) then {_rtChannel = 0;}; _rtChannel = (floor _rtChannel max 0) min 98; private _rtPreset = _rtChannel + 1; private _rtPresetText = if (_rtPreset < 10) then {format ['0%1',_rtPreset]} else {str _rtPreset}; private _rtEndpoint = _rtRadios select _rtLine; if (_rtEndpoint isEqualTo '') then {_rtEndpoint = _rtRadioA;}; private _rtName = ''; if !(_rtEndpoint isEqualTo '') then {private _rtData = [_rtEndpoint,'getChannelData',_rtChannel] call acre_sys_data_fnc_dataEvent; if !(isNil '_rtData') then {_rtName = _rtData getVariable ['description','']; if !(_rtName isEqualType '') then {_rtName = '';};};}; if (_rtName isEqualTo '') then {_rtName = format ['PRESET P%1',_rtPresetText];}; (_display displayCtrl (_rtHeaderIDs select _rtLine)) ctrlSetText format ['R/T %1                         P%2',_rtLine + 1,_rtPresetText]; (_display displayCtrl (_rtNameIDs select _rtLine)) ctrlSetText (toUpper _rtName);}; (_display displayCtrl 16576) ctrlSetText format ['R/T %1 SELECTED',_selectedLine + 1]; {private _selected = _forEachIndex isEqualTo _selectedLine; {private _ctrl = _display displayCtrl _x; _ctrl ctrlSetBackgroundColor (if (_selected) then {[0.141176471,0.141176471,0.141176471,0.96]} else {[0,0,0,0]}); _ctrl ctrlSetTextColor (if (_selected) then {[0.31372549,0.321568627,0.258823529,1]} else {[0.141176471,0.141176471,0.141176471,0.96]}); _ctrl ctrlCommit 0;} forEach _x;} forEach [[16577,16578],[16580,16581]];}; (_display displayCtrl 16421) ctrlShow (_homeView && {_selectedLine isEqualTo 1}); (_display displayCtrl 16422) ctrlShow (_homeView && {_selectedLine isEqualTo 0}); private _spatialStateName = ['prc163SpatialA','prc163SpatialB'] select _selectedLine; private _spatial = 0; if !(_radio isEqualTo '') then {_spatial = [_radio,'getState',_spatialStateName] call acre_sys_data_fnc_dataEvent;}; if !(_spatial in [-1,0,1]) then {_spatial = 0;}; private _earText = switch (_spatial) do {case -1: {'L'}; case 1: {'R'}; default {'B'};}; (_display displayCtrl 16410) ctrlSetText _earText; private _audioText = switch (_spatial) do {case -1: {'LEFT'}; case 1: {'RIGHT'}; default {'BOTH'};}; (_display displayCtrl 16516) ctrlSetText format ['R/T %1 SELECTED',_selectedLine + 1]; (_display displayCtrl 16518) ctrlSetText _audioText; private _audioSelectedIndex = _spatial + 1; {private _ctrl = _display displayCtrl _x; private _selected = _forEachIndex isEqualTo _audioSelectedIndex; _ctrl ctrlSetBackgroundColor (if (_selected) then {[0.141176471,0.141176471,0.141176471,0.96]} else {[0,0,0,0]}); _ctrl ctrlSetTextColor (if (_selected) then {[0.31372549,0.321568627,0.258823529,1]} else {[0.141176471,0.141176471,0.141176471,0.96]}); _ctrl ctrlCommit 0;} forEach [16519,16520,16521]; private _txPowerRadio = _hmiState getOrDefault ['radioA',_radio]; private _txPowerValue = 5000; if !(_txPowerRadio isEqualTo '') then {_txPowerValue = [_txPowerRadio,_selectedLine] call UKSF_PRC163_fnc_getTxPower;}; private _txPowerValues = [250,500,1000,2500,5000]; private _txPowerLabels = ['0.25 W','0.5 W','1 W','2.5 W','5 W']; private _txPowerIndex = _txPowerValues find _txPowerValue; if (_txPowerIndex < 0) then {_txPowerIndex = 4; _txPowerValue = 5000;}; (_display displayCtrl 16556) ctrlSetText format ['R/T %1 SELECTED',_selectedLine + 1]; (_display displayCtrl 16558) ctrlSetText (_txPowerLabels select _txPowerIndex); {private _ctrl = _display displayCtrl _x; private _selected = _forEachIndex isEqualTo _txPowerIndex; _ctrl ctrlSetBackgroundColor (if (_selected) then {[0.141176471,0.141176471,0.141176471,0.96]} else {[0,0,0,0]}); _ctrl ctrlSetTextColor (if (_selected) then {[0.31372549,0.321568627,0.258823529,1]} else {[0.141176471,0.141176471,0.141176471,0.96]}); _ctrl ctrlCommit 0;} forEach [16559,16560,16561,16562,16563]; if (_statusView) then {private _displayState = [_radio] call UKSF_PRC163_fnc_getDisplayState; private _batteryPercent = _displayState getOrDefault ['batteryChargePercent',0]; if !(_batteryPercent isEqualType 0) then {_batteryPercent = 0;}; _batteryPercent = round ((_batteryPercent max 0) min 100); private _batteryState = _displayState getOrDefault ['batteryStatus','---']; if !(_batteryState isEqualType '') then {_batteryState = '---';}; _batteryState = toUpper _batteryState; private _statusChannelStateName = ['prc163ChannelA','prc163ChannelB'] select _selectedLine; private _statusChannel = 0; if !(_radio isEqualTo '') then {_statusChannel = [_radio,'getState',_statusChannelStateName] call acre_sys_data_fnc_dataEvent;}; if !(_statusChannel isEqualType 0) then {_statusChannel = 0;}; _statusChannel = (floor _statusChannel max 0) min 98; private _statusPreset = _statusChannel + 1; private _statusPresetText = if (_statusPreset < 10) then {format ['0%1',_statusPreset]} else {str _statusPreset}; private _statusRadioA = _hmiState getOrDefault ['radioA',_radio]; private _statusRadioB = _hmiState getOrDefault ['radioB','']; private _statusEndpoint = [_statusRadioA,_statusRadioB] select _selectedLine; if (_statusEndpoint isEqualTo '') then {_statusEndpoint = _statusRadioA;}; private _statusChannelName = ''; private _statusFrequencyText = '---.--- MHz'; if !(_statusEndpoint isEqualTo '') then {private _statusChannelData = [_statusEndpoint,'getChannelData',_statusChannel] call acre_sys_data_fnc_dataEvent; if !(isNil '_statusChannelData') then {_statusChannelName = _statusChannelData getVariable ['description','']; if !(_statusChannelName isEqualType '') then {_statusChannelName = '';}; private _statusFrequency = _statusChannelData getVariable ['frequency',0]; if (_statusFrequency isEqualType 0 && {_statusFrequency > 0}) then {_statusFrequencyText = format ['%1 MHz',_statusFrequency toFixed 3];};};}; if (_statusChannelName isEqualTo '') then {_statusChannelName = format ['PRESET P%1',_statusPresetText];}; private _statusDualWatchText = if (_dualWatch isEqualTo true || {_dualWatch isEqualTo 1}) then {'ON'} else {'OFF'}; private _statusTxPowerText = _txPowerLabels select _txPowerIndex; (_display displayCtrl 16536) ctrlSetText format ['R/T %1 SELECTED      P%2',_selectedLine + 1,_statusPresetText]; (_display displayCtrl 16537) ctrlSetText format ['CHANNEL  %1',toUpper _statusChannelName]; (_display displayCtrl 16538) ctrlSetText format ['FREQ     %1',_statusFrequencyText]; (_display displayCtrl 16539) ctrlSetText format ['TX POWER %1',_statusTxPowerText]; (_display displayCtrl 16540) ctrlSetText format ['DUAL WATCH      %1',_statusDualWatchText]; (_display displayCtrl 16541) ctrlSetText format ['BATTERY  %1%% %2',_batteryPercent,_batteryState]; private _selectedStatusCtrl = _display displayCtrl 16536; _selectedStatusCtrl ctrlSetBackgroundColor [0.141176471,0.141176471,0.141176471,0.96]; _selectedStatusCtrl ctrlSetTextColor [0.31372549,0.321568627,0.258823529,1]; _selectedStatusCtrl ctrlCommit 0;}; private _volumeStateName = ['prc163VolumeA','prc163VolumeB'] select _selectedLine; private _volume = 1; if !(_radio isEqualTo '') then {_volume = [_radio,'getState',_volumeStateName] call acre_sys_data_fnc_dataEvent;}; if !(_volume isEqualType 0) then {_volume = 1;}; _volume = (_volume max 0) min 1; (_display displayCtrl 16427) progressSetPosition _volume; (_display displayCtrl 16496) ctrlSetText format ['R/T %1 SELECTED',_selectedLine + 1]; (_display displayCtrl 16498) ctrlSetText format ['%1%%',round (_volume * 100)]; (_display displayCtrl 16499) progressSetPosition _volume; private _channelStateName = ['prc163ChannelA','prc163ChannelB'] select _selectedLine; private _selectedChannel = 0; if !(_radio isEqualTo '') then {_selectedChannel = [_radio,'getState',_channelStateName] call acre_sys_data_fnc_dataEvent;}; if !(_selectedChannel isEqualType 0) then {_selectedChannel = 0;}; _selectedChannel = (floor _selectedChannel max 0) min 98; private _selectedPreset = _selectedChannel + 1; private _presetText = if (_selectedPreset < 10) then {format ['0%1',_selectedPreset]} else {str _selectedPreset}; private _selectedEndpoint = [] call UKSF_PRC163_fnc_getTargetRadio; private _channelDescription = ''; private _typeText = '---'; private _trafficText = '---'; private _modeText = '---'; private _channelText = '---'; private _keyText = '---'; private _frequencyText = '---.--- MHz'; if !(_selectedEndpoint isEqualTo '') then {private _channelData = [_selectedEndpoint,'getChannelData',_selectedChannel] call acre_sys_data_fnc_dataEvent; if !(isNil '_channelData') then {_channelDescription = _channelData getVariable ['description','']; private _frequency = _channelData getVariable ['frequency',0]; if (_frequency isEqualType 0 && {_frequency > 0}) then {_frequencyText = format ['%1 MHz',_frequency toFixed 3];}; private _channelMode = _channelData getVariable ['channelMode','']; if !(_channelMode isEqualType '') then {_channelMode = '';}; _channelMode = toUpper _channelMode; _typeText = if (_channelMode in ['BASIC','LOS']) then {'LOS'} else {'---'}; _trafficText = 'VOC'; private _modulation = _channelData getVariable ['modulation','']; if !(_modulation isEqualType '') then {_modulation = '';}; _modulation = toUpper _modulation; _modeText = if (_modulation isEqualTo '') then {'---'} else {_modulation}; _channelText = format ['P%1',_presetText]; private _encryption = _channelData getVariable ['encryption',0]; private _encrypted = (_encryption isEqualTo true) || {(_encryption isEqualType 0) && {_encryption > 0}}; if (_encrypted) then {private _tek = _channelData getVariable ['TEK',0]; if (_tek isEqualType 0) then {_tek = floor (_tek max 0); private _tekText = if (_tek < 10) then {format ['0%1',_tek]} else {str _tek}; _keyText = format ['K%1',_tekText];} else {if (_tek isEqualType '') then {_keyText = toUpper _tek; if (_keyText isEqualTo '') then {_keyText = 'KEY';};} else {_keyText = 'KEY';};};};};}; if (!(_channelDescription isEqualType '') || {_channelDescription isEqualTo ''}) then {_channelDescription = format ['FMLOSVOC%1',_presetText];}; (_display displayCtrl 16411) ctrlSetText _channelDescription; (_display displayCtrl 16412) ctrlSetText _typeText; (_display displayCtrl 16433) ctrlSetText _trafficText; (_display displayCtrl 16434) ctrlSetText _modeText; (_display displayCtrl 16435) ctrlSetText _channelText; (_display displayCtrl 16436) ctrlSetText _keyText; (_display displayCtrl 16476) ctrlSetText format ['R/T %1 SELECTED',_selectedLine + 1]; (_display displayCtrl 16477) ctrlSetText format ['P%1',_presetText]; (_display displayCtrl 16478) ctrlSetText _channelDescription; (_display displayCtrl 16479) ctrlSetText _frequencyText; private _entryText = switch (count _inputBuffer) do {case 1: {format ['P%1_',_inputBuffer]}; case 2: {format ['P%1',_inputBuffer]}; default {'P__'};}; (_display displayCtrl 16481) ctrlSetText _entryText; private _receivingSignal = 0; if !(_selectedEndpoint isEqualTo '') then {_receivingSignal = [_selectedEndpoint,'receivingSignal',0] call acre_sys_data_fnc_getScratchData;}; if !(_receivingSignal isEqualType 0) then {_receivingSignal = 0;}; _receivingSignal = (_receivingSignal max 0) min 1; (_display displayCtrl 16432) progressSetPosition _receivingSignal; private _batteryInstalled = 0; private _batteryCharge = 0; if !(_radio isEqualTo '') then {private _batteryRecord = [_radio,player] call UKSF_PRC163_fnc_getBatteryRecord; if ((count _batteryRecord) isEqualTo 5) then {_batteryInstalled = _batteryRecord param [1,0,[0]]; _batteryCharge = _batteryRecord param [3,0,[0]];};}; if (_batteryInstalled isEqualTo 0) then {_batteryCharge = 0;}; _batteryCharge = (_batteryCharge max 0) min 1; private _batteryBar = _display displayCtrl 16417; _batteryBar progressSetPosition _batteryCharge; _batteryBar ctrlShow (_frontView && {_isPowered});}; [_display] call _updateTopStatus; private _topStatusPFH = [{params ['_args','_handle']; private _display = _args param [0,displayNull,[displayNull]]; if (isNull _display) exitWith {[_handle] call CBA_fnc_removePerFrameHandler; uiNamespace setVariable ['UKSF_PRC163_topStatusPFH',-1];}; [_display] call (_args select 1);},0.25,[_display,_updateTopStatus]] call CBA_fnc_addPerFrameHandler; uiNamespace setVariable ['UKSF_PRC163_topStatusPFH',_topStatusPFH]; [_display] call acre_api_fnc_addDisplayPassthroughKeys;";

    onUnload = "private _topStatusPFH = uiNamespace getVariable ['UKSF_PRC163_topStatusPFH',-1]; if (_topStatusPFH >= 0) then {[_topStatusPFH] call CBA_fnc_removePerFrameHandler;}; uiNamespace setVariable ['UKSF_PRC163_topStatusPFH',-1]; private _radio = uiNamespace getVariable ['UKSF_PRC163_guiRadio','']; uiNamespace setVariable ['UKSF_PRC163_display',displayNull]; if !(_radio isEqualTo '') then {[_radio,'closeGui'] call acre_sys_data_fnc_interactEvent;};";

    class controlsBackground {
        class RadioPicture: UKSF_PRC163_RscPicture {
            idc = 16370;
            text = "\UKSF_PRC163\data\ui\prc163_ui.paa";
            x = PRC163_UI_X;
            y = PRC163_UI_Y;
            w = PRC163_UI_SIZE;
            h = PRC163_UI_SIZE;
        };

        class SideRadioPicture: UKSF_PRC163_RscPicture {
            idc = 16371;
            text = "\UKSF_PRC163\data\ui\prc163_side_ui.paa";
            x = PRC163_UI_X;
            y = PRC163_UI_Y;
            w = PRC163_UI_SIZE;
            h = PRC163_UI_SIZE;
        };
    };

    class controls {
        class VolumeKnob: UKSF_PRC163_RscHotspot {
            idc = 16303;
            x = PRC163_X(845);
            y = PRC163_Y(326);
            w = PRC163_W(100);
            h = PRC163_H(138);
            onMouseButtonUp = "private _direction = if ((_this select 1) isEqualTo 1) then {-1} else {1}; private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; if !(_radio isEqualTo '') then {private _line = [_radio,'getState','prc163SelectedLine'] call acre_sys_data_fnc_dataEvent; if !(_line in [0,1]) then {_line = 0;}; private _stateName = ['prc163VolumeA','prc163VolumeB'] select _line; private _value = [_radio,'getState',_stateName] call acre_sys_data_fnc_dataEvent; if !(_value isEqualType 0) then {_value = 0.8;}; _value = ((_value + (0.1 * _direction)) max 0) min 1; [_radio,'setVolume',_value] call acre_sys_data_fnc_dataEvent;};";
            tooltip = "Volume: left-click increase, right-click decrease";
        };

        class ChannelKnob: UKSF_PRC163_RscHotspot {
            idc = 16304;
            x = PRC163_X(1132);
            y = PRC163_Y(326);
            w = PRC163_W(105);
            h = PRC163_H(138);
            onMouseButtonUp = "private _direction = if ((_this select 1) isEqualTo 1) then {-1} else {1}; private _radio = uiNamespace getVariable ['UKSF_PRC163_guiRadio','']; if (_radio isEqualTo '') then {_radio = [] call UKSF_PRC163_fnc_getTargetRadio;}; if !(_radio isEqualTo '') then {private _hmiState = [_radio] call UKSF_PRC163_fnc_getHMIState; private _radioA = _hmiState getOrDefault ['radioA',_radio]; private _radioB = _hmiState getOrDefault ['radioB','']; private _resetHMI = {{if !(_x isEqualTo '') then {[_x,'setState',['prc163HMIPage','HOME']] call acre_sys_data_fnc_dataEvent; [_x,'setState',['prc163HMICursor',0]] call acre_sys_data_fnc_dataEvent; [_x,'setState',['prc163HMIInputBuffer','']] call acre_sys_data_fnc_dataEvent; [_x,'setState',['prc163HMIEditing',0]] call acre_sys_data_fnc_dataEvent;};} forEach [_radioA,_radioB];}; private _powerState = [_radioA] call acre_api_fnc_getRadioOnOffState; private _powered = _powerState isEqualTo 1 || {_powerState isEqualTo true}; if (!_powered) then {if (_direction > 0) then {call _resetHMI; [_radioA,'setOnOffState',1] call acre_sys_data_fnc_dataEvent;};} else {private _selectedLine = _hmiState getOrDefault ['selectedLine',0]; if !(_selectedLine in [0,1]) then {_selectedLine = 0;}; private _channelStateName = ['prc163ChannelA','prc163ChannelB'] select _selectedLine; private _channel = [_radioA,'getState',_channelStateName] call acre_sys_data_fnc_dataEvent; if !(_channel isEqualType 0) then {_channel = 0;}; if (_direction < 0 && {_channel <= 0}) then {call _resetHMI; [_radioA,'setOnOffState',0] call acre_sys_data_fnc_dataEvent;} else {[_direction] call UKSF_PRC163_fnc_cycleChannel;};};};";
            tooltip = "Channel/power: left-click forward or ON, right-click backward or OFF at P01";
        };

        class Key1: UKSF_PRC163_RscHotspot {
            idc = 16351;
            x = PRC163_IMG_X(887);
            y = PRC163_Y(1079);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['1'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "1";
        };

        class Key2: UKSF_PRC163_RscHotspot {
            idc = 16352;
            x = PRC163_IMG_X(958);
            y = PRC163_Y(1079);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['2'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "2";
        };

        class Key3: UKSF_PRC163_RscHotspot {
            idc = 16353;
            x = PRC163_IMG_X(1031);
            y = PRC163_Y(1079);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['3'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "3";
        };

        class ClearKey: UKSF_PRC163_RscHotspot {
            idc = 16360;
            x = PRC163_IMG_X(1101);
            y = PRC163_Y(1080);
            w = PRC163_IMG_W(58);
            h = PRC163_H(48);
            onMouseButtonUp = "['CLR'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "CLR";
        };

        class Key4: UKSF_PRC163_RscHotspot {
            idc = 16354;
            x = PRC163_IMG_X(887);
            y = PRC163_Y(1144);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['4'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "4";
        };

        class Key5: UKSF_PRC163_RscHotspot {
            idc = 16355;
            x = PRC163_IMG_X(958);
            y = PRC163_Y(1144);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['5'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "5";
        };

        class Key6: UKSF_PRC163_RscHotspot {
            idc = 16356;
            x = PRC163_IMG_X(1031);
            y = PRC163_Y(1144);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; private _state = if (_radio isEqualTo '') then {createHashMap} else {[_radio] call UKSF_PRC163_fnc_getHMIState}; private _page = _state getOrDefault ['page','HOME']; private _input = switch (_page) do {case 'PRESET': {'6'}; case 'TXPOWER': {'RIGHT'}; default {'UP'};}; [_input] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "6 / Up";
        };

        class EnterKey: UKSF_PRC163_RscHotspot {
            idc = 16345;
            x = PRC163_IMG_X(1101);
            y = PRC163_Y(1145);
            w = PRC163_IMG_W(58);
            h = PRC163_H(48);
            onMouseButtonUp = "private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; private _state = if (_radio isEqualTo '') then {createHashMap} else {[_radio] call UKSF_PRC163_fnc_getHMIState}; if !((_state getOrDefault ['page','HOME']) isEqualTo 'HOME') then {['ENT'] call UKSF_PRC163_fnc_handleHMIInput;};";
            tooltip = "ENT";
        };

        class Key7: UKSF_PRC163_RscHotspot {
            idc = 16357;
            x = PRC163_IMG_X(887);
            y = PRC163_Y(1209);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['7'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "7 / OPT";
        };

        class Key8: UKSF_PRC163_RscHotspot {
            idc = 16358;
            x = PRC163_IMG_X(958);
            y = PRC163_Y(1209);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; private _state = if (_radio isEqualTo '') then {createHashMap} else {[_radio] call UKSF_PRC163_fnc_getHMIState}; private _page = _state getOrDefault ['page','HOME']; private _input = if (_page isEqualTo 'PRESET') then {'8'} else {'MENU'}; [_input] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "8 / PGM";
        };

        class Key9: UKSF_PRC163_RscHotspot {
            idc = 16359;
            x = PRC163_IMG_X(1031);
            y = PRC163_Y(1209);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; private _state = if (_radio isEqualTo '') then {createHashMap} else {[_radio] call UKSF_PRC163_fnc_getHMIState}; private _page = _state getOrDefault ['page','HOME']; private _input = switch (_page) do {case 'PRESET': {'9'}; case 'TXPOWER': {'LEFT'}; default {'DOWN'};}; [_input] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "9 / Down";
        };

        class Key0: UKSF_PRC163_RscHotspot {
            idc = 16350;
            x = PRC163_IMG_X(887);
            y = PRC163_Y(1274);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['0'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "0";
        };

        class NavigationLeft: UKSF_PRC163_RscHotspot {
            idc = 16344;
            x = PRC163_IMG_X(958);
            y = PRC163_Y(1274);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['LEFT'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Left";
        };

        class NavigationRight: UKSF_PRC163_RscHotspot {
            idc = 16346;
            x = PRC163_IMG_X(1031);
            y = PRC163_Y(1274);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['RIGHT'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Right";
        };

        class PresetUp: UKSF_PRC163_RscHotspot {
            idc = 16343;
            x = PRC163_IMG_X(1101);
            y = PRC163_Y(1209);
            w = PRC163_IMG_W(58);
            h = PRC163_H(56);
            onMouseButtonUp = "private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; private _state = if (_radio isEqualTo '') then {createHashMap} else {[_radio] call UKSF_PRC163_fnc_getHMIState}; private _page = _state getOrDefault ['page','HOME']; if (_page in ['HOME','PRESET','VOLUME','AUDIO','TXPOWER']) then {['RIGHT'] call UKSF_PRC163_fnc_handleHMIInput;};";
            tooltip = "PRE +";
        };

        class PresetDown: UKSF_PRC163_RscHotspot {
            idc = 16347;
            x = PRC163_IMG_X(1101);
            y = PRC163_Y(1266);
            w = PRC163_IMG_W(58);
            h = PRC163_H(57);
            onMouseButtonUp = "private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; private _state = if (_radio isEqualTo '') then {createHashMap} else {[_radio] call UKSF_PRC163_fnc_getHMIState}; private _page = _state getOrDefault ['page','HOME']; if (_page in ['HOME','PRESET','VOLUME','AUDIO','TXPOWER']) then {['LEFT'] call UKSF_PRC163_fnc_handleHMIInput;};";
            tooltip = "PRE -";
        };


        class LCDDualWatch: UKSF_PRC163_RscLCDText {
            idc = 16391;
            text = "";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(860);
            y = PRC163_Y(810);
            w = PRC163_IMG_W(88);
            h = PRC163_H(22);
        };

        class LCDMissionTime: UKSF_PRC163_RscLCDTextCentre {
            idc = 16392;
            text = "";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(948);
            y = PRC163_Y(810);
            w = PRC163_IMG_W(122);
            h = PRC163_H(22);
        };

        class LCDBatteryBar: UKSF_PRC163_RscLCDProgress {
            idc = 16417;
            x = PRC163_IMG_X(1090);
            y = PRC163_Y(816);
            w = PRC163_IMG_W(98);
            h = PRC163_H(14);
        };


        class LCDSelectorTop: UKSF_PRC163_RscLCDLine {
            idc = 16418;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDSelectorLeft: UKSF_PRC163_RscLCDLine {
            idc = 16419;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(40);
        };

        class LCDRadioOne: UKSF_PRC163_RscLCDText {
            idc = 16394;
            text = "VULOS";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(858);
            y = PRC163_Y(844);
            w = PRC163_IMG_W(82);
            h = PRC163_H(24);
        };

        class LCDRadioOnePT: UKSF_PRC163_RscLCDTextCentre {
            idc = 16420;
            text = "PT";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(950);
            y = PRC163_Y(844);
            w = PRC163_IMG_W(35);
            h = PRC163_H(24);
        };

        class LCDRadioOneFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16421;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(139);
            h = PRC163_H(40);
        };

        class LCDRadioTwo: UKSF_PRC163_RscLCDText {
            idc = 16395;
            text = "VULOS";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(1002);
            y = PRC163_Y(844);
            w = PRC163_IMG_W(82);
            h = PRC163_H(24);
        };

        class LCDRadioTwoPT: UKSF_PRC163_RscLCDTextCentre {
            idc = 16423;
            text = "PT";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(1082);
            y = PRC163_Y(844);
            w = PRC163_IMG_W(35);
            h = PRC163_H(24);
        };

        class LCDRadioTwoFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16422;
            x = PRC163_IMG_X(993);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(131);
            h = PRC163_H(40);
        };

        class LCDMissionModuleFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16424;
            x = PRC163_IMG_X(1124);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(68);
            h = PRC163_H(40);
        };

        class LCDMissionModule: UKSF_PRC163_RscLCDTextCentre {
            idc = 16425;
            text = "MM";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(1124);
            y = PRC163_Y(844);
            w = PRC163_IMG_W(68);
            h = PRC163_H(24);
        };

        class LCDEarRoute: UKSF_PRC163_RscLCDTextCentre {
            idc = 16410;
            text = "";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(879);
            w = PRC163_IMG_W(24);
            h = PRC163_H(24);
        };

        class LCDVolumeLabel: UKSF_PRC163_RscLCDText {
            idc = 16426;
            text = "VOL";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(880);
            y = PRC163_Y(879);
            w = PRC163_IMG_W(44);
            h = PRC163_H(24);
        };

        class LCDVolumeBar: UKSF_PRC163_RscLCDProgress {
            idc = 16427;
            x = PRC163_IMG_X(930);
            y = PRC163_Y(885);
            w = PRC163_IMG_W(62);
            h = PRC163_H(12);
        };

        class LCDWaveform: UKSF_PRC163_RscLCDTextCentre {
            idc = 16428;
            text = "VULOS";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(997);
            y = PRC163_Y(879);
            w = PRC163_IMG_W(76);
            h = PRC163_H(24);
        };

        class LCDReferenceMode: UKSF_PRC163_RscLCDTextCentre {
            idc = 16429;
            text = "MOI";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(1078);
            y = PRC163_Y(879);
            w = PRC163_IMG_W(48);
            h = PRC163_H(24);
        };

        class LCDReferenceStatus: UKSF_PRC163_RscLCDTextCentre {
            idc = 16430;
            text = "-------";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(1128);
            y = PRC163_Y(879);
            w = PRC163_IMG_W(64);
            h = PRC163_H(24);
        };

        class LCDConfiguredChannelName: UKSF_PRC163_RscLCDText {
            idc = 16411;
            text = "";
            sizeEx = 0.0155 * safeZoneH;
            x = PRC163_IMG_X(860);
            y = PRC163_Y(909);
            w = PRC163_IMG_W(328);
            h = PRC163_H(28);
        };

        class LCDSignalIcon: UKSF_PRC163_RscLCDPicture {
            idc = 16431;
            text = "\UKSF_PRC163\data\ui\icon_transmit.paa";
            colorText[] = {1,1,1,1};
            x = PRC163_IMG_X(1079);
            y = PRC163_Y(906.57);
            w = PRC163_IMG_W(52);
            h = PRC163_H(24.87);
            tooltip = "";
        };

        class LCDSignalBar: UKSF_PRC163_RscLCDProgress {
            idc = 16432;
            x = PRC163_IMG_X(1120);
            y = PRC163_Y(909.44);
            w = PRC163_IMG_W(68);
            h = PRC163_H(20);
            tooltip = "";
        };

        class LCDTypeValue: UKSF_PRC163_RscLCDTextCentre {
            idc = 16412;
            text = "---";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(852);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(62);
            h = PRC163_H(24);
        };

        class LCDTrafficValue: UKSF_PRC163_RscLCDTextCentre {
            idc = 16433;
            text = "---";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(918);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(62);
            h = PRC163_H(24);
        };

        class LCDModeValue: UKSF_PRC163_RscLCDTextCentre {
            idc = 16434;
            text = "---";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(984);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(62);
            h = PRC163_H(24);
        };

        class LCDChannelValue: UKSF_PRC163_RscLCDTextCentre {
            idc = 16435;
            text = "---";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(1050);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(62);
            h = PRC163_H(24);
        };

        class LCDKeyValue: UKSF_PRC163_RscLCDTextCentre {
            idc = 16436;
            text = "---";
            sizeEx = 0.0135 * safeZoneH;
            x = PRC163_IMG_X(1116);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(76);
            h = PRC163_H(24);
        };

        class LCDTypeHeading: UKSF_PRC163_RscLCDTextCentre {
            idc = 16437;
            text = "TYPE";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(852);
            y = PRC163_Y(972);
            w = PRC163_IMG_W(62);
            h = PRC163_H(20);
        };

        class LCDTrafficHeading: UKSF_PRC163_RscLCDTextCentre {
            idc = 16438;
            text = "TRF";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(918);
            y = PRC163_Y(972);
            w = PRC163_IMG_W(62);
            h = PRC163_H(20);
        };

        class LCDModeHeading: UKSF_PRC163_RscLCDTextCentre {
            idc = 16439;
            text = "MOD";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(984);
            y = PRC163_Y(972);
            w = PRC163_IMG_W(62);
            h = PRC163_H(20);
        };

        class LCDChannelHeading: UKSF_PRC163_RscLCDTextCentre {
            idc = 16440;
            text = "CHAN";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(1050);
            y = PRC163_Y(972);
            w = PRC163_IMG_W(62);
            h = PRC163_H(20);
        };

        class LCDKeyHeading: UKSF_PRC163_RscLCDTextCentre {
            idc = 16441;
            text = "KEY";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(1116);
            y = PRC163_Y(972);
            w = PRC163_IMG_W(76);
            h = PRC163_H(20);
        };

        class LCDPositionTopSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16442;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(994);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDPositionStatus: UKSF_PRC163_RscLCDTextCentre {
            idc = 16443;
            text = "POSITION NOT AVAILABLE";
            sizeEx = 0.0085 * safeZoneH;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(996);
            w = PRC163_IMG_W(338);
            h = PRC163_H(12);
        };

        class LCDPositionBottomSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16444;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(1008);
            w = PRC163_IMG_W(0);
            h = PRC163_H(0);
        };

        class LCDOuterBorderLeft: UKSF_PRC163_RscLCDLine {
            idc = 16445;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(160);
        };

        class LCDOuterBorderRight: UKSF_PRC163_RscLCDLine {
            idc = 16446;
            x = PRC163_IMG_X(1190);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(160);
        };


        class LCDMenuTopBorder: UKSF_PRC163_RscLCDLine {
            idc = 16450;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDMenuLeftBorder: UKSF_PRC163_RscLCDLine {
            idc = 16451;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDMenuRightBorder: UKSF_PRC163_RscLCDLine {
            idc = 16452;
            x = PRC163_IMG_X(1190);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDMenuBottomBorder: UKSF_PRC163_RscLCDLine {
            idc = 16453;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(1008);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDMenuTitle: UKSF_PRC163_RscLCDTextCentre {
            idc = 16454;
            text = "MAIN MENU";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(842);
            w = PRC163_IMG_W(320);
            h = PRC163_H(20);
        };

        class LCDMenuTitleSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16455;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(866);
            w = PRC163_IMG_W(320);
            h = PRC163_H(2);
        };

        class LCDMenuRow1: UKSF_PRC163_RscLCDText {
            idc = 16456;
            text = "";
            sizeEx = 0.0115 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(312);
            h = PRC163_H(20);
        };

        class LCDMenuRow2: LCDMenuRow1 {
            idc = 16457;
            y = PRC163_Y(894);
        };

        class LCDMenuRow3: LCDMenuRow1 {
            idc = 16458;
            y = PRC163_Y(916);
        };

        class LCDMenuRow4: LCDMenuRow1 {
            idc = 16459;
            y = PRC163_Y(938);
        };

        class LCDMenuRow5: LCDMenuRow1 {
            idc = 16460;
            y = PRC163_Y(960);
        };

        class LCDMenuScrollTrack: UKSF_PRC163_RscLCDLine {
            idc = 16461;
            x = PRC163_IMG_X(1181);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(2);
            h = PRC163_H(108);
        };

        class LCDMenuScrollThumb: UKSF_PRC163_RscLCDLine {
            idc = 16462;
            x = PRC163_IMG_X(1178);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(8);
            h = PRC163_H(68);
        };

        class LCDMenuPosition: UKSF_PRC163_RscLCDText {
            idc = 16463;
            style = 1;
            text = "1/8";
            sizeEx = 0.0095 * safeZoneH;
            x = PRC163_IMG_X(1126);
            y = PRC163_Y(842);
            w = PRC163_IMG_W(54);
            h = PRC163_H(20);
        };

        class LCDMenuFooterSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16464;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(984);
            w = PRC163_IMG_W(320);
            h = PRC163_H(2);
        };

        class LCDMenuInstruction: UKSF_PRC163_RscLCDTextCentre {
            idc = 16465;
            text = "UP/DOWN MOVE  ENT SELECT  CLR HOME";
            sizeEx = 0.0082 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(988);
            w = PRC163_IMG_W(320);
            h = PRC163_H(16);
        };

        class LCDRTSelectTopBorder: UKSF_PRC163_RscLCDLine {
            idc = 16570;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDRTSelectLeftBorder: UKSF_PRC163_RscLCDLine {
            idc = 16571;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDRTSelectRightBorder: UKSF_PRC163_RscLCDLine {
            idc = 16572;
            x = PRC163_IMG_X(1190);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDRTSelectBottomBorder: UKSF_PRC163_RscLCDLine {
            idc = 16573;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(1008);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDRTSelectTitle: UKSF_PRC163_RscLCDTextCentre {
            idc = 16574;
            text = "R/T SELECT";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(842);
            w = PRC163_IMG_W(320);
            h = PRC163_H(20);
        };

        class LCDRTSelectTitleSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16575;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(866);
            w = PRC163_IMG_W(320);
            h = PRC163_H(2);
        };

        class LCDRTSelectCurrent: UKSF_PRC163_RscLCDTextCentre {
            idc = 16576;
            text = "R/T 1 SELECTED";
            sizeEx = 0.015 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(318);
            h = PRC163_H(27);
        };

        class LCDRTSelectOneHeader: UKSF_PRC163_RscLCDText {
            idc = 16577;
            text = "R/T 1                         P01";
            sizeEx = 0.0098 * safeZoneH;
            x = PRC163_IMG_X(868);
            y = PRC163_Y(905);
            w = PRC163_IMG_W(306);
            h = PRC163_H(16);
        };

        class LCDRTSelectOneName: UKSF_PRC163_RscLCDText {
            idc = 16578;
            text = "OPEN NET A";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(868);
            y = PRC163_Y(921);
            w = PRC163_IMG_W(306);
            h = PRC163_H(17);
        };

        class LCDRTSelectTwoHeader: UKSF_PRC163_RscLCDText {
            idc = 16580;
            text = "R/T 2                         P02";
            sizeEx = 0.0098 * safeZoneH;
            x = PRC163_IMG_X(868);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(306);
            h = PRC163_H(16);
        };

        class LCDRTSelectTwoName: UKSF_PRC163_RscLCDText {
            idc = 16581;
            text = "Z11";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(868);
            y = PRC163_Y(962);
            w = PRC163_IMG_W(306);
            h = PRC163_H(17);
        };

        class LCDRTSelectOneFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16582;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(901);
            w = PRC163_IMG_W(318);
            h = PRC163_H(41);
        };

        class LCDRTSelectTwoFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16583;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(942);
            w = PRC163_IMG_W(318);
            h = PRC163_H(41);
        };

        class LCDRTSelectInstructionOne: UKSF_PRC163_RscLCDTextCentre {
            idc = 16584;
            text = "ARROWS / PRE +/- SELECT";
            sizeEx = 0.0087 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(985);
            w = PRC163_IMG_W(318);
            h = PRC163_H(11);
        };

        class LCDRTSelectInstructionTwo: UKSF_PRC163_RscLCDTextCentre {
            idc = 16585;
            text = "ENT HOME / CLR BACK";
            sizeEx = 0.0087 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(996);
            w = PRC163_IMG_W(318);
            h = PRC163_H(11);
        };

        class LCDRTSelectSelectionMarker: UKSF_PRC163_RscLCDTextCentre {
            idc = 16586;
            text = "";
            x = PRC163_IMG_X(864);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(1);
            h = PRC163_H(1);
        };

        class LCDPresetTopBorder: UKSF_PRC163_RscLCDLine {
            idc = 16470;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDPresetLeftBorder: UKSF_PRC163_RscLCDLine {
            idc = 16471;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDPresetRightBorder: UKSF_PRC163_RscLCDLine {
            idc = 16472;
            x = PRC163_IMG_X(1190);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDPresetBottomBorder: UKSF_PRC163_RscLCDLine {
            idc = 16473;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(1008);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDPresetTitle: UKSF_PRC163_RscLCDTextCentre {
            idc = 16474;
            text = "PRESET";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(842);
            w = PRC163_IMG_W(320);
            h = PRC163_H(20);
        };

        class LCDPresetTitleSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16475;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(866);
            w = PRC163_IMG_W(320);
            h = PRC163_H(2);
        };

        class LCDPresetLineLabel: UKSF_PRC163_RscLCDTextCentre {
            idc = 16476;
            text = "R/T 1 SELECTED";
            sizeEx = 0.0115 * safeZoneH;
            colorText[] = {0.31372549,0.321568627,0.258823529,1};
            colorBackground[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
            x = PRC163_IMG_X(864);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(218);
            h = PRC163_H(20);
        };

        class LCDPresetCurrent: UKSF_PRC163_RscLCDTextCentre {
            idc = 16477;
            text = "P01";
            sizeEx = 0.0115 * safeZoneH;
            colorText[] = {0.31372549,0.321568627,0.258823529,1};
            colorBackground[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
            x = PRC163_IMG_X(1086);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(96);
            h = PRC163_H(20);
        };

        class LCDPresetDescription: UKSF_PRC163_RscLCDTextCentre {
            idc = 16478;
            text = "OPEN NET A";
            sizeEx = 0.014 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(897);
            w = PRC163_IMG_W(318);
            h = PRC163_H(23);
        };

        class LCDPresetFrequency: UKSF_PRC163_RscLCDTextCentre {
            idc = 16479;
            text = "59.375 MHz";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(921);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDPresetEntryLabel: UKSF_PRC163_RscLCDTextCentre {
            idc = 16480;
            text = "DIRECT ENTRY";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(872);
            y = PRC163_Y(947);
            w = PRC163_IMG_W(140);
            h = PRC163_H(20);
        };

        class LCDPresetEntry: UKSF_PRC163_RscLCDTextCentre {
            idc = 16481;
            text = "P__";
            sizeEx = 0.014 * safeZoneH;
            colorText[] = {0.31372549,0.321568627,0.258823529,1};
            colorBackground[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
            x = PRC163_IMG_X(1020);
            y = PRC163_Y(944);
            w = PRC163_IMG_W(90);
            h = PRC163_H(26);
        };

        class LCDPresetEntryFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16482;
            x = PRC163_IMG_X(1018);
            y = PRC163_Y(942);
            w = PRC163_IMG_W(94);
            h = PRC163_H(30);
        };

        class LCDPresetInstructionOne: UKSF_PRC163_RscLCDTextCentre {
            idc = 16483;
            text = "ARROWS / PRE +/- CHANGE";
            sizeEx = 0.009 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(975);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };

        class LCDPresetInstructionTwo: UKSF_PRC163_RscLCDTextCentre {
            idc = 16484;
            text = "01-99 + ENT / CLR BACK";
            sizeEx = 0.009 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(992);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };


        class LCDVolumePageTopBorder: UKSF_PRC163_RscLCDLine {
            idc = 16490;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDVolumePageLeftBorder: UKSF_PRC163_RscLCDLine {
            idc = 16491;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDVolumePageRightBorder: UKSF_PRC163_RscLCDLine {
            idc = 16492;
            x = PRC163_IMG_X(1190);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDVolumePageBottomBorder: UKSF_PRC163_RscLCDLine {
            idc = 16493;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(1008);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDVolumePageTitle: UKSF_PRC163_RscLCDTextCentre {
            idc = 16494;
            text = "VOLUME";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(842);
            w = PRC163_IMG_W(320);
            h = PRC163_H(20);
        };

        class LCDVolumePageTitleSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16495;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(866);
            w = PRC163_IMG_W(320);
            h = PRC163_H(2);
        };

        class LCDVolumePageLine: UKSF_PRC163_RscLCDTextCentre {
            idc = 16496;
            text = "R/T 1 SELECTED";
            sizeEx = 0.0115 * safeZoneH;
            colorText[] = {0.31372549,0.321568627,0.258823529,1};
            colorBackground[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
            x = PRC163_IMG_X(864);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(318);
            h = PRC163_H(20);
        };

        class LCDVolumePageLabel: UKSF_PRC163_RscLCDTextCentre {
            idc = 16497;
            text = "CURRENT VOLUME";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(897);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDVolumePageValue: UKSF_PRC163_RscLCDTextCentre {
            idc = 16498;
            text = "100%";
            sizeEx = 0.018 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(915);
            w = PRC163_IMG_W(318);
            h = PRC163_H(27);
        };

        class LCDVolumePageBar: UKSF_PRC163_RscLCDProgress {
            idc = 16499;
            colorFrame[] = {0,0,0,0};
            x = PRC163_IMG_X(889);
            y = PRC163_Y(953);
            w = PRC163_IMG_W(268);
            h = PRC163_H(12);
        };

        class LCDVolumePageInstructionOne: UKSF_PRC163_RscLCDTextCentre {
            idc = 16500;
            text = "ARROWS / PRE +/- ADJUST";
            sizeEx = 0.009 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(975);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };

        class LCDVolumePageInstructionTwo: UKSF_PRC163_RscLCDTextCentre {
            idc = 16501;
            text = "ENT HOME / CLR BACK";
            sizeEx = 0.009 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(992);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };

        class LCDVolumePageBarFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16502;
            x = PRC163_IMG_X(884);
            y = PRC163_Y(948);
            w = PRC163_IMG_W(278);
            h = PRC163_H(22);
        };

        class LCDAudioPageTopBorder: UKSF_PRC163_RscLCDLine {
            idc = 16510;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDAudioPageLeftBorder: UKSF_PRC163_RscLCDLine {
            idc = 16511;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDAudioPageRightBorder: UKSF_PRC163_RscLCDLine {
            idc = 16512;
            x = PRC163_IMG_X(1190);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDAudioPageBottomBorder: UKSF_PRC163_RscLCDLine {
            idc = 16513;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(1008);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDAudioPageTitle: UKSF_PRC163_RscLCDTextCentre {
            idc = 16514;
            text = "AUDIO";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(842);
            w = PRC163_IMG_W(320);
            h = PRC163_H(20);
        };

        class LCDAudioPageTitleSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16515;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(866);
            w = PRC163_IMG_W(320);
            h = PRC163_H(2);
        };

        class LCDAudioPageLine: UKSF_PRC163_RscLCDTextCentre {
            idc = 16516;
            text = "R/T 1 SELECTED";
            sizeEx = 0.0115 * safeZoneH;
            colorText[] = {0.31372549,0.321568627,0.258823529,1};
            colorBackground[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
            x = PRC163_IMG_X(864);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(318);
            h = PRC163_H(20);
        };

        class LCDAudioPageLabel: UKSF_PRC163_RscLCDTextCentre {
            idc = 16517;
            text = "CURRENT ROUTING";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(897);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDAudioPageValue: UKSF_PRC163_RscLCDTextCentre {
            idc = 16518;
            text = "BOTH";
            sizeEx = 0.018 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(915);
            w = PRC163_IMG_W(318);
            h = PRC163_H(27);
        };

        class LCDAudioPageLeftOption: UKSF_PRC163_RscLCDTextCentre {
            idc = 16519;
            text = "LEFT";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(868);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(94);
            h = PRC163_H(22);
        };

        class LCDAudioPageBothOption: UKSF_PRC163_RscLCDTextCentre {
            idc = 16520;
            text = "BOTH";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(976);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(94);
            h = PRC163_H(22);
        };

        class LCDAudioPageRightOption: UKSF_PRC163_RscLCDTextCentre {
            idc = 16521;
            text = "RIGHT";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(1084);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(94);
            h = PRC163_H(22);
        };

        class LCDAudioPageInstructionOne: UKSF_PRC163_RscLCDTextCentre {
            idc = 16522;
            text = "ARROWS / PRE +/- ADJUST";
            sizeEx = 0.009 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(975);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };

        class LCDAudioPageInstructionTwo: UKSF_PRC163_RscLCDTextCentre {
            idc = 16523;
            text = "ENT HOME / CLR BACK";
            sizeEx = 0.009 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(992);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };

        class LCDAudioPageLeftOptionFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16524;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(942);
            w = PRC163_IMG_W(102);
            h = PRC163_H(30);
        };

        class LCDAudioPageBothOptionFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16525;
            x = PRC163_IMG_X(972);
            y = PRC163_Y(942);
            w = PRC163_IMG_W(102);
            h = PRC163_H(30);
        };

        class LCDAudioPageRightOptionFrame: UKSF_PRC163_RscLCDFrame {
            idc = 16526;
            x = PRC163_IMG_X(1080);
            y = PRC163_Y(942);
            w = PRC163_IMG_W(102);
            h = PRC163_H(30);
        };

        class LCDStatusPageTopBorder: UKSF_PRC163_RscLCDLine {
            idc = 16530;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDStatusPageLeftBorder: UKSF_PRC163_RscLCDLine {
            idc = 16531;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDStatusPageRightBorder: UKSF_PRC163_RscLCDLine {
            idc = 16532;
            x = PRC163_IMG_X(1190);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDStatusPageBottomBorder: UKSF_PRC163_RscLCDLine {
            idc = 16533;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(1008);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDStatusPageTitle: UKSF_PRC163_RscLCDTextCentre {
            idc = 16534;
            text = "STATUS";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(842);
            w = PRC163_IMG_W(320);
            h = PRC163_H(20);
        };

        class LCDStatusPageTitleSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16535;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(866);
            w = PRC163_IMG_W(320);
            h = PRC163_H(2);
        };

        class LCDStatusPageSelectedLine: UKSF_PRC163_RscLCDTextCentre {
            idc = 16536;
            text = "R/T 1 SELECTED      P01";
            sizeEx = 0.0098 * safeZoneH;
            colorText[] = {0.31372549,0.321568627,0.258823529,1};
            colorBackground[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
            x = PRC163_IMG_X(864);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(318);
            h = PRC163_H(20);
        };

        class LCDStatusPageChannel: UKSF_PRC163_RscLCDText {
            idc = 16537;
            text = "CHANNEL  OPEN NET A";
            sizeEx = 0.0095 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(891);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDStatusPageFrequency: UKSF_PRC163_RscLCDText {
            idc = 16538;
            text = "FREQ     ---.--- MHz";
            sizeEx = 0.0095 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(910);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDStatusPageTxPower: UKSF_PRC163_RscLCDText {
            idc = 16539;
            text = "TX POWER 5 W";
            sizeEx = 0.0095 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(929);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDStatusPageDualWatch: UKSF_PRC163_RscLCDText {
            idc = 16540;
            text = "DUAL WATCH      ON";
            sizeEx = 0.0095 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(948);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDStatusPageBattery: UKSF_PRC163_RscLCDText {
            idc = 16541;
            text = "BATTERY  100% NORMAL";
            sizeEx = 0.0095 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(967);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDStatusPageInstruction: UKSF_PRC163_RscLCDTextCentre {
            idc = 16542;
            text = "ENT HOME / CLR BACK";
            sizeEx = 0.009 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(990);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };


        class LCDTxPowerPageTopBorder: UKSF_PRC163_RscLCDLine {
            idc = 16550;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDTxPowerPageLeftBorder: UKSF_PRC163_RscLCDLine {
            idc = 16551;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDTxPowerPageRightBorder: UKSF_PRC163_RscLCDLine {
            idc = 16552;
            x = PRC163_IMG_X(1190);
            y = PRC163_Y(836);
            w = PRC163_IMG_W(2);
            h = PRC163_H(174);
        };

        class LCDTxPowerPageBottomBorder: UKSF_PRC163_RscLCDLine {
            idc = 16553;
            x = PRC163_IMG_X(854);
            y = PRC163_Y(1008);
            w = PRC163_IMG_W(338);
            h = PRC163_H(2);
        };

        class LCDTxPowerPageTitle: UKSF_PRC163_RscLCDTextCentre {
            idc = 16554;
            text = "TX POWER";
            sizeEx = 0.0125 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(842);
            w = PRC163_IMG_W(320);
            h = PRC163_H(20);
        };

        class LCDTxPowerPageTitleSeparator: UKSF_PRC163_RscLCDLine {
            idc = 16555;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(866);
            w = PRC163_IMG_W(320);
            h = PRC163_H(2);
        };

        class LCDTxPowerPageLine: UKSF_PRC163_RscLCDTextCentre {
            idc = 16556;
            text = "R/T 1 SELECTED";
            sizeEx = 0.0115 * safeZoneH;
            colorText[] = {0.31372549,0.321568627,0.258823529,1};
            colorBackground[] = {PRC163_LCD_DARK,PRC163_LCD_DARK,PRC163_LCD_DARK,0.96};
            x = PRC163_IMG_X(864);
            y = PRC163_Y(872);
            w = PRC163_IMG_W(318);
            h = PRC163_H(20);
        };

        class LCDTxPowerPageLabel: UKSF_PRC163_RscLCDTextCentre {
            idc = 16557;
            text = "OUTPUT POWER";
            sizeEx = 0.0105 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(897);
            w = PRC163_IMG_W(318);
            h = PRC163_H(18);
        };

        class LCDTxPowerPageValue: UKSF_PRC163_RscLCDTextCentre {
            idc = 16558;
            text = "5 W";
            sizeEx = 0.017 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(915);
            w = PRC163_IMG_W(318);
            h = PRC163_H(27);
        };

        class LCDTxPowerPageQuarterOption: UKSF_PRC163_RscLCDTextCentre {
            idc = 16559;
            text = "0.25 W";
            sizeEx = 0.0092 * safeZoneH;
            x = PRC163_IMG_X(862);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(62);
            h = PRC163_H(22);
        };

        class LCDTxPowerPageHalfOption: UKSF_PRC163_RscLCDTextCentre {
            idc = 16560;
            text = "0.5 W";
            sizeEx = 0.0092 * safeZoneH;
            x = PRC163_IMG_X(926);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(62);
            h = PRC163_H(22);
        };

        class LCDTxPowerPageOneOption: UKSF_PRC163_RscLCDTextCentre {
            idc = 16561;
            text = "1 W";
            sizeEx = 0.0092 * safeZoneH;
            x = PRC163_IMG_X(990);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(62);
            h = PRC163_H(22);
        };

        class LCDTxPowerPageTwoHalfOption: UKSF_PRC163_RscLCDTextCentre {
            idc = 16562;
            text = "2.5 W";
            sizeEx = 0.0092 * safeZoneH;
            x = PRC163_IMG_X(1054);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(62);
            h = PRC163_H(22);
        };

        class LCDTxPowerPageFiveOption: UKSF_PRC163_RscLCDTextCentre {
            idc = 16563;
            text = "5 W";
            sizeEx = 0.0092 * safeZoneH;
            x = PRC163_IMG_X(1118);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(64);
            h = PRC163_H(22);
        };

        class LCDTxPowerPageInstructionOne: UKSF_PRC163_RscLCDTextCentre {
            idc = 16564;
            text = "ARROWS / PRE +/- ADJUST";
            sizeEx = 0.0086 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(975);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };

        class LCDTxPowerPageInstructionTwo: UKSF_PRC163_RscLCDTextCentre {
            idc = 16565;
            text = "ENT HOME / CLR BACK";
            sizeEx = 0.009 * safeZoneH;
            x = PRC163_IMG_X(864);
            y = PRC163_Y(992);
            w = PRC163_IMG_W(318);
            h = PRC163_H(16);
        };

        class ViewSideControls: UKSF_PRC163_RscHotspot {
            idc = 16399;
            x = PRC163_IMG_X(675);
            y = PRC163_Y(470);
            w = PRC163_IMG_W(95);
            h = PRC163_H(1205);
            onMouseButtonUp = "private _display = ctrlParent (_this select 0); uiNamespace setVariable ['UKSF_PRC163_view','SIDE']; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow false; _ctrl ctrlEnable false;} forEach (uiNamespace getVariable ['UKSF_PRC163_frontViewControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow true; _ctrl ctrlEnable true;} forEach (uiNamespace getVariable ['UKSF_PRC163_sideViewControls',[]]);";
            tooltip = "View side controls";
        };

        class ReturnToFront: UKSF_PRC163_RscHotspot {
            idc = 16400;
            x = PRC163_IMG_X(1195);
            y = PRC163_Y(470);
            w = PRC163_IMG_W(95);
            h = PRC163_H(1205);
            onMouseButtonUp = "private _display = ctrlParent (_this select 0); uiNamespace setVariable ['UKSF_PRC163_view','FRONT']; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow false; _ctrl ctrlEnable false;} forEach (uiNamespace getVariable ['UKSF_PRC163_sideViewControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow true; _ctrl ctrlEnable true;} forEach (uiNamespace getVariable ['UKSF_PRC163_frontBaseControls',[]]); private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; private _state = if (_radio isEqualTo '') then {createHashMap} else {[_radio] call UKSF_PRC163_fnc_getHMIState}; private _page = toUpper (_state getOrDefault ['page','HOME']); private _home = _page isEqualTo 'HOME'; private _menu = _page isEqualTo 'MENU'; private _preset = _page isEqualTo 'PRESET'; private _volume = _page isEqualTo 'VOLUME'; private _audio = _page isEqualTo 'AUDIO'; private _status = _page isEqualTo 'STATUS'; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _home; _ctrl ctrlEnable _home;} forEach (uiNamespace getVariable ['UKSF_PRC163_homeLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _menu; _ctrl ctrlEnable _menu;} forEach (uiNamespace getVariable ['UKSF_PRC163_menuLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _preset; _ctrl ctrlEnable _preset;} forEach (uiNamespace getVariable ['UKSF_PRC163_presetLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _volume; _ctrl ctrlEnable _volume;} forEach (uiNamespace getVariable ['UKSF_PRC163_volumeLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _audio; _ctrl ctrlEnable _audio;} forEach (uiNamespace getVariable ['UKSF_PRC163_audioLCDControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow _status; _ctrl ctrlEnable _status;} forEach (uiNamespace getVariable ['UKSF_PRC163_statusLCDControls',[]]);";
            tooltip = "Return to front";
        };

        class RTSelector: UKSF_PRC163_RscHotspot {
            idc = 16401;
            x = PRC163_IMG_X(965);
            y = PRC163_Y(520);
            w = PRC163_IMG_W(160);
            h = PRC163_H(65);
            onMouseButtonUp = "private _line = if ((_this select 1) isEqualTo 1) then {1} else {0}; private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; if !(_radio isEqualTo '') then {[_radio] call acre_api_fnc_setCurrentRadio; [_radio,_line] call UKSF_PRC163_fnc_selectLine;};";
            tooltip = "R/T selector: left-click R/T 1, right-click R/T 2";
        };

        class SideRocker: UKSF_PRC163_RscHotspot {
            idc = 16402;
            x = PRC163_IMG_X(1004);
            y = PRC163_Y(600);
            w = PRC163_IMG_W(80);
            h = PRC163_H(218);
            tooltip = "Side rocker";
        };
    };
};

#undef PRC163_LCD_DARK
#undef PRC163_IMG_X
#undef PRC163_IMG_W
#undef PRC163_UI_SCALE
#undef PRC163_UI_SIZE
#undef PRC163_UI_X
#undef PRC163_UI_Y
#undef PRC163_X
#undef PRC163_Y
#undef PRC163_W
#undef PRC163_H
