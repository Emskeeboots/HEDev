//::///////////////////////////////////////////////
//:: _mod_unequip
//:://////////////////////////////////////////////
/*
    Modified XP2 OnItemEquipped - script: x2_mod_def_unequ
    (c) 2003 Bioware Corp.
    Put into: OnUnEquip Event

    Community Content used:

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller (2003-07-16)
//:: Modified: Deva Winblood (April 15th, 2008)
//::           - Added Support for Mounted Archery Feat penalties
//:: Modified: henesua (2015 dec 30) for setting up PW base mod
//:://////////////////////////////////////////////

// Bioware
#include "x2_inc_switches"
#include "x3_inc_horse"
#include "x2_inc_intweapon"

// Project Q
#include "q_inc_acp"

// The Magus's PW
#include "_inc_light"
#include "_inc_vfx"
//#include "_inc_creatures"


void doVFXUnequip(object oPC, object oItem, int nBaseItemType) {
        /////////////////// BODY PART BASED MODEL ///////////////////////////////////////////////
        if(GetAppearanceType(oPC)>6) return;

     //------------------------------------------------------------------------------
     //                           PROJECT Q CUSTOMIZATIONS
     //------------------------------------------------------------------------------

        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_DLA_DYNAMIC_QUIVERS)) {
                int nBaseItemType = GetBaseItemType(oItem);
                int nNeckPartId = GetLocalInt(oPC, "Q_NECK_PART_ID");

                if (nBaseItemType == BASE_ITEM_ARROW || nBaseItemType == BASE_ITEM_BOLT) {
                        if (GetCreatureBodyPart(CREATURE_PART_NECK, oPC) == 7) {
                                //Delete the stored neck value
                                DeleteLocalInt(oPC, "Q_NECK_PART_ID");

                                SetCreatureBodyPart(CREATURE_PART_NECK, nNeckPartId, oPC);
                        }
                } else if ((nBaseItemType == BASE_ITEM_HEAVYCROSSBOW ||
                      nBaseItemType == BASE_ITEM_LIGHTCROSSBOW ||
                      nBaseItemType == BASE_ITEM_LONGBOW ||
                      nBaseItemType == BASE_ITEM_SHORTBOW)
                && (GetItemInSlot(INVENTORY_SLOT_ARROWS, oPC) == OBJECT_INVALID &&
                      GetItemInSlot(INVENTORY_SLOT_BOLTS, oPC) == OBJECT_INVALID)) {
                        if (GetCreatureBodyPart(CREATURE_PART_NECK, oPC) == 7) {
                                //Delete the stored neck value
                                DeleteLocalInt(oPC, "Q_NECK_PART_ID");

                                SetCreatureBodyPart(CREATURE_PART_NECK, nNeckPartId, oPC);
                        }
                }
        }

    //hack for demonblade robe issue
        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_REQUIRE_DEMONBLADE_MULTIWEAPON)) {
                if (GetPhenoType(oPC) == 20) {
                        if (!GetCreatureFlag(oPC, CREATURE_FLAG_DEMONBLADE_MULTIWEAPON_OVERRIDE)) {
                                if (GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC) != OBJECT_INVALID) {
                                        int nBaseItemType = GetBaseItemType(oItem);
                                        if (nBaseItemType == BASE_ITEM_BASTARDSWORD ||
                                                nBaseItemType == BASE_ITEM_BATTLEAXE ||
                                                nBaseItemType == BASE_ITEM_CLUB ||
                                                nBaseItemType == BASE_ITEM_DAGGER ||
                                                nBaseItemType == BASE_ITEM_DART ||
                                                nBaseItemType == BASE_ITEM_DWARVENWARAXE ||
                                                nBaseItemType == BASE_ITEM_HANDAXE ||
                                                nBaseItemType == BASE_ITEM_HEAVYFLAIL ||
                                                nBaseItemType == BASE_ITEM_KAMA ||
                                                nBaseItemType == BASE_ITEM_KATANA ||
                                                nBaseItemType == BASE_ITEM_KUKRI ||
                                                nBaseItemType == BASE_ITEM_LIGHTFLAIL ||
                                                nBaseItemType == BASE_ITEM_LIGHTHAMMER ||
                                                nBaseItemType == BASE_ITEM_LIGHTMACE ||
                                                nBaseItemType == BASE_ITEM_LONGSWORD ||
                                                nBaseItemType == BASE_ITEM_MORNINGSTAR ||
                                                nBaseItemType == BASE_ITEM_RAPIER ||
                                                nBaseItemType == BASE_ITEM_SCIMITAR ||
                                                nBaseItemType == BASE_ITEM_SHORTSWORD ||
                                                nBaseItemType == BASE_ITEM_SICKLE ||
                                                nBaseItemType == BASE_ITEM_THROWINGAXE ||
                                                nBaseItemType == BASE_ITEM_WARHAMMER ||
                                                nBaseItemType == BASE_ITEM_WHIP ||
                                                nBaseItemType == BASE_ITEM_TORCH) {
                                                SendMessageToPC(oPC, "Secondary weapon unequipped, reverting to normal style...");
                                                Q_ACPCheckChat(oPC, "style normal");
                                        }
                                }
                        }
                }
        }

// requires integration with VFX and items

        if(     (nBaseItemType==BASE_ITEM_ARROW && GetItemInSlot(INVENTORY_SLOT_BOLTS, oPC)==OBJECT_INVALID)
                ||  (nBaseItemType==BASE_ITEM_BOLT && GetItemInSlot(INVENTORY_SLOT_ARROWS, oPC)==OBJECT_INVALID)) {
                int nRemove = BODY_EFFECTS_ARROWS;
                if(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC)==OBJECT_INVALID) nRemove += BODY_EFFECTS_QUIVER;

                RemovePersonalVFX(oPC, nRemove);
        } else if(nBaseItemType==BASE_ITEM_ARMOR) {
                if(     GetItemInSlot(INVENTORY_SLOT_BOLTS, oPC)==OBJECT_INVALID
                    &&  GetItemInSlot(INVENTORY_SLOT_ARROWS, oPC)==OBJECT_INVALID) {
                        RemovePersonalVFX(oPC, BODY_EFFECTS_QUIVER);
                }
        }

    // Rolo's/Cestus Dei's Torc base item creates a vfx of the torc around the neck
        else if(nBaseItemType==BASE_ITEM_TORC) {
                RemovePersonalVFX(oPC, BODY_EFFECTS_NECK);
        }
/*
    // some amulets show up around the neck. body part neck changes to accommodate
    else if( nBaseItemType==BASE_ITEM_AMULET )
    {
        if(GetLocalInt(oItem, "NECK_MODEL"))
        {
            SetCreatureBodyPart(CREATURE_PART_NECK, GetSkinInt(oPC, BASE_BODY_NECK), oPC);
            object oGarb    = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
            AssignCommand(oPC,ActionEquipItem(oGarb,INVENTORY_SLOT_CHEST));
        }
    }
*/
        else if( nBaseItemType==BASE_ITEM_SCARF) {
                RemovePersonalVFX(oPC, BODY_EFFECTS_SHOULDERS);
        }

}



