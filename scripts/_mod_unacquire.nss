//::///////////////////////////////////////////////
//:: v2_mod_unacquire
//:://////////////////////////////////////////////
/*
    Put into: OnItemUnAcquire Event

    Modified XP2 OnItemUnAcquireScript: x2_mod_def_unaqu
    (c) 2003 Bioware Corp.

    Custom Modifications added:

*/
//:://////////////////////////////////////////////
//:: Created: Georg Zoeller (2003-07-16)
//:: Modified: henesua (2015 dec 24) for setting up hills edge


// Bioware Includes
#include "x2_inc_switches"

#include "_inc_corpse"   // for CorpseItemDropped
#include "_inc_spells"
#include "_inc_light"
//#include "v2_inc_time"

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
void doPlaceableItem(object oItem, object oLoser);
void doPlaceableItem(object oItem, object oLoser)
{
  // if location is valid then item was dropped in area
  location lLoc     = GetLocation(oItem);
  vector vLoc       = GetPositionFromLocation(lLoc);
  object oAreaItem  = GetAreaFromLocation(lLoc);
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

void main()
{
    object oItem        = GetModuleItemLost();
    if(!GetIsObjectValid(oItem))
    {
        // item destroyed
        return;
    }

    object oLoser       = GetModuleItemLostBy();

    int nBaseItem       = GetBaseItemType(oItem);
    //int nGPValue        = GetGoldPieceValue(oItem);
    string sTag         = GetTag(oItem);

    //SendMessageToPC(GetFirstPC(), RED+"Unacquire: Loser("+GetName(oLoser)+") Item("+GetName(oItem)+")");
     // Set this here so all other called scripts can use it.
     SetUserDefinedItemEventNumber(X2_ITEM_EVENT_UNACQUIRE);
     
     // PW bookkeeping - this is not a bug - same script handles both acquire and unacquire.
     ExecuteScript("pw_mod_aqu", OBJECT_SELF);
     
     // CPP unacquire fixes - meaglyn: this is not currently in he.
     //ExecuteScript("70_mod_unaqu", OBJECT_SELF);
        
    if(GetLocalInt(oItem, "OOC_ITEM")&&!IsOOC(oLoser))
        DestroyObject(oItem);
    // is this a corpse?
    else if(GetLocalString(oItem,"CORPSE_PCID")!="")
    {
        // if location is valid then item was dropped in area
        location lLoc     = GetLocation(oItem);
        object oAreaItem  = GetAreaFromLocation(lLoc);

        if(GetIsObjectValid(oAreaItem))
        {
            CorpseItemDropped(oLoser, oItem, lLoc);
        }
    }
    // items unidentified - herbs, scrolls, potions, wands, rods, and staves
    else if(    nBaseItem==BASE_ITEM_HERBS   ||
                nBaseItem==BASE_ITEM_SPELLSCROLL || nBaseItem==BASE_ITEM_ENCHANTED_SCROLL ||
                nBaseItem==BASE_ITEM_POTIONS     || nBaseItem==BASE_ITEM_ENCHANTED_POTION ||
                nBaseItem==BASE_ITEM_MAGICWAND   || nBaseItem==BASE_ITEM_ENCHANTED_WAND   ||
                nBaseItem==BASE_ITEM_MAGICROD    ||
                nBaseItem==BASE_ITEM_MAGICSTAFF  ||
                nBaseItem==BASE_ITEM_KEY
    )
    {
        if(GetIdentified(oItem)) // player remembers how to use item
        {
            SetLocalInt(oLoser,"IDENTIFIED_"+ObjectToString(oItem),TRUE);
            SetLocalString(oLoser, "DESCRIPTION_"+ObjectToString(oItem), GetDescription(oItem));
        }

        SetIdentified(oItem, FALSE); // item unidentified for others

        if( nBaseItem==BASE_ITEM_HERBS ||
            nBaseItem==BASE_ITEM_KEY
          )
            SetDescription(oItem, ""); // wipe out information
    }

    // traces left behind for a ranger
    if(     !GetHasFeat(FEAT_TRACKLESS_STEP,oLoser)
        &&  !GetHasSpellEffect(SPELL_PASS_WITH_NO_TRACE, oLoser)
      )
    {
        SetLocalInt(oItem,"TRACKS", TRUE);
        SetLocalInt(oItem,"TRACKS_TIME",GetTimeCumulative(TIME_HOURS));
        SetLocalObject(oItem,"TRACKS_ID",oLoser);
        SetLocalInt(oItem,"TRACKS_RACE",GetRacialType(oLoser));
        SetLocalInt(oItem,"TRACKS_GENDER",GetGender(oLoser));
    }
    // ranger
    else
    {
        DeleteLocalInt(oItem,"TRACKS");
        DeleteLocalInt(oItem,"TRACKS_TIME");
        DeleteLocalObject(oItem,"TRACKS_ID");
        DeleteLocalInt(oItem,"TRACKS_RACE");
        DeleteLocalInt(oItem,"TRACKS_GENDER");
    }
    // PLACEABLE_ITEM_RESREF
    // items that become placeables when dropped
    if (GetLocalString(oItem, PLACEABLE_ITEM_RESREF) != "")
        doPlaceableItem(oItem,oLoser);


     // meaglyn: no tag based scripting?? Re-added but commented out for now
      // * Generic Item Script Execution Code
        // * If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
        // * it will execute a script that has the same name as the item's tag
        // * inside this script you can manage scripts for all events by checking against
        // * GetUserDefinedItemEventNumber(). See x2_it_example.nss
        /*
        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS)) {
                int nRet =   ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oItem),OBJECT_SELF);
                if (nRet == X2_EXECUTE_SCRIPT_END) {
                        return;
                }
        }
        */
}