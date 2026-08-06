class CfgVehicles
{
    class Man;
    class CAManBase: Man
    {
        class ACE_SelfActions
        {
            class UKSF_PRC163_Interact
            {
                displayName = "AN/PRC-163";
                condition = "(([_player] call acre_sys_core_fnc_getGear) findIf {(toLower _x) find 'acre_prc163_id_' isEqualTo 0}) >= 0";
                exceptions[] = {"isNotInside","isNotSitting"};
                statement = "";
                icon = "\UKSF_PRC163\data\ui\prc163_icon.paa";
                insertChildren = "_this call UKSF_PRC163_fnc_getInteractionChildren";
            };
        };
    };
    class Item_Base_F;
    class UKSF_PRC163_World: Item_Base_F
    {
        author = "UKSF Surplus";
        scope = 2;
        scopeCurator = 2;
        displayName = "AN/PRC-163";
        model = "\UKSF_PRC163\data\prc163.p3d";
        editorCategory = "EdCat_Things";
        editorSubcategory = "EdSubcat_InventoryItems";
        vehicleClass = "Items";
        class TransportItems
        {
            class _xx_ACRE_PRC163
            {
                name = "ACRE_PRC163";
                count = 1;
            };
        };
    };
    class UKSF_PRC163_Battery_World: Item_Base_F
    {
        author = "UKSF Surplus";
        scope = 2;
        scopeCurator = 2;
        displayName = "AN/PRC-163 Battery";
        model = "\UKSF_PRC163\data\battery.p3d";
        editorCategory = "EdCat_Things";
        editorSubcategory = "EdSubcat_InventoryItems";
        vehicleClass = "Items";
        class TransportItems
        {
            class _xx_UKSF_PRC163_Battery
            {
                name = "UKSF_PRC163_Battery";
                count = 1;
            };
        };
    };
};
