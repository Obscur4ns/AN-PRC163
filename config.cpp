class CfgPatches {
    class UKSF_PRC163 {
        name = "UKSF AN/PRC-163";
        units[] = {
            "UKSF_PRC163_World",
            "UKSF_PRC163_Battery_World"
        };
        weapons[] = {
            "ACRE_PRC163",
            "UKSF_PRC163_Battery"
        };
        requiredVersion = 2.14;
        requiredAddons[] = {
            "cba_common",
            "cba_keybinding",
            "cba_settings",
            "acre_api",
            "acre_ace_interact",
            "acre_sys_core",
            "acre_sys_data",
            "acre_sys_external",
            "acre_sys_modes",
            "acre_sys_prc152",
            "acre_sys_radio",
            "acre_sys_rack",
            "acre_sys_antenna",
            "ace_common",
            "ace_interact_menu",
            "A3_Weapons_F",
            "A3_Ui_F"
        };
        author = "UKSF Surplus";
    };
};
class CfgUIGrids {
    class IGUI {
        class Presets {
            class Arma3 {
                class Variables {
                    grid_UKSF_PRC163_Notifications[] = {
                        {
                            "((safeZoneX + safeZoneW) - (10 * (((safeZoneW / safeZoneH) min 1.2) / 40)) - (2.9 * (((safeZoneW / safeZoneH) min 1.2) / 40)))",
                            "safeZoneY + (0.175 * safeZoneH)",
                            "(10 * (((safeZoneW / safeZoneH) min 1.2) / 40))",
                            "(6 * ((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25))"
                        },
                        "(((safeZoneW / safeZoneH) min 1.2) / 40)",
                        "((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25)"
                    };
                };
            };
        };
        class Variables {
            class grid_UKSF_PRC163_Notifications {
                displayName = "PRC-163 Notifications";
                description = "Position of AN/PRC-163 status, warning and battery notifications.";
                preview = "\z\ace\addons\common\UI\ACE_Hint_Preview_ca.paa";
                saveToProfile[] = {0,1};
            };
        };
    };
};
#include "CfgWeapons.hpp"
#include "CfgVehicles.hpp"
#include "CfgFunctions.hpp"
#include "CfgAcreRadios.hpp"
#include "CfgAcreRadioModes.hpp"
#include "CfgDialogs.hpp"
#include "CfgRemoteExec.hpp"