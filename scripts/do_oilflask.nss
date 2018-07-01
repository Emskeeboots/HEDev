/*::////////////////////////////////////////////////////////////////////////////
//:: Name: KMdS PNP Hard Core Rule Set 1.0
//:: System: KMdS AD&D Lantern and Light System
//:: FileName do_oilflask.nss
//:: Copyright (c) 2006 Michael Careaga
//::////////////////////////////////////////////////////////////////////////////

    This is script may be tag based or called from the modules "On Activate"
    event script using the "ExecuteScript" function.  For tag based activation,
    you must have an item with the tag "OILFLASK" that has the item property
    "Unique Spell" with unlimited uses.

    The use of the oilflask will refuel a lantern and only use the oil needed
    so that a player may "top off" their lantern periodically as desired.  Once
    the oil flasks oil has been used up, the flask is destroyed.

    See KMdS_LightSource.nss for more info.

//::////////////////////////////////////////////////////////////////////////////
//:: Created: KMdS aka Kilr Mik d Spik 19/07/2006
//:: Modified: The Magus (2011 Feb 28) - setting up for proper tag based script
//:: Modified: The Magus (2012 may 5) - grenade action
//:://////////////////////////////////////////////////////////////////////////*/

//  ----------------------------------------------------------------------------
//  LIBRARY
//  ----------------------------------------------------------------------------

#include "x2_inc_switches"
//#include"kmds_lightsource"
#include "_inc_light"
//#include "_inc_constants"
//#include "_inc_util"

/*//////////////////////////////////////////////////////////////////////////////
Uncomment the following line if you wish to use item properties to remove the
light properties from lanterns when out of oil for more realistic lanterns.
//////////////////////////////////////////////////////////////////////////////*/
#include "x2_inc_itemprop"


// if DoGrenade is wanted
#include "X0_I0_SPELLS"

// DECLARATION

int DoOilSplash(int nOil, location lTarget, object oTarget=OBJECT_INVALID);

// IMPLEMENTED -----------------------------------------------------------------

int DoOilSplash(int nOil, location lTarget, object oOrigin)
{
    int nSize, nType, bHit, nApplied;
    float fRadius   = 5.0;
    int nOilPart    = FloatToInt(nOil/9.0);
    if(nOilPart<1)
        nOilPart    = 1;

    vector vOrigin  = GetPosition(oOrigin);
    object oHit     = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, vOrigin);

    while(GetIsObjectValid(oHit) && nOil)
    {
        bHit    = 0;
        nSize   = 0;
        nApplied= 0;
        nType   = GetObjectType(oHit);
        if(nType==OBJECT_TYPE_CREATURE)
        {
            if( !GetCreatureFlag(oHit, CREATURE_VAR_IS_INCORPOREAL) )
            {
                nSize   = GetCreatureSize(oHit);
                if( !GetHasSpellEffect(SPELL_SHIELD, oHit) )
                    bHit    = TRUE;
            }
        }
        else if(nType==OBJECT_TYPE_PLACEABLE)
        {
            nSize   = 3;
            if(GetUseableFlag(oHit)&&!GetPlotFlag(oHit))
                bHit    = TRUE;
        }
        else if(nType==OBJECT_TYPE_DOOR)
        {
            nSize   = 4;
            if(GetIsDoorActionPossible(oHit,DOOR_ACTION_BASH)&&!GetPlotFlag(oHit))
                bHit    = TRUE;
        }

        nApplied    = nSize*nOilPart;
        if(nApplied)
        {
            if( nApplied > nOil)
                nApplied = nOil;
            nOil    -= nApplied;
            if(bHit)
            {
                if(GetTag(oHit)!="oil")
                    AssignCommand(oHit, SpeakString("*Doused in oil*", TALKVOLUME_TALK));
                SetLocalInt(oHit, "OIL_AMOUNT", GetLocalInt(oHit, "OIL_AMOUNT")+nApplied);
            }
        }

        oHit        = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, vOrigin);
    }
    return nOil;
}

