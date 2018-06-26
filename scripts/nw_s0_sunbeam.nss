//::///////////////////////////////////////////////
//:: Sunbeam
//:: s_Sunbeam.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: All creatures in the beam are struck blind and suffer 4d6 points of damage. (A successful
//:: Reflex save negates the blindness and reduces the damage by half.) Creatures to whom sunlight
//:: is harmful or unnatural suffer double damage.
//::
//:: Undead creatures caught within the ray are dealt 1d6 points of damage per caster level
//:: (maximum 20d6), or half damage if a Reflex save is successful. In addition, the ray results in
//:: the total destruction of undead creatures specifically affected by sunlight if they fail their saves.
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Feb 22, 2001
//:://////////////////////////////////////////////
//:: Last Modified By: Keith Soleski, On: March 21, 2001
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.71, by Shadooow

- second save at DC 0 removed
- damage wasn't properly calculated in case that there would be both undead and
non-undead creatures in AoE
- oozes and plants takes full damage as if they were undead
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 Sept 11)
//          changed dice to d8 for undead
//          oozes in separate category along with fungus for d6
//          plants changed to fungus and given function to detect based on appearance

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

#include "_inc_util"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis     = EffectVisualEffect(VFX_IMP_DEATH);
    effect eVis2    = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eStrike  = EffectVisualEffect(VFX_FNF_SUNBEAM);
    effect eDam;
    effect eBlind   = EffectLinkEffects(EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE),
                                        EffectBlindness()
                                       );

    int nCasterLevel = spell.Level;
    int nRace, nDamage, nOrgDam, bBlind;
    int nDice, nNumber;
    float fDelay;
    int nBlindLength = 3;
    //Limit caster level
    if (nCasterLevel > 20)
    {
        nCasterLevel = 20;
    }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spell.Loc);
    //Get the first target in the spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc);
    while(GetIsObjectValid(oTarget))
    {
        // Make a faction check
        if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, spell.Caster))
        {
            fDelay = GetRandomDelay(1.0, 2.0);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make an SR check
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                nRace = GetRacialType(oTarget);
                // undead are the most vulnerable
                if(nRace == RACIAL_TYPE_UNDEAD)
                {
                    nDice   = 8;
                    nNumber = nCasterLevel;
                    bBlind  = TRUE;
                }
                // other vulnerable species
                else if(    nRace == RACIAL_TYPE_OOZE
                        ||  CreatureGetIsFungus(oTarget)
                        ||  spellsIsLightVulnerable(oTarget)
                       )
                {
                    nDice   = 6;
                    nNumber = nCasterLevel;
                    bBlind  = TRUE;
                }
                // constructs are almost unaffected
                else if(nRace == RACIAL_TYPE_CONSTRUCT)
                {
                    nDice   = 4;
                    nNumber = 3;
                    bBlind  = FALSE;
                }
                // all others
                else
                {
                    nDice   = 6;
                    nNumber = 3;
                    bBlind  = TRUE;
                }
                //Do metamagic checks
                nOrgDam = MaximizeOrEmpower(nDice,nNumber,spell.Meta);

                //Get the adjusted damage due to Reflex Save, Evasion or Improved Evasion
                nDamage = GetReflexAdjustedDamage(nOrgDam, oTarget, spell.DC, SAVING_THROW_TYPE_DIVINE, spell.Caster);

                if(nDamage > 0)
                {
                    if( nOrgDam==nDamage && bBlind && !spellsIsSightless(oTarget) )
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBlind, oTarget, RoundsToSeconds(nBlindLength)));

                    //Set damage effect
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_DIVINE);
                    //Apply the damage effect and VFX impact
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                }
            }
        }
        //Get the next target in the spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc);
    }
}
