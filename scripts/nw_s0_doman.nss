//::///////////////////////////////////////////////
//:: [Dominate Animal]
//:: [NW_S0_DomAn.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is dominated for 1 round
//:: per caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 30, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 30, 2001
/*
Patch 1.70, fix by Shadooow

- won't fire signal event on wrong targets
*/
//:: Modified: Henesua (2013 sept 9) GetIsAnimal check added


#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

//#include "v2_inc_util"
#include "_inc_util"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eDom     = EffectDominated();
    effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //Link domination and persistant VFX
    effect eLink    = EffectLinkEffects(eMind, eDom);
           eLink    = EffectLinkEffects(eLink, eDur);
    effect eVis     = EffectVisualEffect(VFX_IMP_DOMINATE_S);

    int nDuration   = 3 + spell.Level;
    //Check for Metamagic extension
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration * 2;

    //Make sure the target is an animal
    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        if(CreatureGetIsAnimal(spell.Target))
        {
           //Make SR check
           if (!MyResistSpell(spell.Caster, spell.Target))
           {
                //Will Save for spell negation
                if (!MySavingThrow(SAVING_THROW_WILL, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
                {
                    //Apply linked effect and VFX impact
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(nDuration));
                }
            }
        }
    }
}
