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
    colorText[] = {0,0,0,0.96};
    colorBackground[] = {0,0,0,0};
};

class UKSF_PRC163_RadioDialog {
    idd = 16300;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = "private _display = _this select 0; uiNamespace setVariable ['UKSF_PRC163_display',_display]; uiNamespace setVariable ['UKSF_PRC163_view','FRONT']; private _frontControls = [16303,16304,16343,16344,16345,16346,16347,16350,16351,16352,16353,16354,16355,16356,16357,16358,16359,16360,16370,16391,16392,16393,16394,16395,16396,16397,16398,16399]; private _sideControls = [16371,16400,16401,16402]; uiNamespace setVariable ['UKSF_PRC163_frontViewControls',_frontControls]; uiNamespace setVariable ['UKSF_PRC163_sideViewControls',_sideControls]; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow true; _ctrl ctrlEnable true;} forEach _frontControls; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow false; _ctrl ctrlEnable false;} forEach _sideControls; [_display] call acre_api_fnc_addDisplayPassthroughKeys;";
    onUnload = "private _radio = uiNamespace getVariable ['UKSF_PRC163_guiRadio','']; uiNamespace setVariable ['UKSF_PRC163_display',displayNull]; if !(_radio isEqualTo '') then {[_radio,'closeGui'] call acre_sys_data_fnc_interactEvent;};";

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
            onMouseButtonUp = "private _direction = if ((_this select 1) isEqualTo 1) then {-1} else {1}; [_direction] call UKSF_PRC163_fnc_cycleChannel;";
            tooltip = "Channel: left-click forward, right-click backward";
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
            onMouseButtonUp = "['6'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "6";
        };

        class EnterKey: UKSF_PRC163_RscHotspot {
            idc = 16345;
            x = PRC163_IMG_X(1101);
            y = PRC163_Y(1145);
            w = PRC163_IMG_W(58);
            h = PRC163_H(48);
            onMouseButtonUp = "['ENT'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "ENT";
        };

        class Key7: UKSF_PRC163_RscHotspot {
            idc = 16357;
            x = PRC163_IMG_X(887);
            y = PRC163_Y(1209);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['7'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "7";
        };

        class Key8: UKSF_PRC163_RscHotspot {
            idc = 16358;
            x = PRC163_IMG_X(958);
            y = PRC163_Y(1209);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['8'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "8";
        };

        class Key9: UKSF_PRC163_RscHotspot {
            idc = 16359;
            x = PRC163_IMG_X(1031);
            y = PRC163_Y(1209);
            w = PRC163_IMG_W(57);
            h = PRC163_H(49);
            onMouseButtonUp = "['9'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "9";
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
            onMouseButtonUp = "['UP'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "PRE +";
        };

        class PresetDown: UKSF_PRC163_RscHotspot {
            idc = 16347;
            x = PRC163_IMG_X(1101);
            y = PRC163_Y(1266);
            w = PRC163_IMG_W(58);
            h = PRC163_H(57);
            onMouseButtonUp = "['DOWN'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "PRE -";
        };


        class LCDTopRowCalibration: UKSF_PRC163_RscLCDText {
            idc = 16391;
            text = "X8:OFF     1B:32:02     BAT";
            x = PRC163_IMG_X(860);
            y = PRC163_Y(810);
            w = PRC163_IMG_W(328);
            h = PRC163_H(22);
        };

        class LCDSecondRowCalibration: UKSF_PRC163_RscLCDText {
            idc = 16392;
            text = "R/T 1    P01    59.375";
            x = PRC163_IMG_X(860);
            y = PRC163_Y(844);
            w = PRC163_IMG_W(328);
            h = PRC163_H(22);
        };

        class LCDThirdRowCalibration: UKSF_PRC163_RscLCDText {
            idc = 16393;
            text = "R/T 2    P02    59.500";
            x = PRC163_IMG_X(860);
            y = PRC163_Y(878);
            w = PRC163_IMG_W(328);
            h = PRC163_H(22);
        };

        class LCDFourthRowCalibration: UKSF_PRC163_RscLCDText {
            idc = 16394;
            text = "DUAL WATCH     BAT 100%";
            x = PRC163_IMG_X(860);
            y = PRC163_Y(912);
            w = PRC163_IMG_W(328);
            h = PRC163_H(22);
        };

        class LCDFifthRowCalibration: UKSF_PRC163_RscLCDText {
            idc = 16395;
            text = "RX --   TX --   VOL 80%";
            x = PRC163_IMG_X(860);
            y = PRC163_Y(946);
            w = PRC163_IMG_W(328);
            h = PRC163_H(22);
        };


        class LCDSoftKeyLeft: UKSF_PRC163_RscHotspot {
            idc = 16396;
            x = PRC163_IMG_X(850);
            y = PRC163_Y(974);
            w = PRC163_IMG_W(92);
            h = PRC163_H(31);
            tooltip = "Left soft key";
        };

        class LCDSoftKeyCentre: UKSF_PRC163_RscHotspot {
            idc = 16397;
            x = PRC163_IMG_X(951);
            y = PRC163_Y(974);
            w = PRC163_IMG_W(145);
            h = PRC163_H(31);
            tooltip = "Centre soft key";
        };

        class LCDSoftKeyRight: UKSF_PRC163_RscHotspot {
            idc = 16398;
            x = PRC163_IMG_X(1106);
            y = PRC163_Y(974);
            w = PRC163_IMG_W(92);
            h = PRC163_H(31);
            tooltip = "Right soft key";
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
            onMouseButtonUp = "private _display = ctrlParent (_this select 0); uiNamespace setVariable ['UKSF_PRC163_view','FRONT']; {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow false; _ctrl ctrlEnable false;} forEach (uiNamespace getVariable ['UKSF_PRC163_sideViewControls',[]]); {private _ctrl = _display displayCtrl _x; _ctrl ctrlShow true; _ctrl ctrlEnable true;} forEach (uiNamespace getVariable ['UKSF_PRC163_frontViewControls',[]]);";
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

        class SideRockerCalibration: UKSF_PRC163_RscCalibrationHotspot {
            idc = 16402;
            x = PRC163_IMG_X(1004);
            y = PRC163_Y(600);
            w = PRC163_IMG_W(80);
            h = PRC163_H(218);
            tooltip = "SIDE ROCKER CALIBRATION";
        };
    };
};

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
