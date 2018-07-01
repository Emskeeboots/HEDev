//::///////////////////////////////////////////////
//:: Magic Vestment
//:: X2_S0_MagcVest
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 AC bonus to armor touched per 3 caster
  levels (maximum of +5).
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 09, 2003
//:: 2003-07-29: Rewritten, Georg Zoeller
/*
Patch 1.70, fix by Shadooow

- never auto-targetted any shield if cast at character (without armor)
- VFX added if cast on weapon on ground
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 15) duration to rounds

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddACBonusToArmor(object oMyArmor, float fDuration, int nAmount)
{
    IPSafeAddItemProperty(oMyArmor,ItemPropertyACBonus(nAmount), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eVis = EffectVisualEffect(VFX_IMP_GLOBE_USE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    // Duration
    int nDuration   = 15 + (5*spell.Level);
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration * 2; //Duration is +100%
    float fDuration = RoundsToSeconds(nDuration);

    // AC Enchantment level
    int nAmount = spell.Level/3;
    if (nAmount < 0)
        nAmount = 1;
    else if (nAmount > 5)
        nAmount = 5;

    object oMyArmor = IPGetTargetedOrEquippedArmor(TRUE);
    object oPossessor = GetItemPossessor(oMyArmor);

    if(GetIsObjectValid(oMyArmor))
    {
        SignalEvent(oPossessor, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        if(GetIsObjectValid(oPossessor))
        {
            DelayCommand(1.3, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, fDuration);
        }
        else
        {
            DelayCommand(1.3, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc));
        }
        AddACBonusToArmor(oMyArmor, fDuration, nAmount);
    }
    else
    {
        FloatingTextStrRefOnCreature(83826, spell.Caster);
    }
}
