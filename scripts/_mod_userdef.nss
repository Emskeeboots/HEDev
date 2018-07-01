//::///////////////////////////////////////////////
//:: _mod_userdef
//:://////////////////////////////////////////////
/*
    Use: OnModuleUserDefined Event

    Modified On User Defined Event Script: x2_def_userdef
    (c) 2001 Bioware Corp.

    Community Content used:

*/
//:://////////////////////////////////////////////
//:: Created: Keith Warner (June 11/03)
//:: Modified: henesua (2016 jan 1) setting up PW
//:://////////////////////////////////////////////

// TT - Modification
// Line 135

#include "x0_i0_match"

#include "_inc_constants"
#include "_inc_util"
#include "_inc_xp"

// THE MAGUS' INNOCUOUS FAMILIARS
#include "_inc_pets"

//#include "v2_inc_spell"


void main()
{
    int nUser = GetUserDefinedEventNumber();

    if(nUser == EVENT_HEARTBEAT ) //HEARTBEAT
    {

    }
    else if(nUser == EVENT_PERCEIVE) // PERCEIVE
    {

    }
    else if(nUser == EVENT_END_COMBAT_ROUND) // END OF COMBAT
    {

    }
    else if(nUser == EVENT_DIALOGUE) // ON DIALOGUE
    {

    }
    else if(nUser == EVENT_ATTACKED) // ATTACKED
    {

    }
    else if(nUser == EVENT_DAMAGED) // DAMAGED
    {

    }

    else if(nUser == EVENT_SPELLCAST) // SPELL SUCESSFULLY CAST
    {
        object oCaster  = GetLocalObject(GetModule(), "SPELLLAST_CASTER");
        int nCasterLevel= GetLocalInt(oCaster,"SPELLLAST_CASTER_LEVEL");
        int nSpellID    = GetLocalInt(oCaster,"SPELLLAST_ID");
        int nMasterID   = nSpellID; // track master spell
        // if this spell has a master spell, only track spell cast for that spell
        string sMasterID=Get2DAString("spells","Master",nSpellID);
        if (sMasterID!="")
            nMasterID=StringToInt(sMasterID);
        int nSpellLevel = GetLocalInt(oCaster,"SPELLLAST_LEVEL"); //innate spell level
        //int nSpellClass = GetLocalInt(oCaster,"SPELLLAST_CLASS");
        //int nSpellDC    = GetLocalInt(oCaster,"SPELLLAST_DC");
        int nMeta       = GetLocalInt(oCaster,"SPELLLAST_META");
        object oTarget  = GetLocalObject(oCaster,"SPELLLAST_TARGET");

        string sSpellID  = "SPELL_"+IntToString(nMasterID); // ID of the spell in string format
        string sRewardTag= TAG_MAGIC+sSpellID; // tag string for the reward (when actually awarded it has "XP_" tacked on front)
        // polymorphed casters go no further
        if(GetHasEffect(EFFECT_TYPE_POLYMORPH,oCaster))
            return;


        // THE MAGUS' INNOCUOUS FAMILIARS --------------------------------------

        // Initiate Share Spell
        if(     GetLocalInt(oCaster, HAS_PET)
            &&  oTarget==oCaster
            &&  nMasterID!=SPELL_SHAPECHANGE && nMasterID!=SPELL_POLYMORPH_SELF
          )
        {
            // Only one of the following should be used. See FamiliarSpawnEvent(object oMaster)
            //object oFamiliar    = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCaster);// more_efficient_familiar
            object oFamiliar    = GetLocalObject(oCaster, FAMILIAR);// more_flexible_familiar

            // Familiars
            if(     GetIsObjectValid(oFamiliar)
                &&  GetDistanceBetween(oCaster, oFamiliar)<=10.0
              )
            {
                AssignCommand(oCaster, MasterSharesSpellWithFamiliar(nSpellID, oFamiliar, nMeta, nCasterLevel) );
            }
        }
        // END THE MAGUS' INNOCUOUS FAMILIARS ----------------------------------
/*
        // XP REWARD CODE ------------------------------------------------------
        int bReward = FALSE;

        if(nSpellID==318||nSpellID==317)
            bReward = FALSE;
        else if(GetIsInCombat(oCaster))
            bReward = TRUE;
        else
        {
            int last_minute     = GetLocalInt(oCaster,"SPELL_LAST_CAST_MINUTE");
            int this_minute     = GetTimeCumulative();
            if((this_minute-last_minute)>d4())
            {
                bReward = TRUE;
                SetLocalInt(oCaster,"SPELL_LAST_CAST_MINUTE",this_minute);
            }
        }

        if(bReward)
        {
            // calculate XP value of spell
            int nXPReward;
            if(nSpellLevel>0)
                nXPReward = (nSpellLevel*35);

// TT - Modification
//              nXPReward = (nSpellLevel*20)+(nCasterLevel*5);

            else
                nXPReward = 10;
            // Execute XP Reward Function
            // This call now handle the spell count degradation.
            XPRewardByType(sRewardTag, oCaster, nXPReward,  XP_TYPE_MAGIC);
        }
 */
    }

    else if(nUser == 1007) // DEATH  - do not use for critical code, does not fire reliably all the time
    {

    }
    else if(nUser == EVENT_DISTURBED) // DISTURBED
    {

    }
}
