//::///////////////////////////////////////////////
//:: _mod_equip
//:://////////////////////////////////////////////
/*
    Modified XP2 OnItemEquipped - script: x2_mod_def_equ
    Put into: OnEquip Event

    Community Content used:


*/
//:://////////////////////////////////////////////
//:: Created: Georg Zoeller (2003-07-16)
//:: Modified: Deva Winblood (April 15th, 2008)
//::           - Added Support for Mounted Archery Feat penalties
//:: Modified: henesua (2015 dec 30) for setting up PW base mod
//:://////////////////////////////////////////////

// Bioware
#include "x2_inc_switches"
#include "x2_inc_intweapon"
#include "x3_inc_horse"

// Project Q
#include "q_inc_acp"

//
//#include "_inc_constants"
#include "_inc_light"
//#include "_inc_util"
#include "_inc_vfx"
//#include "_inc_creatures"


void doVFXEquip(object oPC, object oItem, int nBaseItemType) {
        if(GetAppearanceType(oPC) > 6)  return;

//------------------------------------------------------------------------------
//                           PROJECT Q CUSTOMIZATIONS
//------------------------------------------------------------------------------

        // -------------------------------------------------------------------------
        // DLA Dynamic Quivers
        // -------------------------------------------------------------------------
        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_DLA_DYNAMIC_QUIVERS)) {
        //Only add quiver if a cloak is not equipped
                if (GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC) == OBJECT_INVALID) {
                       int nBaseItemType = GetBaseItemType(oItem);
                       int nNeckPartId = GetCreatureBodyPart(CREATURE_PART_NECK, oPC);

                       if (nBaseItemType == BASE_ITEM_ARROW ||
                        nBaseItemType == BASE_ITEM_BOLT ||
                        nBaseItemType == BASE_ITEM_HEAVYCROSSBOW ||
                        nBaseItemType == BASE_ITEM_LIGHTCROSSBOW ||
                        nBaseItemType == BASE_ITEM_LONGBOW ||
                        nBaseItemType == BASE_ITEM_SHORTBOW) {
                                if (nNeckPartId != 7) {
                                       //Store the original neck value
                                       SetLocalInt(oPC, "Q_NECK_PART_ID", nNeckPartId);

                                       SetCreatureBodyPart(CREATURE_PART_NECK, 7, oPC);
                               }
                       }
               }

        //Remove quiver if a cloak is equipped
                if (GetBaseItemType(oItem) == BASE_ITEM_CLOAK) {
                        if (GetCreatureBodyPart(CREATURE_PART_NECK, oPC) == 7) {
                                int nNeckPartId = GetLocalInt(oPC, "Q_NECK_PART_ID");
                                SetCreatureBodyPart(CREATURE_PART_NECK, nNeckPartId, oPC);

                                //Delete the stored neck value
                                DeleteLocalInt(oPC, "Q_NECK_PART_ID");
                        }
                }
        }

// ALL THIS STUFF REQUIRES SPECIAL INMTEGRATION WITH VFX AND BASE ITEMS ETC..............
// Magus - do not allow players with horns to equip helmets
        if(nBaseItemType==BASE_ITEM_HELMET) {
                if (GetSkinInt(oPC, "VFX_TYPE_"+IntToString(HEAD_EFFECTS_HORNS)) && !GetLocalInt(oItem, "HORNS_OK")) {
                        ActionUnequipItem(oItem);
                        DelayCommand(1.5, FloatingTextStringOnCreature(RED+"That headgear is incompatible with your horns.",oPC,FALSE));
                } else {
                        RemovePersonalVFX(oPC, HEAD_EFFECTS_MASK); // remove mask effect
                }
        } else if(nBaseItemType==BASE_ITEM_TORC) {
        // Rolo's/Cestus Dei's Torc base item creates a vfx of the torc around the neck
                int nTorc   = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, TRUE);
        //SendMessageToPC(oPC, "Torc("+IntToString(nTorc)+")");
                if(nTorc==1) ApplyPersonalVFX(oPC, BODY_EFFECTS_NECK, NECK_TORC_00);
                else if(nTorc==2) ApplyPersonalVFX(oPC, BODY_EFFECTS_NECK, NECK_TORC_01);
                else if(nTorc==3) ApplyPersonalVFX(oPC, BODY_EFFECTS_NECK, NECK_TORC_02);
                else ApplyPersonalVFX(oPC, BODY_EFFECTS_NECK, NECK_TORC_00);
        }
