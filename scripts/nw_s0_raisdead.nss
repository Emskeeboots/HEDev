//::///////////////////////////////////////////////
//:: [Raise Dead]
//:: [NW_S0_RaisDead.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Brings a character back to life with 1 HP.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 31, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: VFX Pass By: Preston W, On: June 22, 2001

#include "70_inc_spells"
#include "x2_inc_spellhook"

#include "_inc_corpse"

void main()
{
    // Spellcast Hook Code check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    // End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    if(GetIsDead(spell.Target))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), spell.Target);
        //Apply raise dead effect and VFX impact
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RAISE_DEAD), spell.Loc);
    }
    // if the target is not dead,
    // we still need to check if its a corpse that we can raise
    // check the object for the RAISEABLE bitflag in the local CORPSE int
    // if CORPSE is not set, this will also fail.
    else if( !SpellRaiseCorpse(spell.Target, spell.Id, spell.Loc, spell.Caster) )
    {
        // provide a potential fail message
        int nStrRef = GetLocalInt(spell.Target,"X2_L_RESURRECT_SPELL_MSG_RESREF");
        if (nStrRef == 0)
            nStrRef = 83861;

        if (nStrRef != -1)
            FloatingTextStrRefOnCreature(nStrRef,spell.Caster);
    }
}
