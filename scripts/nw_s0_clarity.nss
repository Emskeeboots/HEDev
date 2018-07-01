//::///////////////////////////////////////////////
//:: Clarity
//:: NW_S0_Clarity.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell removes Charm, Daze, Confusion, Stunned
    and Sleep.  It also protects the user from these
    effects for 1 turn / level.  Does 1 point of
    damage for each effect removed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 25, 2001
//:://////////////////////////////////////////////
//:: Modified:  Henesua (2013 sept 8) minor adjustment of duration so that all of the duration doubles with metamagic extend

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eImm1 = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    effect eDam = EffectDamage(1, DAMAGE_TYPE_NEGATIVE);
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eImm1, eVis);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eSearch = GetFirstEffect(spell.Target);

    float fDur = RoundsToSeconds(5 + spell.Level);
    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        fDur += fDur; //Duration is +100%
    }
    int bValid;
    int bVisual;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Search through effects
    while(GetIsEffectValid(eSearch))
    {
        bValid = FALSE;
        //Check to see if the effect matches a particular type defined below
        switch(GetEffectType(eSearch))
        {
        case EFFECT_TYPE_DAZED:
        case EFFECT_TYPE_CHARMED:
        case EFFECT_TYPE_SLEEP:
        case EFFECT_TYPE_CONFUSED:
        case EFFECT_TYPE_STUNNED:
        bValid = TRUE;
        break;
        }
        //Apply damage and remove effect if the effect is a match
        if (bValid == TRUE)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            RemoveEffect(spell.Target, eSearch);
            bVisual = TRUE;
        }
        eSearch = GetNextEffect(spell.Target);
    }

    //After effects are removed we apply the immunity to mind spells to the target
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDur);
}
