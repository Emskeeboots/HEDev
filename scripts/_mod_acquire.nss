//::///////////////////////////////////////////////
//:: _mod_acquire
//:://////////////////////////////////////////////
/*
    Put into: OnItemUnAcquire Event

    Modified XP2 OnItemAcquireScript: x2_mod_def_aqu
    (c) 2003 Bioware Corp.

    Custom Modifications added:
    Wyldhunts - store-bought item fix   // 2012 mar 12
        Associated Scripts wyld_itemcreate, wyld_storeopen

*/
//:://////////////////////////////////////////////
//:: Created: Georg Zoeller (2003-07-16)
//:: Modified: henesua (2015 dec 24) setup for hills edge

// Bioware Includes
#include "x2_inc_switches"

#include "_inc_light"
#include "_inc_spells"
#include "_inc_util"

// DECLARATIONS ----------------------------------------------------------------


// IMPLEMENTATION --------------------------------------------------------------
// turns on a light vfx placeable for a dropped placeable lantern
void TurnLightOn();
void TurnLightOn()
{
    object oArea= GetArea(OBJECT_SELF);
    string sRef = GetLocalString(OBJECT_SELF, "LIGHT_REF");
    location lLoc= GetLocation(OBJECT_SELF);

    object oLight   = CreateObject(OBJECT_TYPE_PLACEABLE, sRef, lLoc);
    if(!GetIsObjectValid(oLight))
        oLight   = CreateObject(OBJECT_TYPE_PLACEABLE, "light_orange", lLoc);

    int nBrightness = GetLocalInt(OBJECT_SELF, "LIGHT_BRIGHTNESS");
    string sType    = GetLocalString(OBJECT_SELF, "LIGHTABLE_TYPE");

    SetLocalObject(OBJECT_SELF, "PAIRED", oLight);

    SetLocalInt(OBJECT_SELF,"NW_L_AMION",TRUE);

    DelayCommand(0.5, RecomputeStaticLighting(oArea));
}

// handles unAcquired Event for items which become placeables when dropped
void doPlaceableItem(object oItem, object oLoser, location lLoc);
void doPlaceableItem(object oItem, object oLoser, location lLoc)
{
  // if location is valid then item was dropped in area
  object oAreaItem  = GetAreaFromLocation(lLoc);
  if(!GetIsObjectValid(oAreaItem))
        lLoc     = GetLocation(oItem);
  vector vLoc       = GetPositionFromLocation(lLoc);

           lLoc     = Location(oAreaItem,Vector(vLoc.x, vLoc.y, vLoc.z-0.1), 90.0 );
  if(GetIsObjectValid(oAreaItem))
  {
    // gather data from item for transfer to placeable
    string sRefItem     = GetResRef(oItem);
    string sName        = GetName(oItem);
    string sDescription = GetDescription(oItem);
    string sTag         = GetTag(oItem);
    int bStolen         = GetStolenFlag(oItem);

    // special case - lightables
    int bLight          = GetLocalInt(oItem, "LIGHTABLE");
    string sLightType   = GetLocalString(oItem, "LIGHTABLE_TYPE");
    int iLightBrightness;
    int iBurningTickCount;
    int bLanternIsEmpty;
    if (bLight)
    {
        itemproperty ip =   GetFirstItemProperty(oItem);
        while ( GetIsItemPropertyValid(ip) )
        {
            if ( GetItemPropertyType(ip) == ITEM_PROPERTY_LIGHT )
            {
                int tmpBright   = GetItemPropertyCostTableValue(ip);
                if( iLightBrightness < tmpBright )
                    iLightBrightness = tmpBright;
            }
            //Next itemproperty on the list...
            ip = GetNextItemProperty(oItem);
        }

        iBurningTickCount   = GetLocalInt(oItem, "LIGHTABLE_BURNED_TICKS");
        bLanternIsEmpty     = GetLocalInt(oItem, "LIGHTABLE_LANTERN_EMPTY");
        if(bLanternIsEmpty)
            iLightBrightness = 0;
        else if (iLightBrightness == 0)
            iLightBrightness = 1;

        // can not light this underwater
        if(GetLocalString(oLoser,"UNDERWATER_ID")!="")
        {
            if(     sLightType=="torch"
                ||  sLightType=="candle"
                ||  sLightType=="lantern"
              )
            {
                    return;
            }
        }
    }

    // destroy item then create placeable
    DestroyObject(oItem);
    object oPlc     = CreateObject(OBJECT_TYPE_PLACEABLE, GetLocalString(oItem, PLACEABLE_ITEM_RESREF), lLoc, FALSE, sTag);
    float fFace     = GetFacing(oLoser);
    if(GetLocalInt(oPlc,"FLIP_FACING"))
    {
        if(fFace>180.0){fFace -= 180.0;}
        else           {fFace += 180.0;}
    }
    AssignCommand(oPlc, SetFacing(fFace));

    SetLocalInt(oPlc, "PLACEABLE_ITEM_STOLEN", bStolen);

    // transfer data to new object
    if(GetUseableFlag(oPlc))
    {
        SetName(oPlc, sName);
        SetDescription(oPlc, sDescription);
        SetLocalString(oPlc, PLACEABLE_ITEM_RESREF, sRefItem);
    }
    // Leave traces
    if(     !GetHasFeat(FEAT_TRACKLESS_STEP,oLoser)
      &&  !GetHasSpellEffect(SPELL_PASS_WITH_NO_TRACE, oLoser)
      )
    {
        SetLocalInt(oPlc,"TRACKS", TRUE);
        SetLocalInt(oPlc,"TRACKS_TIME",GetTimeCumulative(TIME_HOURS));
        SetLocalObject(oPlc,"TRACKS_ID",oLoser);
        SetLocalInt(oPlc,"TRACKS_RACE",GetRacialType(oLoser));
        SetLocalInt(oPlc,"TRACKS_GENDER",GetGender(oLoser));
    }

    // special case - lightables
    if(bLight)
    {
        SetLocalInt(oPlc, LIGHT_VALUE, iLightBrightness);
        SetLocalInt(oPlc, "LIGHTABLE_LANTERN_EMPTY", bLanternIsEmpty);
        SetLocalInt(oPlc, "LIGHTABLE_BURNED_TICKS", iBurningTickCount);
        SetLocalInt(oPlc, "LIGHTABLE", bLight);
        SetLocalString(oPlc, "LIGHTABLE_TYPE", sLightType);

        if(!bLanternIsEmpty)
        {
            if(sLightType=="lantern")
            {
                DelayCommand(   0.1,
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT,
                                EffectVisualEffect(VFX_DUR_LIGHT_GREY_15),
                                oPlc
                                )
                            );
                AssignCommand(oPlc, TurnLightOn());
            }
            else
                SetPlaceableIllumination(oPlc, TRUE);

            DelayCommand(0.5, RecomputeStaticLighting(oAreaItem));
        }
    }
  }
}

