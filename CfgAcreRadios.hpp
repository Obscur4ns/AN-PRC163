class CfgAcreComponents {
    class ACRE_PRC152;

    class ACRE_PRC163: ACRE_PRC152 {
        name = "AN/PRC-163";

        class Interfaces {
            class CfgAcreDataInterface {
                getListInfo = "acre_sys_prc152_fnc_getListInfo";
                setVolume = "UKSF_PRC163_fnc_setVolume";
                getVolume = "UKSF_PRC163_fnc_getVolume";
                setSpatial = "UKSF_PRC163_fnc_setSpatial";
                getSpatial = "UKSF_PRC163_fnc_getSpatial";
                setChannelData = "acre_sys_prc152_fnc_setChannelData";
                getChannelData = "acre_sys_prc152_fnc_getChannelData";
                getCurrentChannelData = "acre_sys_prc152_fnc_getCurrentChannelData";
                getCurrentChannel = "acre_sys_prc152_fnc_getCurrentChannel";
                setCurrentChannel = "acre_sys_prc152_fnc_setCurrentChannel";
                getStates = "acre_sys_prc152_fnc_getStates";
                getState = "acre_sys_prc152_fnc_getState";
                setState = "acre_sys_prc152_fnc_setState";
                getOnOffState = "acre_sys_prc152_fnc_getOnOffState";
                setOnOffState = "UKSF_PRC163_fnc_setOnOffState";
                initializeComponent = "acre_sys_prc152_fnc_initializeRadio";
                getChannelDescription = "acre_sys_prc152_fnc_getChannelDescription";
                isExternalAudio = "acre_sys_prc152_fnc_isExternalAudio";
            };

            class CfgAcrePhysicalInterface {
                getExternalAudioPosition = "acre_sys_prc152_fnc_getExternalAudioPosition";
            };

            class CfgAcreTransmissionInterface {
                handleBeginTransmission = "acre_sys_prc152_fnc_handleBeginTransmission";
                handleEndTransmission = "acre_sys_prc152_fnc_handleEndTransmission";
                handleSignalData = "acre_sys_prc152_fnc_handleSignalData";
                handleMultipleTransmissions = "UKSF_PRC163_fnc_handleMultipleTransmissions";
                handlePTTDown = "UKSF_PRC163_fnc_handlePTTDown";
                handlePTTUp = "UKSF_PRC163_fnc_handlePTTUp";
            };

            class CfgAcreInteractInterface {
                openGui = "UKSF_PRC163_fnc_openGui";
                closeGui = "UKSF_PRC163_fnc_closeGui";
            };
        };
    };

    class ACRE_243CM_VHF_TNC {
        compatibleRadios[] = {
            "ACRE_PRC148",
            "ACRE_PRC152",
            "ACRE_PRC163",
            "ACRE_PRC117F",
            "ACRE_PRC77",
            "ACRE_SEM70"
        };
    };

    class ACRE_643CM_VHF_TNC {
        compatibleRadios[] = {
            "ACRE_PRC148",
            "ACRE_PRC152",
            "ACRE_PRC163",
            "ACRE_PRC117F",
            "ACRE_PRC77",
            "ACRE_SEM70"
        };
    };

};