void PCRequips(object oItem)
{
    ClearAllActions(TRUE);
    ActionEquipItem(oItem,INVENTORY_SLOT_RIGHTHAND);
}

void main() {
        object oItem    =   GetPCItemLastUnequipped();
        object oPC      =   GetPCItemLastUnequippedBy();
        string sTag     =   GetTag(oItem);
        int nBaseItemType = GetBaseItemType(oItem);
        int     bLight  =   GetItemHasItemProperty(oItem, ITEM_PROPERTY_LIGHT);

        if(GetLocalInt(oItem, "PLACEABLE_ITEM_EQUIP")) {
                DelayCommand(0.2, AssignCommand(oPC, PCRequips(oItem)) );
        }
    
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_UNEQUIP);
        ExecuteScript("sh_twexploit_eq",OBJECT_SELF);  

// LIGHT SYSTEM
    // determine if PC unequipped a light source
        if (bLight) {
                PCLostLight(oPC, oItem);
        }

// Bioware Begin
    // -------------------------------------------------------------------------
    //  Intelligent Weapon System
    // -------------------------------------------------------------------------
        if (IPGetIsIntelligentWeapon(oItem)) {
                IWSetIntelligentWeaponEquipped(oPC,OBJECT_INVALID);
                IWPlayRandomUnequipComment(oPC,oItem);
        }

    // -------------------------------------------------------------------------
    // Mounted benefits control
    // -------------------------------------------------------------------------
        if (GetWeaponRanged(oItem)) {
                DeleteLocalInt(oPC,"bX3_M_ARCHERY");
                HORSE_SupportAdjustMountedArcheryPenalty(oPC);
        }

        // This one runs as the module
        ExecuteScript("tb_armor_enc", OBJECT_SELF);


        // Pantheon favored weapons 
        // Use a delay here so that the weapon is actually unequipped before the deity weapon status is updated.
        DelayCommand(0.1, ExecuteScript("deity_onequip", oPC));

        doVFXUnequip(oPC, oItem, nBaseItemType);
   
        // -------------------------------------------------------------------------
        // Generic Item Script Execution Code
        // If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
        // it will execute a script that has the same name as the item's tag
        // inside this script you can manage scripts for all events by checking against
        // GetUserDefinedItemEventNumber(). See x2_it_example.nss
        // -------------------------------------------------------------------------
            //SetUserDefinedItemEventNumber(X2_ITEM_EVENT_UNEQUIP);
        string sScript;
        string sPre = GetTagPrefix(sTag);
        if(sPre!="")
            sScript = PREFIX + sPre;
        else
            sScript = GetUserDefinedItemEventScriptName(oItem);

        int nRet =   ExecuteScriptAndReturnInt(sScript,OBJECT_SELF);
        if (nRet == X2_EXECUTE_SCRIPT_END)
        {
           return;
        }
}