// the item can only be held... so we need to force drop it now
void DropPlaceableItem(object oItem, object oLoser);
void DropPlaceableItem(object oItem, object oLoser)
{
    location lLoc   = GetLocation(oLoser);
    if(GetLocalString(oItem, PLACEABLE_ITEM_RESREF) != "")
        doPlaceableItem(oItem, oLoser, lLoc);
    else
    {
        object oNew =CreateObject(OBJECT_TYPE_ITEM,GetResRef(oItem),lLoc,FALSE,GetTag(oItem));
        SetName(oNew,GetName(oItem));
        SetDescription(oNew,GetName(oItem));
        SetStolenFlag(oNew,GetStolenFlag(oItem));
        DestroyObject(oItem);
    }
}

// MAIN ------------------------------------------------------------------------
void main()
{
    object oItem    = GetModuleItemAcquired();
    int nBaseItem   = GetBaseItemType(oItem);

    object oPC      = GetModuleItemAcquiredBy();
    object oArea    = GetArea(oPC);
    //int nGPValue    = GetGoldPieceValue(oItem);
    object oFrom    = GetModuleItemAcquiredFrom();
    string sTag     = GetTag(oItem);

    string sPreOwned = "PreOwned";

    // ignore creature items/hides etc...
    if(nBaseItem==BASE_ITEM_CREATUREITEM)
        return;

    if(GetIsPC(oPC))
    {
        if(GetResRef(oItem)=="x2_it_emptyskin")
        {
            DestroyObject(oItem);
            return;
        }
    }

  if(!MODULE_NWNX_MODE)// BEGIN wyldhunt store-bought item fix ------------------------------------
  { if(    GetObjectType(oFrom) == OBJECT_TYPE_STORE
        && FindSubString(sTag, "_novars")==-1
      )
    {
        string sTemplate= GetResRef(oItem);
        int nStack      = GetModuleItemAcquiredStackSize();
        int nNewStack;

        SetLocalObject(oPC, "BaseStore", oFrom);
        // Player has purchased an item from a store.
        // Sanity check to ensure that the store is set up.
        if (!GetLocalInt(oFrom, "InfiniteItemCheck"))
        {
            ExecuteScript("wyld_itemcreate", oPC);
        }
        if (    !GetLocalInt(oItem, sPreOwned)
            &&  (GetLocalInt(oFrom, sTemplate+"Infinite")
            &&  GetLocalString(oFrom, sTemplate+"Tag") == sTag))
        {
            SetLocalString(oPC, "ItemAcquired", sTemplate);
            SetLocalInt(oPC, "ItemStack", nStack);
            nNewStack = GetNumStackedItems(oItem);
            if (nStack != nNewStack)
            {
                if (nStack < nNewStack)
                {
                    SetItemStackSize(oItem, nNewStack - nStack);
                }
                else
                {
                    nStack -= nNewStack;
                    DestroyObject(oItem);
                    object oNewItem = GetFirstItemInInventory(oPC);
                    while (GetIsObjectValid(oNewItem))
                    {
                        if (GetTag(oNewItem) == sTag && GetResRef(oNewItem) == sTemplate)
                        {
                            nNewStack = GetItemStackSize(oNewItem);
                            if (nStack < nNewStack)
                            {
                                SetItemStackSize(oNewItem, nNewStack - nStack);
                                nStack -= nNewStack;
                                if (nStack < 1)
                                {
                                    nStack = 0;
                                    DestroyObject(oItem);
                                    oItem = oNewItem;
                                    break;
                                }
                            }
                        }
                        oNewItem = GetNextItemInInventory(oPC);
                    }
                }
            }
            else
            {
                DestroyObject(oItem);
            }
            DelayCommand(0.1, ExecuteScript("wyld_itemcreate", oPC));
        }
    }

    // this would be a good place to put an OOC item acquisition loop if we need it

    if (!GetIsObjectValid(oItem)) return;
    SetLocalInt(oItem, sPreOwned, TRUE);
    // END wyldhunt store-bought item fix --------------------------------------
   } // end NWNX exclusion

    // Set this here so all other called scripts can use it.
    SetUserDefinedItemEventNumber(X2_ITEM_EVENT_ACQUIRE);

    // Clean this up when picked up - should be set by death code. 
    DeleteLocalInt(oItem, "ITEM_PC_DROP");

    if(GetLocalInt(oItem, "PLACEABLE_ITEM_EQUIP"))
    {
        object oEquipped    = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
        if(GetLocalInt(oEquipped, "PLACEABLE_ITEM_EQUIP"))
            DropPlaceableItem(oEquipped, oPC);

        AssignCommand(oPC, ActionEquipItem(oItem,INVENTORY_SLOT_RIGHTHAND) );
    }
    // Perishables are time stamped when picked up for the first time
    if( GetLocalInt(oItem,"PERISHABLE") && !GetLocalInt(oItem,"PERISHABLE_TIME") )
    {
        int nPerishable = GetLocalInt(oItem,"PERISHABLE");
        SetLocalInt(oItem,"PERISHABLE_TIME",GetTimeCumulative()+(60*nPerishable));
    }

     // 1.71 crafting exploit fix - set by x2_im_cancel.nss - cancel from default crafting convo
     if(GetLocalInt(oItem,"DUPLICATED_ITEM")) {
        DestroyObject(oItem);
        return;
     }

     // PW bookkeeping
     ExecuteScript("pw_mod_aqu", OBJECT_SELF);

    // Check for unidentified items
    if(!GetIdentified(oItem))
    {
        // Formerly identified Items are re-identified
        if( GetLocalInt(oPC,"IDENTIFIED_"+ObjectToString(oItem)) )
        {
            SetIdentified(oItem, TRUE);
            SetDescription(oItem, GetLocalString(oPC,"DESCRIPTION_"+ObjectToString(oItem)));
        }
        // Herbs
        else if( nBaseItem==BASE_ITEM_HERBS )
        {
            if( GetLevelByClass(CLASS_TYPE_DRUID,oPC) )
            {
                // druids can always identify plants
                SetIdentified(oItem,TRUE);
                SendMessageToPC(oPC, " ");
                SendMessageToPC(oPC, LIGHTBLUE+"As a druid, you are able to immediately identify the plant. "+GetDescription(oItem) );
            }
        }
    }

        // meaglyn: no tag based scripting?? Re-added but commented out for now
     // * Generic Item Script Execution Code
     // * If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
     // * it will execute a script that has the same name as the item's tag
     // * inside this script you can manage scripts for all events by checking against
     // * GetUserDefinedItemEventNumber(). See x2_it_example.nss
     /*
        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS)) {
         //SetUserDefinedItemEventNumber(X2_ITEM_EVENT_ACQUIRE);
                int nRet =   ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oItem),OBJECT_SELF);
                if (nRet == X2_EXECUTE_SCRIPT_END) {
                        return;
                }
        }
        */
}
