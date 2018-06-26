//::///////////////////////////////////////////////
//:: Divine Weapon
//:: x0_s0_divfav.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
+1 bonus to attack and damage for every three
caster levels (+1 to max +5)  \
NOTE: Official rules say +6, we can only go to +5
 Duration: 1 turn
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 15, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 15)   duration to rounds 5 + 2/level
//::                                    weapon gains bonus damage type depending on class and clerical domains

#include "70_inc_spells"
#include "nw_i0_spells"
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

    // * determine the damage type to apply (and appropriate VFX)
    int nEnergyProp = 145;   // divine default damage type
    int nEnergyVFX  = VFX_FNF_LOS_NORMAL_30;
    int nItemVFX    = ITEM_VISUAL_HOLY;
    int nHead       = VFX_IMP_HEAD_HOLY;

    if(spell.Class==CLASS_TYPE_CLERIC)
    {
        if(     GetHasFeat(FEAT_EVIL_DOMAIN_POWER, spell.Caster)
            ||  GetHasFeat(FEAT_DEATH_DOMAIN_POWER, spell.Caster)
            ||  GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER, spell.Caster)
          )
        {
            nEnergyProp = 146; // on hit negative
            nEnergyVFX  = VFX_FNF_LOS_EVIL_30;
            nHead       = VFX_IMP_HEAD_EVIL;
            nItemVFX    = ITEM_VISUAL_EVIL;
        }
        else if(    GetHasFeat(FEAT_GOOD_DOMAIN_POWER, spell.Caster)
                ||  GetHasFeat(FEAT_HEALING_DOMAIN_POWER, spell.Caster)
                ||  GetHasFeat(FEAT_SUN_DOMAIN_POWER, spell.Caster)
               )
        {
            nEnergyProp = 147; // on hit positive
            nEnergyVFX  = VFX_FNF_LOS_HOLY_30;
        }
    }
    else if(spell.Class==CLASS_TYPE_PALADIN)
    {
        nEnergyProp = 147; // on hit positive
        nEnergyVFX  = VFX_FNF_LOS_HOLY_30;
    }

    effect eVis = EffectVisualEffect(nEnergyVFX);
    effect eHead= EffectVisualEffect(nHead);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    // Duration
    int nDuration   = 5 + (2*spell.Level);
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration * 2; //Duration is +100%
    float fDuration = RoundsToSeconds(nDuration);

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
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHead, oPossessor);
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
