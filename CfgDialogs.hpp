class RscText;
class RscButton;

class UKSF_PRC163_RscText: RscText {
    font = "RobotoCondensed";
    sizeEx = 0.022 * safeZoneH;
    shadow = 0;
    colorText[] = {0.78,0.92,0.72,1};
    colorBackground[] = {0,0,0,0};
};

class UKSF_PRC163_RscButton: RscButton {
    font = "RobotoCondensed";
    sizeEx = 0.019 * safeZoneH;
    shadow = 0;

    colorText[] = {0.78,0.92,0.72,1};
    colorTextActive[] = {0.9,1,0.86,1};

    colorBackground[] = {0.075,0.085,0.07,1};
    colorBackgroundActive[] = {0.16,0.2,0.14,1};
    colorFocused[] = {0.16,0.2,0.14,1};

    colorDisabled[] = {0.3,0.3,0.3,1};
    colorBackgroundDisabled[] = {0.04,0.04,0.04,1};

    colorBorder[] = {0.18,0.21,0.17,1};
    borderSize = 0.0015;

    soundEnter[] = {"",0.1,1};
    soundPush[] = {"",0.1,1};
    soundClick[] = {"",0.1,1};
    soundEscape[] = {"",0.1,1};
};

class UKSF_PRC163_RscKey: UKSF_PRC163_RscButton {
    style = 2;
    sizeEx = 0.021 * safeZoneH;

    colorText[] = {0.72,0.74,0.69,1};
    colorBackground[] = {0.055,0.06,0.05,1};
};

class UKSF_PRC163_RadioDialog {
    idd = 16300;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = "uiNamespace setVariable ['UKSF_PRC163_display',_this select 0]; private _oldPFH = uiNamespace getVariable ['UKSF_PRC163_dialogPFH',-1]; if (_oldPFH >= 0) then {[_oldPFH] call CBA_fnc_removePerFrameHandler;}; [_this select 0] call UKSF_PRC163_fnc_updateDialog; private _pfh = [{private _display = uiNamespace getVariable ['UKSF_PRC163_display',displayNull]; if !(isNull _display) then {[_display] call UKSF_PRC163_fnc_updateDialog;};},0.1] call CBA_fnc_addPerFrameHandler; uiNamespace setVariable ['UKSF_PRC163_dialogPFH',_pfh];";

    onUnload = "private _pfh = uiNamespace getVariable ['UKSF_PRC163_dialogPFH',-1]; if (_pfh >= 0) then {[_pfh] call CBA_fnc_removePerFrameHandler;}; uiNamespace setVariable ['UKSF_PRC163_dialogPFH',-1]; private _radio = uiNamespace getVariable ['UKSF_PRC163_guiRadio','']; uiNamespace setVariable ['UKSF_PRC163_display',displayNull]; if !(_radio isEqualTo '') then {[_radio,'closeGui'] call acre_sys_data_fnc_interactEvent;};";

    class controlsBackground {
        class DialogShadow: RscText {
            idc = -1;

            x = safeZoneX + 0.357 * safeZoneW;
            y = safeZoneY + 0.047 * safeZoneH;
            w = 0.286 * safeZoneW;
            h = 0.896 * safeZoneH;

            colorBackground[] = {0,0,0,0.65};
        };

        class RadioBody: RscText {
            idc = -1;

            x = safeZoneX + 0.365 * safeZoneW;
            y = safeZoneY + 0.055 * safeZoneH;
            w = 0.27 * safeZoneW;
            h = 0.88 * safeZoneH;

            colorBackground[] = {0.075,0.08,0.065,0.99};
        };

        class RadioBodyInner: RscText {
            idc = -1;

            x = safeZoneX + 0.373 * safeZoneW;
            y = safeZoneY + 0.063 * safeZoneH;
            w = 0.254 * safeZoneW;
            h = 0.864 * safeZoneH;

            colorBackground[] = {0.045,0.05,0.04,1};
        };

