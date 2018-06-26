//::///////////////////////////////////////////////
//:: [Charm Person]
//:: [NW_S0_CharmPer.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is charmed for 1 round
//:: per caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 5, 2001
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 20, 2001
/*
Patch 1.70, fix by Shadooow

- wont affect wrong target at all (previously could still took spell mantle)
*/
//:://////////////////////////////////////////////
//:: Modified:   Henesua (2013 sept 8)
//        Duration Changed to 1 Turn/level
//        Incorporating a personal reputation system. Reputation is adjusted for 1hr/level

// INCLUDES --------------------------------------------------------------------
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

//#include "v2_inc_util"
#include "_inc_util"
// Vendalus's Personal Reputation and Reaction System
//#include "_prr_main"

// MAIN ------------------------------------------------------------------------
void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis     = EffectVisualEffect(VFX_IMP_CHARM);
    effect eCharm   = EffectCharmed();
           eCharm   = GetScaledEffect(eCharm, spell.Target);
    effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //Link persistant effects
    effect eLink    = EffectLinkEffects(eMind, eCharm);
           eLink    = EffectLinkEffects(eLink, eDur);

    int nDuration   = spell.Level;
        nDuration   = GetScaledDuration(nDuration, spell.Target);
    //Make Metamagic check for extend
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration * 2;

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
      //Fire cast spell at event for the specified target
      SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

      if(CreatureGetIsHumanoid(spell.Target))
      {
        //Make SR Check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //Make a Will Save check
            if (!MySavingThrow(SAVING_THROW_WILL, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
            {
                //Apply impact and linked effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);

                // Personal Reputation and Reaction System
                //PRR_CHARM_AffectTarget(spell.Target, OBJECT_SELF, nDuration);
            }
            else
            {
                // Reputation
                //  - Unimplemented
                // Caster's reputation should suffer when a target makes a save
                // and realizes that a charm spell was cast

            }
        }
      }
    }
}
