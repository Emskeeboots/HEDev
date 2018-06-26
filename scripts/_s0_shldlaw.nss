//::///////////////////////////////////////////////
//:: _s0_shldlaw
//:://////////////////////////////////////////////
/*
    Spell Script for shield of law
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 10)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

#include "_inc_spells"
#include "_inc_pets"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    object oTarget  = OBJECT_SELF;
    float fDelay;
    float fRadius   = 10.0;
    int nDuration   = 1 + spell.Level;
    //Make Metamagic check for extend
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration * 2;

    int nGood       = GetAlignmentGoodEvil(OBJECT_SELF);

    effect eShi     = EffectVisualEffect(VFX_IMP_PULSE_HOLY);// VFX on caster
    effect eVis1    = EffectVisualEffect(VFX_IMP_GLOBE_USE); // VFX on individual affected by spell
    effect eVis2    = EffectVisualEffect(VFX_IMP_HEAD_HOLY); // VFX on individual affected by spell
    effect eDur     = EffectVisualEffect(VFX_DUR_GLOBE_MINOR);

    // ac and saves improved
    effect eAC      = EffectACIncrease(7, AC_DEFLECTION_BONUS);
    effect eProt    = EffectLinkEffects(eDur, eAC);
    // spell immunity
           eProt    = EffectLinkEffects(EffectSpellImmunity(SPELL_MAGIC_MISSILE), eProt);
           eProt    = EffectLinkEffects(EffectSpellImmunity(SPELL_FAMILIAR_MAGIC_MISSILE), eProt);
           eProt    = EffectLinkEffects(EffectSpellImmunity(SPELL_ISAACS_LESSER_MISSILE_STORM), eProt);
           eProt    = EffectLinkEffects(EffectSpellImmunity(SPELL_ISAACS_GREATER_MISSILE_STORM), eProt);
    // anti-chaos effect
    effect eImmune  = EffectLinkEffects(EffectSavingThrowIncrease(5,SAVING_THROW_ALL),
                                        EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS)
                                       );
    int nSR;
    effect eLaw;

    //Get the first target in the radius around the caster
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eShi, OBJECT_SELF);

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {
        if(     (GetIsReactionTypeFriendly(oTarget) || GetFactionEqual(oTarget))
            &&  GetAlignmentLawChaos(oTarget)==ALIGNMENT_LAWFUL
            &&  GetAlignmentGoodEvil(oTarget)==nGood

          )
        {
            nSR     = 25 - GetSpellResistance(oTarget);
            if(nSR<1){ nSR = 1; }
            eLaw    = VersusAlignmentEffect(EffectLinkEffects(EffectSpellResistanceIncrease(nSR), eImmune), ALIGNMENT_CHAOTIC);

            fDelay = GetRandomDelay(0.4, 1.1);
            //Fire spell cast at event for target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_SHIELD_OF_LAW, FALSE));
            //Apply VFX impact and bonus effects
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eProt, oTarget, RoundsToSeconds(nDuration));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLaw, oTarget, RoundsToSeconds(nDuration));
        }
        //Get the next target in the specified area around the caster
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(OBJECT_SELF));
    }
}
