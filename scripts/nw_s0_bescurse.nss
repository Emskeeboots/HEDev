//::///////////////////////////////////////////////
//:: Bestow Curse
//:: NW_S0_BesCurse.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Afflicted creature must save or suffer a -2 penalty
    to all ability scores. This is a supernatural effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Bob McCabe
//:: Created On: March 6, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 20, 2001
/*
Patch 1.70, fix by Shadooow

- wrong signal event fixed
*/
//:://////////////////////////////////////////////
//:: Modified:   Henesua (2013 sept 8)
//        Spell Focus System incorporated
//        Enhanced Version for some cleric domains (combo of Krit DDPP and henesua)

// INCLUDES --------------------------------------------------------------------
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

// used by spellfocus system
#include "_inc_spells"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();


    // THE MAGUS'S SPELL FOCUS SYSTEM ------------------------------------------
    if(GetLocalInt(OBJECT_SELF, SPELLFOCUS_USE))
    {
        object oFocus   = GetLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);
        int nType       = GetLocalInt(oFocus, SPELLFOCUS_TYPE);
        if(nType==2)
            spell.Target     = GetLocalObject(oFocus, SPELLFOCUS_CREATURE);
        else if(nType==3)
            spell.Target     = GetPCByPCID(GetLocalString(oFocus, SPELLFOCUS_CREATURE));

        // garbage collection
        DeleteLocalInt(OBJECT_SELF, SPELLFOCUS_USE);
        DeleteLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);

        if(GetIsObjectValid(spell.Target))
        {
            SendMessageToPC(OBJECT_SELF, DMBLUE+"Success: Curse transmitted through the Spell Focus.");
            if(SPELLFOCUS_ONE_USE)
                DestroyObject(oFocus, 0.5);
        }
        else
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: Curse was not transmitted.");
            return;
        }

    }
    else
        spell.Target = GetSpellTargetObject(); // proceed as normal
    // END THE MAGUS'S SPELL FOCUS SYSTEM --------------------------------------


    effect eVis     = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eCurse   = EffectCurse(2, 2, 2, 2, 2, 2);


    // ENHANCED CURSES FOR SOME CLERIC DOMAINS ---------------------------------
    effect eEnhancedCurse;
    int bEnhanced;
    if(spell.Class == CLASS_TYPE_CLERIC)
    {
        // Add extra effects for the Destruction domain.
        if ( GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER) )
        {
            eEnhancedCurse =    EffectLinkEffects(  EffectACDecrease(1),
                                                    EffectLinkEffects(EffectAttackDecrease(1),EffectDamageDecrease(1))
                                                 );
            bEnhanced = TRUE;
        }
        // Add extra effects for the LUCK domain.
        if ( GetHasFeat(FEAT_LUCK_DOMAIN_POWER) )
        {
            if(bEnhanced)
                eEnhancedCurse =    EffectLinkEffects(  EffectLinkEffects(EffectSavingThrowDecrease(SAVING_THROW_ALL,1), EffectSkillDecrease(SKILL_ALL_SKILLS,2) ),
                                                        eEnhancedCurse
                                                     );
            else
                eEnhancedCurse =    EffectLinkEffects( EffectSavingThrowDecrease(SAVING_THROW_ALL,1), EffectSkillDecrease(SKILL_ALL_SKILLS,2) );
            bEnhanced = TRUE;
        }
        eEnhancedCurse = SupernaturalEffect(eEnhancedCurse);
    }
    // END ENHANCED CURSES------------------------------------------------------


    //Make sure that curse is of type supernatural not magical
    eCurse = SupernaturalEffect(eCurse);
    if(spellsIsTarget(spell.Target,SPELL_TARGET_SINGLETARGET,spell.Caster))
    {
        //Signal spell cast at event
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
         //Make SR Check
         if (!MyResistSpell(spell.Caster, spell.Target))
         {
            //Make Will Save
            if (!MySavingThrow(SAVING_THROW_WILL, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
            {
                //Apply Effect and VFX
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eCurse, spell.Target);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);

               // Enhanced Curse Applied
                if ( bEnhanced )
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEnhancedCurse, spell.Target);
            }
        }
    }
}