/*
    // some amulets show up around the neck. this changes the body neck model while worn.
    else if( nBaseItemType==BASE_ITEM_AMULET )
    {
        int nAmuletNeck = GetLocalInt(oItem, "NECK_MODEL");
        if(nAmuletNeck)
        {
            if(!GetSkinInt(oPC, BASE_BODY_NECK))
                SetSkinInt(oPC, BASE_BODY_NECK, GetCreatureBodyPart(CREATURE_PART_NECK, oPC));
            SetCreatureBodyPart(CREATURE_PART_NECK, nAmuletNeck, oPC);
            object oGarb    = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
            AssignCommand(oPC,ActionEquipItem(oGarb,INVENTORY_SLOT_CHEST));
        }
    }
*/
        else if( nBaseItemType==BASE_ITEM_ARROW || nBaseItemType==BASE_ITEM_BOLT ) {
                // Values for nVFXColor
                // Grey    0   // quiver only
                // Brown   1
                // White   2
                // Black   3
                // Red     4
                // Yellow  5
                // Green   6
                // Aqua    7
                // Blue    8
                // Purple  9
                // Orange  10  //arrows only
                int nVFXColor   = GetArrowColorFromTag(GetTag(oItem));

                int nVFXQuiver  = GetSkinInt(oPC, "VFX_TYPE_"+IntToString(BODY_EFFECTS_QUIVER));
                if(!nVFXQuiver) {
                        ApplyPersonalVFX(oPC, BODY_EFFECTS_QUIVER, BODY_QUIVER);
                }

        // if no color is embedded in the tag of the arrow
        // use color of feathers on item
                if(!nVFXColor) {
                        int nArrowColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM);
                        //SendMessageToPC(oPC, "Arrow/Bolt Color("+IntToString(nArrowColor)+")");
                        if(nArrowColor==1) {
                                if(nBaseItemType==BASE_ITEM_ARROW) nVFXColor   = 8;
                                else nVFXColor   = 1;
                        } else if(nArrowColor==2) {
                                if(nBaseItemType==BASE_ITEM_ARROW) nVFXColor   = 1;
                                else nVFXColor   = 2;
                        } else if(nArrowColor==3) {
                                nVFXColor   = 4;
                        } else if(nArrowColor==4) {
                                if(nBaseItemType==BASE_ITEM_ARROW) nVFXColor   = 2;
                                else nVFXColor   = 3;
                        }
                }

                ApplyPersonalVFX(oPC, BODY_EFFECTS_ARROWS, BODY_ARROWS, nVFXColor);
        } else if( nBaseItemType==BASE_ITEM_SCARF) {
                int nScarf  = GetLocalInt(oItem, "VFX_INDEX");
                ApplyPersonalVFX(oPC, BODY_EFFECTS_SHOULDERS, nScarf);
        }
}

void doLightEquip(object oPC, object oItem, int nBaseItemType) {
        int     iLightBrightness = 0;
        if(!GetLocalInt(oItem, "LIGHTABLE_LANTERN_EMPTY")  
                || GetHasSpellEffect(SPELL_CONTINUAL_FLAME, oItem)
                || GetHasSpellEffect(SPELL_LIGHT, oItem)) {

        // Initialize Torch for KMDS system
                if( nBaseItemType==BASE_ITEM_TORCH ) {
            // are we underwater?
                        if(GetLocalString(oPC,"UNDERWATER_ID")!="") {
                                if( !GetHasSpellEffect(SPELL_CONTINUAL_FLAME, oItem) ) {
                                        SendMessageToPC(oPC, RED+"The "+GetName(oItem)+" is ruined underwater!");
                                        DestroyObject(oItem);
                                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_BUBBLES), oPC, 3.0);
                                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1677), oPC);
                                        return;
                                }
                        }

                        InitializeTorch(oItem, GetResRef(oItem));
                }

                itemproperty ip = GetFirstItemProperty(oItem);
                while ( GetIsItemPropertyValid(ip) ) {
                        if ( GetItemPropertyType(ip) == ITEM_PROPERTY_LIGHT ) {
                                if( iLightBrightness < GetItemPropertyCostTableValue(ip) ) {
                                        iLightBrightness = GetItemPropertyCostTableValue(ip);
                                }
                        }

            //Next itemproperty on the list...
                       ip = GetNextItemProperty(oItem);
                }

                if(GetLocalInt(oPC, LIGHT_VALUE)<iLightBrightness) {
                        SetLocalInt(oPC, LIGHT_VALUE,iLightBrightness);
                }

        } else { // Empty Lantern that lacks a light spell, remove all light properties
                itemproperty ip = GetFirstItemProperty(oItem);
                while ( GetIsItemPropertyValid(ip) ) {
                       if ( GetItemPropertyType(ip)==ITEM_PROPERTY_LIGHT ) RemoveItemProperty(oItem, ip); // remove light

            //Next itemproperty on the list...
                        ip = GetNextItemProperty(oItem);
                }
                object oArea = GetArea(oPC);
                AssignCommand(oArea, DelayCommand(0.25, RecomputeStaticLighting(oArea)) );
        }
}