        class AntennaBase: RscText {
            idc = -1;

            x = safeZoneX + 0.386 * safeZoneW;
            y = safeZoneY + 0.037 * safeZoneH;
            w = 0.038 * safeZoneW;
            h = 0.042 * safeZoneH;

            colorBackground[] = {0.035,0.038,0.032,1};
        };

        class LeftKnob: RscText {
            idc = -1;

            x = safeZoneX + 0.444 * safeZoneW;
            y = safeZoneY + 0.041 * safeZoneH;
            w = 0.034 * safeZoneW;
            h = 0.034 * safeZoneH;

            colorBackground[] = {0.055,0.06,0.05,1};
        };

        class RightKnob: RscText {
            idc = -1;

            x = safeZoneX + 0.536 * safeZoneW;
            y = safeZoneY + 0.041 * safeZoneH;
            w = 0.034 * safeZoneW;
            h = 0.034 * safeZoneH;

            colorBackground[] = {0.055,0.06,0.05,1};
        };

        class HeaderPanel: RscText {
            idc = -1;

            x = safeZoneX + 0.383 * safeZoneW;
            y = safeZoneY + 0.076 * safeZoneH;
            w = 0.234 * safeZoneW;
            h = 0.092 * safeZoneH;

            colorBackground[] = {0.032,0.038,0.03,1};
        };

        class LCDBezel: RscText {
            idc = -1;

            x = safeZoneX + 0.382 * safeZoneW;
            y = safeZoneY + 0.178 * safeZoneH;
            w = 0.236 * safeZoneW;
            h = 0.302 * safeZoneH;

            colorBackground[] = {0.015,0.018,0.014,1};
        };

        class LCDScreen: RscText {
            idc = -1;

            x = safeZoneX + 0.389 * safeZoneW;
            y = safeZoneY + 0.186 * safeZoneH;
            w = 0.222 * safeZoneW;
            h = 0.286 * safeZoneH;

            colorBackground[] = {0.028,0.042,0.027,1};
        };

        class LCDTopBar: RscText {
            idc = -1;

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.193 * safeZoneH;
            w = 0.21 * safeZoneW;
            h = 0.025 * safeZoneH;

            colorBackground[] = {0.045,0.065,0.042,1};
        };

        class RT1Panel: RscText {
            idc = -1;

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.224 * safeZoneH;
            w = 0.21 * safeZoneW;
            h = 0.092 * safeZoneH;

            colorBackground[] = {0.035,0.052,0.033,1};
        };

        class RT2Panel: RscText {
            idc = -1;

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.326 * safeZoneH;
            w = 0.21 * safeZoneW;
            h = 0.092 * safeZoneH;

            colorBackground[] = {0.035,0.052,0.033,1};
        };

        class LCDStatusPanel: RscText {
            idc = -1;

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.426 * safeZoneH;
            w = 0.21 * safeZoneW;
            h = 0.036 * safeZoneH;

            colorBackground[] = {0.045,0.065,0.042,1};
        };

        class FunctionPanel: RscText {
            idc = -1;

            x = safeZoneX + 0.383 * safeZoneW;
            y = safeZoneY + 0.493 * safeZoneH;
            w = 0.234 * safeZoneW;
            h = 0.424 * safeZoneH;

            colorBackground[] = {0.035,0.039,0.032,1};
        };

        class NavigationPanel: RscText {
            idc = -1;

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.548 * safeZoneH;
            w = 0.21 * safeZoneW;
            h = 0.087 * safeZoneH;

            colorBackground[] = {0.045,0.05,0.041,1};
        };

        class KeypadPanel: RscText {
            idc = -1;

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.646 * safeZoneH;
            w = 0.21 * safeZoneW;
            h = 0.224 * safeZoneH;

            colorBackground[] = {0.04,0.044,0.036,1};
        };
    };

    class controls {
        class Title: UKSF_PRC163_RscText {
            idc = 16301;
            text = "AN/PRC-163";
            style = 2;

