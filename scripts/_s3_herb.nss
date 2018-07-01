//::///////////////////////////////////////////////
//:: _s3_herb
//:://////////////////////////////////////////////
//::original:
//::///////////////////////////////////////////////
//:: NW_S3_HERB.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   Various herbs to offer bonuses to the player using them.
   Belladonna:
   Garlic:
*/
//:://////////////////////////////////////////////
//:: Created By: bioware
//:: Modified:  henesua (2013 sept 17) added generic herb use
//:: Modified:
//:://////////////////////////////////////////////

#include "x3_inc_skin"
#include "X0_I0_SPELLS"

#include "_inc_util"
//#include "v2_inc_lycan"


void main()
{
    object oPC      = OBJECT_SELF;
    object oHerb    = GetSpellCastItem();
    object oTarget  = GetSpellTargetObject();
    int nID         = GetSpellId();
    // harvest time stamped on perishables
    int nPTime      = GetLocalInt(oHerb, "PERISHABLE_TIME");


    // Generic herb use
    if (nID == 998)
    {
        // determine which herb
        string sRef = GetResRef(oHerb);
        string sMsg;
        if(sRef=="willowbark")
        {

        }
        else if(sRef=="belladonna")
        {
            if(oTarget!=oPC)
                sMsg = GetName(oPC)+" feeds the berries to "+GetName(oTarget);
            else
                sMsg = GetName(oPC)+" eats the berries.";
            FloatingTextStringOnCreature(WHITE+sMsg, oPC);
            // is the character infected with lycanthropy?
            //if(GetHasLycanthropy(oTarget))
            {
                int nTime, bBela;
                if(GetIsPC(oTarget))
                {
                    nTime = GetSkinInt(oTarget, "LYCANTHROPY_AFFLICTION_TIME");
                    bBela = GetSkinInt(oTarget, "LYCANTHROPY_BELLADONNA");
                }
                else
                {
                    nTime = GetLocalInt(oTarget, "LYCANTHROPY_AFFLICTION_TIME");
                    bBela = GetLocalInt(oTarget, "LYCANTHROPY_BELLADONNA");
                }
                // only works if infected within the past 24 hours, and can only be tried once
                if(GetTimeCumulative()-nTime<=1440 && !bBela)
                {
                    if(GetIsPC(oTarget))
                        SetSkinInt(oTarget, "LYCANTHROPY_BELLADONNA",TRUE);
                    else
                        SetLocalInt(oTarget, "LYCANTHROPY_BELLADONNA",TRUE);
                    // DC 20 for the cure
                    if(GetIsSkillSuccessful(oTarget, SKILL_HEAL, 20) || FortitudeSave(oTarget, 20))
                    {
                        //SetHasLycanthropy(oTarget,0,FALSE);
                        DelayCommand(30.0, FloatingTextStringOnCreature(LIGHTBLUE+"The belladonna appears to have overwhelmed the beast's infection in "+GetName(oTarget)+"." , oPC, TRUE) );
                    }
                }
            }
            // Apply Poison
            effect ePoison = EffectPoison(POISON_NIGHTSHADE);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, oTarget);
        }
        else if(sRef=="garlic")
        {

        }
        else if(sRef=="onion")
        {

        }
        else if(sRef=="chamomile")
        {

        }
        else if(sRef=="mistletoe")
        {

        }
        else if(sRef=="wolfsbane")
        {
          if(GetTimeCumulative()>=nPTime)
          {
            //wolfsbane only lasts a week
            FloatingTextStringOnCreature(RED+"This wolfsbane is too old to be effective.", oPC, FALSE);
            return;
          }

            if(oTarget!=oPC)
                sMsg = GetName(oPC)+" rubs the wolfsbane on "+GetName(oTarget);
            else
                sMsg = GetName(oPC)+" rubs the wolfsbane on themself.";
            FloatingTextStringOnCreature(WHITE+sMsg, oPC);
            //if(!GetHasLycanthropy(oTarget))
            {
                effect eVisual = EffectVisualEffect(VFX_IMP_AC_BONUS);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVisual, oTarget);
                effect eACBonus = VersusRacialTypeEffect(EffectACIncrease(5), RACIAL_TYPE_SHAPECHANGER);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eACBonus, oTarget, 120.0);
            }
            //else
               //DoPCLycanthropeWolfsbane(oTarget);

        }
        else if(sRef=="mandrake")
        {
            sMsg = GetName(oPC)+" breaks the mandrake root open, invoking its scream.";
            FloatingTextStringOnCreature(WHITE+sMsg, oPC);

            location lLoc   = GetLocation(oPC);
            if(!GetHasEffect(EFFECT_TYPE_SILENCE, oPC))
            {
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_WAIL_O_BANSHEES), lLoc);
                float fDelay;
                effect eDeath = EffectDeath();
                effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
                object oTarget  = GetFirstObjectInShape(SHAPE_SPHERE, 15.0, lLoc);
                int nRace;
                while(GetIsObjectValid(oTarget))
                {
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_WAIL_OF_THE_BANSHEE));//udef event spellcastat for oTarget
                    nRace   = GetRacialType(oTarget);
                    if(     !GetHasEffect(EFFECT_TYPE_DEAF, oTarget)
                        &&  !GetHasEffect(EFFECT_TYPE_SILENCE, oTarget)
                        &&  nRace!=RACIAL_TYPE_FEY
                        &&  nRace!=RACIAL_TYPE_HUMANOID_GOBLINOID
                      )
                    {
                        if(!MySavingThrow(SAVING_THROW_FORT, oTarget, 12, SAVING_THROW_TYPE_DEATH))//fort save to avoid death
                        {
                            fDelay = GetRandomDelay(3.0, 3.8);
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                        }
                    }
                    oTarget  = GetNextObjectInShape(SHAPE_SPHERE, 15.0, lLoc);
                }
            }

        }
    }
    else
    // * Bioware Belladonna
    if (nID == 409)
    {
       object oTarget = GetSpellTargetObject();
       effect eVisual = EffectVisualEffect(VFX_IMP_AC_BONUS);
       ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVisual, oTarget);
       effect eACBonus = VersusRacialTypeEffect(EffectACIncrease(5), RACIAL_TYPE_SHAPECHANGER);
       ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eACBonus, oTarget, 60.0);
    }
    else
    // * Bioware Garlic; protection against Vampires
    // * Lowers charisma
    if (nID == 410)
    {
       object oTarget = GetSpellTargetObject();
       effect eAttackBonus = VersusRacialTypeEffect(EffectAttackIncrease(2), RACIAL_TYPE_UNDEAD);
       effect eCharisma = EffectAbilityDecrease(ABILITY_CHARISMA, 1);
       effect eVisual = EffectVisualEffect(VFX_IMP_AC_BONUS);
       ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVisual, oTarget);
       ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAttackBonus, oTarget, 60.0);
       ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCharisma, oTarget, 60.0);

    }

}
