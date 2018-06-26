//::///////////////////////////////////////////////
//:: Henchman Death Script
//::
//:: NW_CH_AC7.nss
//::
//:: Copyright (c) 2001-2008 Bioware Corp.
//:://////////////////////////////////////////////
//:: Official Campaign Henchmen Respawn
//:://////////////////////////////////////////////
//::
//:: Modified by:   Brent, April 3 2002
//::                Removed delay in respawning
//::                the henchman - caused bugs
//:
//::                Georg, Oct 8 2003
//::                Rewrote teleport to temple routine
//::                because it was broken by
//::                some delicate timing issues in XP2
//:://////////////////////////////////////////////
//:: Modified: Deva Winblood April 9th, 2008
//:: Added Support for Dying While Mounted
//:://///////////////////////////////////////////////
//:: Modified: The Magus (2013 jan 17) Innocuous Familiars -  FamiliarDeathEvent()


#include "nw_i0_generic"
#include "nw_i0_plot"
#include "x3_inc_horse"

// INNOCUOUS FAMILIARS
#include "_inc_pets"

// -----------------------------------------------------------------------------
// Georg, 2003-10-08
// Rewrote that jump part to get rid of the DelayCommand Code that was prone to
// timing problems. If want to see a really back hack, this function is just that.
// -----------------------------------------------------------------------------
void WrapJump(string sTarget)
{
    if (GetIsDead(OBJECT_SELF))
    {
        // * Resurrect and heal again, just in case
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectResurrection(), OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectHeal(GetMaxHitPoints(OBJECT_SELF)), OBJECT_SELF);

        // * recursively call self until we are alive again
        DelayCommand(1.0f,WrapJump( sTarget));
        return;
    }
    // * since the henchmen are teleporting very fast now, we leave a bloodstain on the ground
    object oBlood = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_bloodstain", GetLocation(OBJECT_SELF));

    // * Remove blood after a while
    DestroyObject(oBlood,30.0f);

    // * Ensure the action queue is open to modification again
    SetCommandable(TRUE,OBJECT_SELF);

    // * Jump to Target
    JumpToObject(GetObjectByTag(sTarget), FALSE);

    // * Unset busy state
    ActionDoCommand(SetAssociateState(NW_ASC_IS_BUSY, FALSE));

    // * Make self vulnerable
    SetPlotFlag(OBJECT_SELF, FALSE);

    // * Set destroyable flag to leave corpse
    DelayCommand(6.0f, SetIsDestroyable(TRUE, TRUE, TRUE));

    // * if mounted make sure dismounted
    if (HorseGetIsMounted(OBJECT_SELF))
    { // dismount
        DelayCommand(3.0,AssignCommand(OBJECT_SELF,HorseDismountWrapper()));
    } // dismount
}

// -----------------------------------------------------------------------------
// Georg, 2003-10-08
// Changed to run the bad recursive function above.
// -----------------------------------------------------------------------------
void BringBack()
{
    object oSelf = OBJECT_SELF;

    SetLocalObject(oSelf,"NW_L_FORMERMASTER", GetMaster());
    RemoveEffects(oSelf);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectResurrection(), OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectHeal(GetMaxHitPoints(OBJECT_SELF)), OBJECT_SELF);

    object oWay = GetObjectByTag("NW_DEATH_TEMPLE");

    if (GetIsObjectValid(oWay) == TRUE)
    {
        // * if in Source stone area, respawn at opening to area
        if (GetTag(GetArea(oSelf)) == "M4Q1D2")
        {
            DelayCommand(1.0, WrapJump("M4QD07_ENTER"));
        }
        else
        {
            DelayCommand(1.0, WrapJump(GetTag(oWay)));
        }
    }
    else
    {
        WriteTimestampedLogEntry("UT: No place to go");
    }
}


void main()
{
    // Check whether the death event has already been called
    if(GetLocalInt(OBJECT_SELF, "IS_DEAD"))
        return;
    SetLocalInt(OBJECT_SELF, "IS_DEAD", TRUE); // set the death event as called

    SetLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT","nw_ch_ac7");
    if (HorseHandleDeath()) return;
    DeleteLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT");

    // * This is used by the advanced henchmen
    // * Let Brent know if it interferes with animal
    // * companions et cetera
    object oMaster  = GetMaster();
    if (GetIsObjectValid(oMaster))
    {
        int nAssType = GetAssociateType(OBJECT_SELF);
        if( nAssType == ASSOCIATE_TYPE_HENCHMAN
            // * this is to prevent 'double hits' from stopping
            // * the henchmen from moving to the temple of tyr
            // * I.e., henchmen dies 'twice', once after leaving  your party
            //|| GetLocalInt(OBJECT_SELF, "NW_L_HEN_I_DIED") == TRUE
          )
        {
            // -----------------------------------------------------------------------------
            // Georg, 2003-10-08
            // Rewrote code from here.
            // -----------------------------------------------------------------------------
            /*
            SetPlotFlag(OBJECT_SELF, TRUE);
            SetAssociateState(NW_ASC_IS_BUSY, TRUE);
            AddJournalQuestEntry("Henchman", 99, oMaster, FALSE, FALSE, FALSE);
            SetIsDestroyable(FALSE, TRUE, TRUE);
            SetLocalInt(OBJECT_SELF, "NW_L_HEN_I_DIED", TRUE);
            BringBack();
            */
           // -----------------------------------------------------------------------------
           // End of rewrite
           // -----------------------------------------------------------------------------
        }
        // THE MAGUS' INNOCUOUS FAMILIARS --------------------------------------
        else if(nAssType == ASSOCIATE_TYPE_FAMILIAR)
        {
            FamiliarDeathEvent(oMaster);
        }
        // END THE MAGUS' INNOCUOUS FAMILIARS ----------------------------------
    }
}