            x = safeZoneX + 0.39 * safeZoneW;
            y = safeZoneY + 0.082 * safeZoneH;
            w = 0.22 * safeZoneW;
            h = 0.032 * safeZoneH;

            sizeEx = 0.029 * safeZoneH;
            colorText[] = {0.72,0.75,0.69,1};
        };

        class RadioId: UKSF_PRC163_RscText {
            idc = 16302;
            text = "RADIO: AN/PRC-163 1";
            style = 2;

            x = safeZoneX + 0.39 * safeZoneW;
            y = safeZoneY + 0.112 * safeZoneH;
            w = 0.22 * safeZoneW;
            h = 0.022 * safeZoneH;

            sizeEx = 0.018 * safeZoneH;
            colorText[] = {0.52,0.65,0.5,1};
        };

        class PreviousRadio: UKSF_PRC163_RscButton {
            idc = 16303;
            text = "RADIO -";

            x = safeZoneX + 0.392 * safeZoneW;
            y = safeZoneY + 0.137 * safeZoneH;
            w = 0.082 * safeZoneW;
            h = 0.026 * safeZoneH;

            sizeEx = 0.017 * safeZoneH;
            action = "[-1] call UKSF_PRC163_fnc_cycleRadio;";
            tooltip = "Previous physical AN/PRC-163";
        };

        class NextRadio: UKSF_PRC163_RscButton {
            idc = 16304;
            text = "RADIO +";

            x = safeZoneX + 0.526 * safeZoneW;
            y = safeZoneY + 0.137 * safeZoneH;
            w = 0.082 * safeZoneW;
            h = 0.026 * safeZoneH;

            sizeEx = 0.017 * safeZoneH;
            action = "[1] call UKSF_PRC163_fnc_cycleRadio;";
            tooltip = "Next physical AN/PRC-163";
        };

        class LCDModeLabel: UKSF_PRC163_RscText {
            idc = 16330;
            text = "DUAL-CHANNEL HANDHELD";
            style = 2;

            x = safeZoneX + 0.4 * safeZoneW;
            y = safeZoneY + 0.195 * safeZoneH;
            w = 0.2 * safeZoneW;
            h = 0.02 * safeZoneH;

            sizeEx = 0.015 * safeZoneH;
            colorText[] = {0.5,0.63,0.48,1};
        };

        class SelectedA: UKSF_PRC163_RscText {
            idc = 16310;
            text = ">";

            x = safeZoneX + 0.401 * safeZoneW;
            y = safeZoneY + 0.229 * safeZoneH;
            w = 0.016 * safeZoneW;
            h = 0.025 * safeZoneH;

            sizeEx = 0.025 * safeZoneH;
        };

        class LabelA: UKSF_PRC163_RscText {
            idc = 16311;
            text = "R/T 1";

            x = safeZoneX + 0.417 * safeZoneW;
            y = safeZoneY + 0.229 * safeZoneH;
            w = 0.063 * safeZoneW;
            h = 0.025 * safeZoneH;

            sizeEx = 0.025 * safeZoneH;
        };

        class SelectA: UKSF_PRC163_RscButton {
            idc = 16316;
            text = "SELECT";

            x = safeZoneX + 0.541 * safeZoneW;
            y = safeZoneY + 0.228 * safeZoneH;
            w = 0.058 * safeZoneW;
            h = 0.027 * safeZoneH;

            sizeEx = 0.016 * safeZoneH;
            action = "private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; if !(_radio isEqualTo '') then {[_radio] call acre_api_fnc_setCurrentRadio; [_radio,0] call UKSF_PRC163_fnc_selectLine;};";
            tooltip = "Select R/T 1 for normal ACRE PTT";
        };

        class ChannelA: UKSF_PRC163_RscText {
            idc = 16312;
            text = "P 01";

            x = safeZoneX + 0.417 * safeZoneW;
            y = safeZoneY + 0.257 * safeZoneH;
            w = 0.053 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.021 * safeZoneH;
        };

