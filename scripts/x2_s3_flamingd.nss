//::///////////////////////////////////////////////
//:: OnHit Firedamage
//:: x2_s3_flamgind
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

   OnHit Castspell Fire Damage property for the
   flaming weapon spell (x2_s0_flmeweap).

   We need to use this property because we can not
   add random elemental damage to a weapon in any
   other way and implementation should be as close
   as possible to the book.


    This spell is repurposed for all the elemental enchantments to weapons

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-17
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 15)   switches for Acid, Lightning, Ice, Sonic, Divine, Negative, and positive

void main()
{
    // Get Caster Level
    int nLevel          = GetCasterLevel(OBJECT_SELF);
    int nSpell          = GetSpellId();

    // Assume minimum caster level if variable is not found
    if (nLevel== 0){ nLevel =1; }

    int nDamageType     = DAMAGE_TYPE_FIRE;
    int nVFXImpS        = VFX_IMP_FLAME_S;
    int nVFXImpL        = VFX_IMP_FLAME_M;

    switch(nSpell)
    {
        case 882: //acid
            nDamageType = DAMAGE_TYPE_ACID;
            nVFXImpS    = VFX_IMP_ACID_S;
            nVFXImpL    = VFX_IMP_ACID_L;
        break;
        case 884: //electicity
            nDamageType = DAMAGE_TYPE_ELECTRICAL;
            nVFXImpS    = VFX_IMP_LIGHTNING_S;
            nVFXImpL    = VFX_IMP_LIGHTNING_M;
        break;
        case 886: //cold
            nDamageType = DAMAGE_TYPE_COLD;
            nVFXImpS    = VFX_IMP_FROST_S;
            nVFXImpL    = VFX_IMP_FROST_L;
        break;
        case 888: //sonic
            nDamageType = DAMAGE_TYPE_SONIC;
            nVFXImpS    = VFX_IMP_SONIC;
            nVFXImpL    = VFX_IMP_SONIC;
        break;
        case 889: //divine
            nDamageType = DAMAGE_TYPE_DIVINE;
            nVFXImpS    = VFX_IMP_DIVINE_STRIKE_HOLY;
            nVFXImpL    = VFX_IMP_DIVINE_STRIKE_HOLY;
        break;
        case 890: //negative
            nDamageType = DAMAGE_TYPE_NEGATIVE;
            nVFXImpS    = VFX_IMP_NEGATIVE_ENERGY;
            nVFXImpL    = VFX_IMP_NEGATIVE_ENERGY;
        break;
        case 891: //positive
            nDamageType = DAMAGE_TYPE_POSITIVE;
            nVFXImpS    = VFX_IMP_DIVINE_STRIKE_HOLY;
            nVFXImpL    = VFX_IMP_DIVINE_STRIKE_HOLY;
        break;
    }

    int nDmg = d4() + nLevel;
    effect eDmg = EffectDamage(nDmg,nDamageType);
    effect eVis;
    if (nDmg<10) // if we are doing below 10 point of damage, use small flame
           eVis = EffectVisualEffect(nVFXImpS);
    else
           eVis = EffectVisualEffect(nVFXImpL);

           eDmg = EffectLinkEffects (eVis, eDmg);

    object oTarget = GetSpellTargetObject();
    if(GetIsObjectValid(oTarget))
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
}
