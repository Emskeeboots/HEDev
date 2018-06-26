//::///////////////////////////////////////////////
//:: _s0_hasteslow
//:: Mass Haste/Slow
//:://////////////////////////////////////////////
// If the target is friendly, grants 50% movement speed.
// If the target is hostile, reduces their movement speed by 50%.
// If the target is the ground, becomes an AoE spell which grants 20%
// movement speed bonus/penalty to allies/hostiles, respectively.
// Because single-type spells are boring and this way Improved Haste/Slow
// can be ridiculously overpowered and high level. :P
//:://////////////////////////////////////////////
//:: Created:   Sarah M. / Rubies
//:: Edited:    shinypearls 28/11/12
//                  removed the custom functions that don't seem to do anything,
//                  maybe they were part of the custom client at some point
//                  now it just uses EffectMovementSpeed
//                  raised the cast time to be reasonable for vanilla nwn
//:://////////////////////////////////////////////
//:: Modified:  Henesua (2013 sept 29)  integrated with community patch
//::                                    duration scales. spell is level 7
//::                                    corrected effects to Haste and Slow
//::                                    modelled after mass haste

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration   = spell.Level;
    if(spell.Meta==METAMAGIC_EXTEND)
        nDuration  *= 2;
    float fDuration = RoundsToSeconds(nDuration);

    //eff Defs
    effect eHaste   = EffectHaste();
    effect eDurH    = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eVisH    = EffectVisualEffect(VFX_IMP_HASTE);
           eHaste   = EffectLinkEffects(eHaste, eDurH);
    effect eSlow    = EffectSlow();
    effect eDurS    = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisS    = EffectVisualEffect(VFX_IMP_SLOW);
           eSlow    = EffectLinkEffects(eSlow, eDurS);


    effect eImpact  = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    // Generic AoE code, whee!
    int bHostile; float fDelay;
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc);
    // Only loop while valid...
    while (GetIsObjectValid(oTarget))
    {
      bHostile    = TRUE;
      fDelay = GetRandomDelay(0.0, 1.0);
      if(GetIsEnemy(oTarget, OBJECT_SELF)) // Eep, he's a baddie! DO SOMETHING BAD!
      {
        if(     !MyResistSpell(OBJECT_SELF, oTarget, 0.25)
            &&  !MySavingThrow(SAVING_THROW_WILL, oTarget, spell.DC, SAVING_THROW_TYPE_NONE,spell.Caster)
          )
        {
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisS, oTarget) );
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, oTarget, fDuration) );
        }
      }
      else // Oh phew, I almost mistook him for a baddie! Better buff him instead!
      {
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisH, oTarget) );
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHaste, oTarget, fDuration) );
            bHostile    = FALSE;
      }
      SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, spell.Id, bHostile));

      // Get next baddie! Or goodie, you know. Either's good.
      oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc);
    }
}