        class FrequencyA: UKSF_PRC163_RscText {
            idc = 16313;
            text = "59.375 MHz";

            x = safeZoneX + 0.469 * safeZoneW;
            y = safeZoneY + 0.257 * safeZoneH;
            w = 0.086 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.019 * safeZoneH;
        };

        class ReceiveA: UKSF_PRC163_RscText {
            idc = 16314;
            text = "RX --";

            x = safeZoneX + 0.555 * safeZoneW;
            y = safeZoneY + 0.257 * safeZoneH;
            w = 0.025 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.017 * safeZoneH;
        };

        class TransmitA: UKSF_PRC163_RscText {
            idc = 16315;
            text = "TX --";

            x = safeZoneX + 0.58 * safeZoneW;
            y = safeZoneY + 0.257 * safeZoneH;
            w = 0.025 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.017 * safeZoneH;
        };

        class AudioA: UKSF_PRC163_RscText {
            idc = 16317;
            text = "BOTH | VOL 100%";

            x = safeZoneX + 0.417 * safeZoneW;
            y = safeZoneY + 0.286 * safeZoneH;
            w = 0.175 * safeZoneW;
            h = 0.022 * safeZoneH;

            sizeEx = 0.017 * safeZoneH;
            colorText[] = {0.52,0.65,0.5,1};
        };

        class SelectedB: UKSF_PRC163_RscText {
            idc = 16320;
            text = "";

            x = safeZoneX + 0.401 * safeZoneW;
            y = safeZoneY + 0.331 * safeZoneH;
            w = 0.016 * safeZoneW;
            h = 0.025 * safeZoneH;

            sizeEx = 0.025 * safeZoneH;
        };

        class LabelB: UKSF_PRC163_RscText {
            idc = 16321;
            text = "R/T 2";

            x = safeZoneX + 0.417 * safeZoneW;
            y = safeZoneY + 0.331 * safeZoneH;
            w = 0.063 * safeZoneW;
            h = 0.025 * safeZoneH;

            sizeEx = 0.025 * safeZoneH;
        };

        class SelectB: UKSF_PRC163_RscButton {
            idc = 16326;
            text = "SELECT";

            x = safeZoneX + 0.541 * safeZoneW;
            y = safeZoneY + 0.33 * safeZoneH;
            w = 0.058 * safeZoneW;
            h = 0.027 * safeZoneH;

            sizeEx = 0.016 * safeZoneH;
            action = "private _radio = [] call UKSF_PRC163_fnc_getTargetRadio; if !(_radio isEqualTo '') then {[_radio] call acre_api_fnc_setCurrentRadio; [_radio,1] call UKSF_PRC163_fnc_selectLine;};";
            tooltip = "Select R/T 2 for normal ACRE PTT";
        };

        class ChannelB: UKSF_PRC163_RscText {
            idc = 16322;
            text = "P 02";

            x = safeZoneX + 0.417 * safeZoneW;
            y = safeZoneY + 0.359 * safeZoneH;
            w = 0.053 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.021 * safeZoneH;
        };

        class FrequencyB: UKSF_PRC163_RscText {
            idc = 16323;
            text = "59.500 MHz";

            x = safeZoneX + 0.469 * safeZoneW;
            y = safeZoneY + 0.359 * safeZoneH;
            w = 0.086 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.019 * safeZoneH;
        };

        class ReceiveB: UKSF_PRC163_RscText {
            idc = 16324;
            text = "RX --";

            x = safeZoneX + 0.555 * safeZoneW;
            y = safeZoneY + 0.359 * safeZoneH;
            w = 0.025 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.017 * safeZoneH;
        };

        class TransmitB: UKSF_PRC163_RscText {
            idc = 16325;
            text = "TX --";

            x = safeZoneX + 0.58 * safeZoneW;
            y = safeZoneY + 0.359 * safeZoneH;
            w = 0.025 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.017 * safeZoneH;
        };

