//::///////////////////////////////////////////////
//:: Isaacs Lesser Missile Storm
//:: x0_s0_MissStorm1
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
 Up to 10 missiles, each doing 1d6 damage to all
 targets in area.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 31, 2002
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 14) missile dammage is d4+1

#include "70_inc_spells"
#include "x0_i0_spells"
//#include "70_inc_spellfunc"
#include "x2_inc_spellhook"

// Missile Storm variant that does a multiple of d4+1 per missile - [FILE: _inc_util]
// nD4Dice is the number of dice to use per missile
// nCap is the maximum number of missiles
void MissileStorm(int nD4Dice, int nCap);
void MissileStorm(int nD4Dice, int nCap)
{
    int nCasterLvl  = spell.Level;
    int nTypeSelf   = GetObjectType(spell.Caster);
    int i,nCnt      = 1;
    effect eMissile = EffectVisualEffect(VFX_IMP_MIRV);
    effect eVis     = EffectVisualEffect(VFX_IMP_MAGBLUE);
    float fDist     = 0.0;
    float fDelay    = 0.0;
    float fDelay2, fTime;
    int nMissiles   = nCasterLvl;
    if (nMissiles > nCap)
        nMissiles   = nCap;
    //Roll damage
    int nDam;
    //Resolve metamagic
    if(spell.Meta==METAMAGIC_MAXIMIZE)
        nDam        = (4*nD4Dice) + (1*nD4Dice);
    else
        nDam        = d4(nD4Dice) + (1*nD4Dice);

    if(spell.Meta==METAMAGIC_EMPOWER )
       nDam         = nDam + nDam/2;


        /* New Algorithm
            1. Count # of targets
            2. Determine number of missiles
            3. First target gets a missile and all Excess missiles
            4. Rest of targets (max nMissiles) get one missile
       */
    int nEnemies    = 0;

    object oTarget  = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        // * caster cannot be harmed by this spell
        if (oTarget != spell.Caster && spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster))
        {
            // GZ: You can only fire missiles on visible targets
            // If the firing object is a placeable (such as a projectile trap),
            // we skip the line of sight check as placeables can't "see" things.
            if ( ( nTypeSelf == OBJECT_TYPE_PLACEABLE ) ||
                   GetObjectSeen(oTarget,spell.Caster))
            {
                nEnemies++;
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
     }

     if (nEnemies == 0) return; // * Exit if no enemies to hit
     int nExtraMissiles = nMissiles / nEnemies;

     // April 2003
     // * if more enemies than missiles, need to make sure that at least
     // * one missile will hit each of the enemies
     if (nExtraMissiles <= 0)
        nExtraMissiles = 1;

     // by default the Remainder will be 0 (if more than enough enemies for all the missiles)
     int nRemainder = 0;

     if (nExtraMissiles >0)
        nRemainder = nMissiles % nEnemies;

     if (nEnemies > nMissiles)
        nEnemies = nMissiles;

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);

    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget) && nCnt <= nEnemies)
    {
        // * caster cannot be harmed by this spell
        if(     oTarget != spell.Caster
            &&  spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster)
            &&  (nTypeSelf==OBJECT_TYPE_PLACEABLE || GetObjectSeen(oTarget,spell.Caster))
          )
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));

            // * recalculate appropriate distances
            fDist = GetDistanceBetween(spell.Caster, oTarget);
            fDelay = fDist/(3.0 * log(fDist) + 2.0);

                //--------------------------------------------------------------
                // GZ: Moved SR check out of loop to have 1 check per target
                //     not one check per missile, which would rip spell mantels
                //     apart
                //--------------------------------------------------------------
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                nCap = nExtraMissiles + (nRemainder > 0);//this will distribute remainder missiles evenly
                for (i=1; i <= nCap; i++)
                {
                    fDelay2 += 0.1;
                    fTime = fDelay + fDelay2;

                    //Set damage effect
                    effect eDam = EffectDamage(nDam, DAMAGE_TYPE_MAGICAL);
                    //Apply the MIRV and damage effect
                    DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget));
                    DelayCommand(fDelay2, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget));
                    //do not bother when no damage should happen anyway
                    if(nDam > 0)
                        DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));

                }// for
            }
            else
            {   // * apply a dummy visual effect
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget);
            }
            nCnt++;// * increment count of missiles fired
            nRemainder--;
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    }
}

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();

    MissileStorm(1, 10);
}
