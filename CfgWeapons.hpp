class CfgWeapons {
    class CBA_MiscItem;
    class CBA_MiscItem_ItemInfo;
    class ACRE_PRC152;

    class UKSF_PRC163_Battery: CBA_MiscItem {
        author = "UKSF Surplus";
        scope = 2;
        scopeArsenal = 2;
        displayName = "AN/PRC-163 Battery";
        descriptionShort = "Rechargeable battery for the AN/PRC-163 radio";
        picture = "\UKSF_PRC163\data\ui\prc163_battery_icon.paa";
        model = "\UKSF_PRC163\data\battery.p3d";

        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 8;
        };
    };

    class ACRE_PRC163: ACRE_PRC152 {
        displayName = "AN/PRC-163";
        useActionTitle = "AN/PRC-163";
        descriptionShort = "AN/PRC-163 Dual-Channel Multiband Radio";
        picture = "\UKSF_PRC163\data\ui\prc163_icon.paa";
        model = "\UKSF_PRC163\data\prc163.p3d";
        scope = 2;
        scopeCurator = 2;
        author = "UKSF Surplus";
        acre_hasUnique = 1;
        acre_isUnique = 0;

        class Library {
            libTextDesc = "AN/PRC-163";
        };
    };

    class ACRE_PRC163_ID_Base: ACRE_PRC163 {
        acre_hasUnique = 0;
        acre_isUnique = 1;
        acre_baseClass = "ACRE_PRC163";
        ace_arsenal_uniqueBase = "ACRE_PRC163";
        scope = 1;
        scopeCurator = 0;

        class Armory {
            disabled = 1;
        };
    };

    #include "CfgWeapons_IDs.hpp"
};
