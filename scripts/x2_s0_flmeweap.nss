//::///////////////////////////////////////////////
//:: Flame Weapon
//:: X2_S0_FlmeWeap
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Gives a melee weapon 1d4 fire damage +1 per caster
  level to a maximum of +10.

    This spell is repurposed for the elemental enchantments to weapons

*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 29, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:: 2003-07-15: Complete Rewrite to make use of Item Property System
/*
Patch 1.70, fix by Shadooow

- VFX added if cast on weapon on ground
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 15)   duration to rounds
//::                                    switches for Acid, Lightning, Ice, and Sonic

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddEnergyEffectToWeapon(object oTarget, float fDuration, int nCasterLevel, int nEnergyProp, int nItemVFX)
{
    // If the spell is cast again, any previous itemproperties matching are removed.
    IPSafeAddItemProperty(oTarget, ItemPropertyOnHitCastSpell(nEnergyProp,nCasterLevel), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(nItemVFX), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();

    int nEnergyVFX  = VFX_IMP_PULSE_FIRE;
    int nEnergyProp = 124; // on hit fire
    int nItemVFX    = ITEM_VISUAL_FIRE;
    switch(spell.Id)
    {
        case 881: // acid weapon
            nEnergyVFX  = VFX_IMP_PULSE_NATURE;
            nEnergyProp = 141; // on hit acid
            nItemVFX    = ITEM_VISUAL_ACID;
        break;
        case 883: // lightning weapon
            nEnergyVFX  = VFX_IMP_PULSE_WIND;
            nEnergyProp = 142; // on hit electricity
            nItemVFX    = ITEM_VISUAL_ELECTRICAL;
        break;
        case 885: // ice weapon
            nEnergyVFX  = VFX_IMP_PULSE_WATER;
            nEnergyProp = 143; // on hit cold
            nItemVFX    = ITEM_VISUAL_COLD;
        break;
        case 887: // sonic weapon
            nEnergyVFX  = VFX_IMP_PDK_OATH;
            nEnergyProp = 144; // on hit sonic
            nItemVFX    = ITEM_VISUAL_SONIC;
        break;
    }


    effect eVis = EffectVisualEffect(nEnergyVFX);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    // Duration

//Oldfog 2018-04-21
    int nDuration = GetCasterLevel(OBJECT_SELF);

// Henesua
//    int nDuration   = 5 + (2*spell.Level);
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration * 2; //Duration is +100%
    float fDuration = TurnsToSeconds(nDuration);

    int nCasterLvl = spell.Level;
    //Limit nCasterLvl to 10, so it max out at +10 to the damage.
    if(nCasterLvl > 10)
        nCasterLvl = 10;

    object oMyWeapon    = IPGetTargetedOrEquippedMeleeWeapon();
    object oPossessor   = GetItemPossessor(oMyWeapon);

    if(GetIsObjectValid(oMyWeapon))
    {
        //if the possessor isn't valid, nothing should happen
        SignalEvent(oPossessor, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        if(GetIsObjectValid(oPossessor))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, fDuration);
        }
        else
        {
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
        }
        // haaaack: store caster level on item for the on hit spell to work properly
        AddEnergyEffectToWeapon(oMyWeapon, fDuration, nCasterLvl, nEnergyProp, nItemVFX);
    }
    else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}
