void main()
{
    object  oItem   =   GetPCItemLastEquipped();
    object  oPC     =   GetPCItemLastEquippedBy();
    object oArea    =   GetArea(oPC);
    string sRef     =   GetResRef(oItem);
    string sTag     =   GetTag(oItem);
    int nBaseItemType = GetBaseItemType(oItem);

    // do we need to restore a creature from polymorph?
    if(     nBaseItemType==BASE_ITEM_CREATUREITEM
        &&  CreatureGetIsPolymorphed(oPC)
        &&  !GetHasEffect(EFFECT_TYPE_POLYMORPH,oPC)
      )
    {
        CreatureRestoreFromPolymorph(oPC);
    }
    
    SetUserDefinedItemEventNumber(X2_ITEM_EVENT_EQUIP);
    ExecuteScript("sh_twexploit_eq",OBJECT_SELF);  


    // LIGHT SYSTEM
    // TODO - not sure this works - do continual flame and light add item props? 
    int     bLight  =   GetItemHasItemProperty(oItem, ITEM_PROPERTY_LIGHT);
    // flag player with brightness of brightest equipped light source
    if (bLight) {
        doLightEquip(oPC, oItem, nBaseItemType);
    }
    // END LIGHT SYSTEM

// Bioware begin
    // -------------------------------------------------------------------------
    // Intelligent Weapon System
    // -------------------------------------------------------------------------
    if (IPGetIsIntelligentWeapon(oItem))
    {
        IWSetIntelligentWeaponEquipped(oPC,oItem);
        // prevent players from reequipping their weapon in
        if (IWGetIsInIntelligentWeaponConversation(oPC))
        {
                object oConv =   GetLocalObject(oPC,"X2_O_INTWEAPON_SPIRIT");
                IWEndIntelligentWeaponConversation(oConv, oPC);
        }
        else
        {
            //------------------------------------------------------------------
            // Trigger Drain Health Event
            //------------------------------------------------------------------
            if (GetLocalInt(oPC,"X2_L_ENSERRIC_ASKED_Q3")==1)
            {
                ExecuteScript ("x2_ens_dodrain",oPC);
            }
            else
            {
                IWPlayRandomEquipComment(oPC,oItem);
            }
        }
    }

    // -------------------------------------------------------------------------
    // Mounted benefits control
    // -------------------------------------------------------------------------
    if (GetWeaponRanged(oItem))
    {
        SetLocalInt(oPC,"bX3_M_ARCHERY",TRUE);
        HORSE_SupportAdjustMountedArcheryPenalty(oPC);
    }

        // -------------------------------------------------------------------------
        // Check for Use Limitation: Gender
        // -------------------------------------------------------------------------
        if (GetItemHasItemProperty(oItem, 88 /*ITEM_PROPERTY_USE_LIMITATION_GENDER*/)) {
                itemproperty ipGenderProperty = GetFirstItemProperty(oItem);

                while ((GetIsItemPropertyValid(ipGenderProperty)) 
                        && (GetItemPropertyType(ipGenderProperty) != 88 /*ITEM_PROPERTY_USE_LIMITATION_GENDER*/)) {
                        ipGenderProperty=GetNextItemProperty(oItem);
                }
        //If itemproperty is INVALID exit function
                if (GetIsItemPropertyValid(ipGenderProperty)) {
                        if (GetItemPropertySubType(ipGenderProperty)!=GetGender(oPC)) {
                       //Not equal, so take it off if equipped!
                                AssignCommand(oPC, ActionUnequipItem(oItem));

                                //Tell PC why.
                                SendMessageToPC(oPC, "You cannot use this item because of it's gender restriction.");
                        }
                }
        }

        // This one runs as the module still
        ExecuteScript("tb_armor_enc", OBJECT_SELF);


        // Pantheon favored weapons  - run as PC
        ExecuteScript("deity_onequip", oPC);

        doVFXEquip(oPC, oItem, nBaseItemType);
        
        // -------------------------------------------------------------------------
        // Generic Item Script Execution Code
        // If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
        // it will execute a script that has the same name as the item's tag
        // inside this script you can manage scripts for all events by checking against
        // GetUserDefinedItemEventNumber(). See x2_it_example.nss
        // -------------------------------------------------------------------------
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
