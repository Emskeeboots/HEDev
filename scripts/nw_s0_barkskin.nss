//::///////////////////////////////////////////////
//:: [Barkskin]
//:: [NW_S0_BarkSkin.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
   Enhances the casters Natural AC by an amount
   dependant on the caster's level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 21, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 5, 2001
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 20, 2001
//:://////////////////////////////////////////////
//:: Modified:   Henesua (2013 sept 8)
//        Duration Changed to 5 Turns + 1 Turn/level

// INCLUDES --------------------------------------------------------------------
#include "70_inc_spells"
#include "x2_inc_spellhook"


// MAIN ------------------------------------------------------------------------
void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    int nBonus;
    float fDuration = TurnsToSeconds(5 + spell.Level);
    effect eVis     = EffectVisualEffect(VFX_DUR_PROT_BARKSKIN);
    effect eHead    = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eAC;

    //Signal spell cast at event
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND) //Duration is +100%
    {
        fDuration *= 2.0;
    }

    //Determine AC Bonus based Level.
    if (spell.Level <= 6)
    {
        nBonus = 3;
    }
    else
    {
        if (spell.Level <= 12)
        {
            nBonus = 4;
        }
        else
        {
            nBonus = 5;
        }
     }

    //Make sure the Armor Bonus is of type Natural
            eAC     = EffectACIncrease(nBonus, AC_NATURAL_BONUS);
    effect eLink    = EffectLinkEffects(eVis, eAC);
           eLink    = EffectLinkEffects(eLink, eDur);

    // Apply Effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eHead, spell.Target);
}