        class AudioB: UKSF_PRC163_RscText {
            idc = 16327;
            text = "BOTH | VOL 100%";

            x = safeZoneX + 0.417 * safeZoneW;
            y = safeZoneY + 0.388 * safeZoneH;
            w = 0.175 * safeZoneW;
            h = 0.022 * safeZoneH;

            sizeEx = 0.017 * safeZoneH;
            colorText[] = {0.52,0.65,0.5,1};
        };

        class Instructions: UKSF_PRC163_RscText {
            idc = 16331;
            text = "POWER: ON | MODE: DUAL | BAT 100%";
            style = 2;

            x = safeZoneX + 0.399 * safeZoneW;
            y = safeZoneY + 0.432 * safeZoneH;
            w = 0.202 * safeZoneW;
            h = 0.024 * safeZoneH;

            sizeEx = 0.015 * safeZoneH;
            colorText[] = {0.52,0.65,0.5,1};
        };

        class P1Key: UKSF_PRC163_RscKey {
            idc = 16340;
            text = "P1";

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.503 * safeZoneH;
            w = 0.066 * safeZoneW;
            h = 0.034 * safeZoneH;

            action = "['P1'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Return to the PRC-163 home page";
        };

        class P2Key: UKSF_PRC163_RscKey {
            idc = 16341;
            text = "P2";

            x = safeZoneX + 0.467 * safeZoneW;
            y = safeZoneY + 0.503 * safeZoneH;
            w = 0.066 * safeZoneW;
            h = 0.034 * safeZoneH;

            action = "['P2'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Open the PRC-163 menu";
        };

        class P3Key: UKSF_PRC163_RscKey {
            idc = 16342;
            text = "P3";

            x = safeZoneX + 0.539 * safeZoneW;
            y = safeZoneY + 0.503 * safeZoneH;
            w = 0.066 * safeZoneW;
            h = 0.034 * safeZoneH;

            action = "['P3'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Toggle Dual Watch";
        };

        class NavigationUp: UKSF_PRC163_RscKey {
            idc = 16343;
            text = "UP";

            x = safeZoneX + 0.469 * safeZoneW;
            y = safeZoneY + 0.551 * safeZoneH;
            w = 0.062 * safeZoneW;
            h = 0.026 * safeZoneH;

            action = "['UP'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Move up or increase the current value";
        };

        class NavigationLeft: UKSF_PRC163_RscKey {
            idc = 16344;
            text = "LEFT";

            x = safeZoneX + 0.4 * safeZoneW;
            y = safeZoneY + 0.579 * safeZoneH;
            w = 0.064 * safeZoneW;
            h = 0.028 * safeZoneH;

            sizeEx = 0.015 * safeZoneH;
            action = "['LEFT'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Move left or decrease the current value";
        };

        class NavigationEnter: UKSF_PRC163_RscKey {
            idc = 16345;
            text = "ENT";

            x = safeZoneX + 0.469 * safeZoneW;
            y = safeZoneY + 0.579 * safeZoneH;
            w = 0.062 * safeZoneW;
            h = 0.028 * safeZoneH;

            action = "['ENT'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Confirm the current selection";
        };

        class NavigationRight: UKSF_PRC163_RscKey {
            idc = 16346;
            text = "RIGHT";

            x = safeZoneX + 0.536 * safeZoneW;
            y = safeZoneY + 0.579 * safeZoneH;
            w = 0.064 * safeZoneW;
            h = 0.028 * safeZoneH;

            sizeEx = 0.015 * safeZoneH;
            action = "['RIGHT'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Move right or increase the current value";
        };

        class NavigationDown: UKSF_PRC163_RscKey {
            idc = 16347;
            text = "DOWN";

            x = safeZoneX + 0.469 * safeZoneW;
            y = safeZoneY + 0.609 * safeZoneH;
            w = 0.062 * safeZoneW;
            h = 0.026 * safeZoneH;

            sizeEx = 0.015 * safeZoneH;
            action = "['DOWN'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Move down or decrease the current value";
        };

