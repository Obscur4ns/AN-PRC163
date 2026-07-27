class CfgPatches {
    class UKSF_PRC163 {
        name = "UKSF AN/PRC-163";
        units[] = {};
        weapons[] = {
            "ACRE_PRC163",
            "UKSF_PRC163_Battery"
        };
        requiredVersion = 2.14;
        requiredAddons[] = {
            "cba_common",
            "cba_settings",
            "acre_sys_modes",
            "acre_sys_prc152",
            "ace_interact_menu",
            "A3_Ui_F"
        };
        author = "UKSF Surplus";
    };
};

#include "CfgWeapons.hpp"
#include "CfgFunctions.hpp"
#include "CfgAcreRadios.hpp"
#include "CfgAcreRadioModes.hpp"
#include "CfgDialogs.hpp"
#include "CfgRemoteExec.hpp"