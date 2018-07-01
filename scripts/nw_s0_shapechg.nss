//::///////////////////////////////////////////////
//:: Shapechange
//:: NW_S0_ShapeChg.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 22, 2002
//:://////////////////////////////////////////////
//:: Modified: Henesua (2014 jan 25) poly tracking + Merged Krit's Horse Fix

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x3_inc_horse"

#include "_inc_util"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3);
    effect ePoly;
    int nPoly;
    int nDuration = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    // Horse anti-shapechange code.
    /*
    if ( !GetLocalInt(GetModule(), HORSELV_NO_SHAPESHIFT_CHECK) )
    {
        // The check is not disabled. Look for a mounted target.
        if ( HorseGetIsMounted(spell.Target) )
        {
            // Inform the target and abort.
            FloatingTextStrRefOnCreature(111982, spell.Target, FALSE); // "You cannot shapeshift while mounted."
            return;
        }
    }
    */


    //Determine Polymorph subradial type
    if(spell.Id == 392)
    {
        nPoly = POLYMORPH_TYPE_RED_DRAGON;
    }
    else if (spell.Id == 393)
    {
        nPoly = POLYMORPH_TYPE_FIRE_GIANT;
    }
    else if (spell.Id == 394)
    {
        nPoly = POLYMORPH_TYPE_BALOR;
    }
    else if (spell.Id == 395)
    {
        nPoly = POLYMORPH_TYPE_DEATH_SLAAD;
    }
    else if (spell.Id == 396)
    {
        nPoly = POLYMORPH_TYPE_IRON_GOLEM;
    }
    ePoly = EffectPolymorph(nPoly);
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_SHAPECHANGE, FALSE));
                                                             //direct id here because of subspells
    //Apply the VFX impact and effects
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
    DelayCommand(0.4, AssignCommand(spell.Target, ClearAllActions())); // prevents an exploit
    DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoly, spell.Target, TurnsToSeconds(nDuration)));

    // track polymorphed
    CreaturePolymorphed(spell.Target);
}
