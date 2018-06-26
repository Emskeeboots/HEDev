//::///////////////////////////////////////////////
//:: Rogues Cunning AKA Potion of Extra Thieving
//:: NW_S0_ExtraThf.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants the user +10 Search, Disable Traps and
    Move Silently, Open Lock (+5), Pick Pockets
    Set Trap for 5 Turns
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: November 9, 2001
//:://////////////////////////////////////////////
//:: Modified:  Henesua (2013 sept 14) duration rounded out spell to function as spell rather than magic item
//::                                    skills changed, and bonus reduced to 4.
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
    int nDuration   = 10 + (2*spell.Level);
    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration += nDuration; //Duration is +100%
    }
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    effect eOpen    = EffectSkillIncrease(SKILL_OPEN_LOCK, 4);
    effect eDisable = EffectSkillIncrease(SKILL_DISABLE_TRAP, 4);
    effect ePick    = EffectSkillIncrease(SKILL_PICK_POCKET, 4);
    effect eEscape  = EffectSkillIncrease(26, 4); // escape artist
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    //Link Effects
    effect eLink    = EffectLinkEffects(eOpen, eDisable);
           eLink    = EffectLinkEffects(eLink, ePick);
           eLink    = EffectLinkEffects(eLink, eEscape);
           eLink    = EffectLinkEffects(eLink, eDur);

    effect eVis     = EffectVisualEffect(VFX_IMP_MAGICAL_VISION);
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}