//  ----------------------------------------------------------------------------
//  MAIN
//  ----------------------------------------------------------------------------
void main()
{
 // BEGIN Event Activate
 if (GetUserDefinedItemEventNumber()==X2_ITEM_EVENT_ACTIVATE)
 {
    object oPC              = GetItemActivator();
    object oOilFlask        = GetItemActivated();
    int nOilInFlask         = GetLocalInt(oOilFlask,"OIL_AMOUNT");
    object oTarget          = GetItemActivatedTarget();
    int nTargetType         = GetObjectType(oTarget);
    location lWhere         = GetItemActivatedTargetLocation();

    int nLanternBurntime    = MAX_LANTERN_HB;
    int nTimeOn             = GetLocalInt(oTarget,"LIGHTABLE_BURNED_TICKS");
    string sAmountRefilled;

    // lantern
    if(GetLocalString(oTarget,"LIGHTABLE_TYPE")=="lantern")
    {
        // Trying to use on a lantern that is too far away....mainly for use on placeables.
        if(GetDistanceBetweenLocations(GetLocation(oPC), lWhere) > 3.0)
        {
            SendMessageToPC(oPC,GREY+MOVECLOSER);
            return;
        }

        // A full flask that has never been used...set up the variable for the amount of oil in the flask.
        if(!nOilInFlask)
        {
            SetLocalInt(oOilFlask, "OIL_AMOUNT", nLanternBurntime);
            nOilInFlask = nLanternBurntime;
        }

        // A full lantern.  No oil needed.
        if(!nTimeOn)
        {
            SendMessageToPC(oPC, GREY+"Your lantern is full and needs no oil.");
        }

        // The time the lanten has been on is less than the oil in the flask.
        else if(nTimeOn < nOilInFlask)
        {
            SetLocalInt(oTarget,"LIGHTABLE_BURNED_TICKS", 0);
            SetLocalInt(oOilFlask, "OIL_AMOUNT", nOilInFlask - nTimeOn);
            SendMessageToPC(oPC, GREY+FULLREFILL);
        }

        // The time the lantern has been on is equal or greater than the burntime allowed.
        else if(nTimeOn >= nLanternBurntime)
        {
            SetLocalInt(oTarget,"LIGHTABLE_BURNED_TICKS", nLanternBurntime - nOilInFlask);
            DestroyObject(oOilFlask);
            sAmountRefilled = PARTIALREFILL;
            if(nOilInFlask == nLanternBurntime)
                sAmountRefilled = FULLREFILLLOSEFLASK;

            /*//////////////////////////////////////////////////////////////////////////////
            Uncomment the following lines if you wish to use item properties to remove the
            light properties from lanterns when out of oil
            //////////////////////////////////////////////////////////////////////////////*/
            itemproperty ipAdd = ItemPropertyLight(IP_CONST_LIGHTBRIGHTNESS_NORMAL, IP_CONST_LIGHTCOLOR_GREEN);
            IPSafeAddItemProperty(oTarget, ipAdd);
            ////////////////////////////////////////////////////////////////////////////////

            SetLocalInt(oTarget, "LIGHTABLE_LANTERN_EMPTY", FALSE);
            SendMessageToPC(oPC, GREY+sAmountRefilled);
        }
        // The time the lantern has been on is equal or greater than the Oil in the flask.
        else if(nTimeOn >= nOilInFlask)
        {
            SetLocalInt(oTarget,"LIGHTABLE_BURNED_TICKS", nTimeOn - nOilInFlask);
            DestroyObject(oOilFlask);
            sAmountRefilled = PARTIALREFILL;
            if(nOilInFlask == nTimeOn)
                sAmountRefilled = FULLREFILLLOSEFLASK;
            SendMessageToPC(oPC, GREY+sAmountRefilled);
        }
    }
    /*
    // Target is a door or placeable or creature
    else if(    nTargetType==OBJECT_TYPE_DOOR
            ||  nTargetType==OBJECT_TYPE_PLACEABLE
            ||  nTargetType==OBJECT_TYPE_CREATURE
           )
    {
        int nTouch  = TouchAttackRanged(oTarget,TRUE);
        int bIncorp = GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL);
        if(nTouch==2 && !bIncorp)
        {// critical hit
            if(nTargetType==OBJECT_TYPE_CREATURE)
                SignalEvent(oTarget, EventUserDefined(EVENT_ATTACKED) );
            AssignCommand(oTarget, SpeakString("*Doused in oil*", TALKVOLUME_TALK));
            int nOil    = GetLocalInt(oTarget, "OIL_AMOUNT");
            int nDouse  = FloatToInt(nOilInFlask*0.90);
            SetLocalInt(oTarget, "OIL_AMOUNT", nOil+nDouse);
            nOilInFlask = nOilInFlask - nDouse;
        }
        else if(nTouch==1 && !bIncorp)
        {// normal hit
            if(nTargetType==OBJECT_TYPE_CREATURE)
                SignalEvent(oTarget, EventUserDefined(EVENT_ATTACKED) );
            AssignCommand(oTarget, SpeakString("*Doused in oil*", TALKVOLUME_TALK));
            int nOil    = GetLocalInt(oTarget, "OIL_AMOUNT");
            int nDouse  = FloatToInt(nOilInFlask*0.75);
            SetLocalInt(oTarget, "OIL_AMOUNT", nOil+nDouse);
            nOilInFlask = nOilInFlask - nDouse;
        }

        nOilInFlask = DoOilSplash(nOilInFlask, lWhere, oPC);
        if(nOilInFlask)
        {
            object oCreature    = CreateObject(OBJECT_TYPE_CREATURE, "invisible", lWhere);
            if(!GetLocalInt(oCreature,"ENTER_SWAMP_SECOND"))
            {
                // Create oil slick on ground
                object oOil     = CreateObject(OBJECT_TYPE_PLACEABLE, "oil_slick", lWhere, FALSE, "oil");
                SetLocalInt(oOil, "OIL_AMOUNT", nOilInFlask);
                SetLocalInt(oOil,"FADE_TIME", 30);
                InitializeFade(oOil);
            }
            DestroyObject(oCreature);
        }
        DestroyObject(oOilFlask, 0.1);
    }
    */
    // Not an appropriate target
    else
    {
        SendMessageToPC(oPC,RED+"Bad target: "+YELLOW+GetName(oTarget)+PINK+" is not an appropriate target for your "+YELLOW+GetName(oOilFlask)+PINK+".");
    }

 } // END Event Activate
}