        class Key1: UKSF_PRC163_RscKey {
            idc = 16351;
            text = "1";

            x = safeZoneX + 0.4 * safeZoneW;
            y = safeZoneY + 0.655 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['1'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 1";
        };

        class Key2: UKSF_PRC163_RscKey {
            idc = 16352;
            text = "2";

            x = safeZoneX + 0.472 * safeZoneW;
            y = safeZoneY + 0.655 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['2'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 2";
        };

        class Key3: UKSF_PRC163_RscKey {
            idc = 16353;
            text = "3";

            x = safeZoneX + 0.544 * safeZoneW;
            y = safeZoneY + 0.655 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['3'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 3";
        };

        class Key4: UKSF_PRC163_RscKey {
            idc = 16354;
            text = "4";

            x = safeZoneX + 0.4 * safeZoneW;
            y = safeZoneY + 0.7 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['4'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 4";
        };

        class Key5: UKSF_PRC163_RscKey {
            idc = 16355;
            text = "5";

            x = safeZoneX + 0.472 * safeZoneW;
            y = safeZoneY + 0.7 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['5'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 5";
        };

        class Key6: UKSF_PRC163_RscKey {
            idc = 16356;
            text = "6";

            x = safeZoneX + 0.544 * safeZoneW;
            y = safeZoneY + 0.7 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['6'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 6";
        };

        class Key7: UKSF_PRC163_RscKey {
            idc = 16357;
            text = "7";

            x = safeZoneX + 0.4 * safeZoneW;
            y = safeZoneY + 0.745 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['7'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 7";
        };

        class Key8: UKSF_PRC163_RscKey {
            idc = 16358;
            text = "8";

            x = safeZoneX + 0.472 * safeZoneW;
            y = safeZoneY + 0.745 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['8'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 8";
        };

        class Key9: UKSF_PRC163_RscKey {
            idc = 16359;
            text = "9";

            x = safeZoneX + 0.544 * safeZoneW;
            y = safeZoneY + 0.745 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['9'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 9";
        };

        class ClearKey: UKSF_PRC163_RscKey {
            idc = 16360;;
            text = "CLR";

            x = safeZoneX + 0.4 * safeZoneW;
            y = safeZoneY + 0.79 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['CLR'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Clear an entry, go back, or close from the home page";
        };

        class Key0: UKSF_PRC163_RscKey {
            idc = 16350;
            text = "0";

            x = safeZoneX + 0.472 * safeZoneW;
            y = safeZoneY + 0.79 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['0'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Enter digit 0";
        };

        class EnterKey: UKSF_PRC163_RscKey {
            idc = 16361;
            text = "ENT";

            x = safeZoneX + 0.544 * safeZoneW;
            y = safeZoneY + 0.79 * safeZoneH;
            w = 0.056 * safeZoneW;
            h = 0.036 * safeZoneH;

            action = "['ENT'] call UKSF_PRC163_fnc_handleHMIInput;";
            tooltip = "Confirm the current selection";
        };

        class KeypadLegend: UKSF_PRC163_RscText {
            idc = -1;
            text = "P1 HOME  |  P2 MENU  |  P3 DUAL WATCH";
            style = 2;

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.875 * safeZoneH;
            w = 0.21 * safeZoneW;
            h = 0.022 * safeZoneH;

            sizeEx = 0.012 * safeZoneH;
            colorText[] = {0.38,0.44,0.36,1};
        };

        class ManufacturerLabel: UKSF_PRC163_RscText {
            idc = -1;
            text = "MULTI-CHANNEL TACTICAL RADIO";
            style = 2;

            x = safeZoneX + 0.395 * safeZoneW;
            y = safeZoneY + 0.899 * safeZoneH;
            w = 0.21 * safeZoneW;
            h = 0.018 * safeZoneH;

            sizeEx = 0.011 * safeZoneH;
            colorText[] = {0.3,0.34,0.29,1};
        };
    };
};