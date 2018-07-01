//::///////////////////////////////////////////////
//:: _s0_eruption
//:://////////////////////////////////////////////
/*
    Up to three fiery eruptions occur at the target location
    over the course of one round after casting the spell, each
    spaced 2 seconds apart. The initial eruption deals 12d6 damage
    to creatures within its area of effect, with a Reflex save
    allowed for half damage; if the target fails this save they
    are additionally stunned for one round.

    Each subsequent eruption deals half as much damage as the
    previous one and has its DC reduced by 2.
*/
//:://////////////////////////////////////////////
//:: Created:   Rubies and Pearls (2013 jan -- ccc spells and spellcrafting)
//:: Modified:  Henesua (2013 sept 28)  integrated with community patch
//::                                    causes bludgeon and fire damage (1/2 and 1/2)
//::////////////////////////////////////////////////


#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

#include "_inc_spells"

void EruptionGroundVFX(location lLoc)
{
    effect eEruptG = EffectVisualEffect(1671); // Ground duration effect
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eEruptG, lLoc, 12.0);
}

void EruptionVFX(location lLoc)
{
    effect eEruptF = EffectVisualEffect(1672); // Eruption FnF effect
    effect eEruptS = EffectVisualEffect(287); // Screen bump effect
    effect eEruptR = EffectVisualEffect(354); // Rock chunk effect

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEruptR, lLoc);
    DelayCommand(0.1, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEruptR, lLoc));

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEruptS, lLoc);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEruptF, lLoc);
    DelayCommand(0.15, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEruptF, lLoc));
    DelayCommand(0.35, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEruptF, lLoc));
}

void Eruption(location lLoc, int nDamage, int nDC, int bFirstEruption=0)
{
    EruptionVFX(lLoc);

    effect eDam1, eDam2, eStun, eVis;
    int nDam, nHalf1, nHalf2;

    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, RADIUS_SIZE_LARGE, lLoc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while(GetIsObjectValid(oTarget))
    {
        float fDelay = GetDistanceBetweenLocations(lLoc, GetLocation(oTarget))/20;

        if(oTarget!=OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            if(bFirstEruption)
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_ERUPTION, TRUE));

            int nReflexCheckHack = GetReflexAdjustedDamage(2, oTarget, nDC, SAVING_THROW_TYPE_FIRE, OBJECT_SELF);

            switch (nReflexCheckHack)
            {
                case 0: // Evasion/Improved Evasion, or equivalent modifier
                        // Nothing here, resisted all effects
                    nDam = 0;
                break;

                case 1: // Reflex save: Success
                    nDam    = nDamage /2;
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FLAME_S), oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_SMALL), oTarget));
                break;

                case 2: // Reflex save: Failure
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectStunned(), oTarget, 1.0));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FLAME_M), oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), oTarget));
                break;
            }
            if(nDam)
            {
                nHalf1  = (nDam/2);
                if(nHalf1<1){nHalf1=1;}
                nHalf2  = nDam - nHalf1;
                if(nHalf2<1){nHalf2=1;}

                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nHalf1, DAMAGE_TYPE_FIRE), oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nHalf2, DAMAGE_TYPE_BLUDGEONING), oTarget));
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, RADIUS_SIZE_LARGE, lLoc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDam1       = MaximizeOrEmpower(6, 12, spell.Meta);
    int nDam2       = MaximizeOrEmpower(6, 6, spell.Meta);
    int nDam3       = MaximizeOrEmpower(6, 3, spell.Meta);
    int nDC1        = spell.DC;
    int nDC2        = spell.DC-2;
    int nDC3        = spell.DC-4;
    location lLoc   = spell.Loc;

    EruptionGroundVFX(spell.Loc);
    DelayCommand(2.0, Eruption(lLoc, nDam1, nDC1, TRUE));
    DelayCommand(4.0, Eruption(lLoc, nDam2, nDC2));
    DelayCommand(6.0, Eruption(lLoc, nDam3, nDC3));
}
