//::///////////////////////////////////////////////
//:: Gust of Wind
//:: [x0_s0_gustwind.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell creates a gust of wind in all directions
    around the target. All targets in a medium area will be
    affected:
    - Target must make a For save vs. spell DC or be
      knocked down for 3 rounds
    - plays a wind sound
    - if an area of effect object is within the area
    it is dispelled
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70, fix by Shadooow

- was missing delay in VFXs
- added stonehold into list of "blown-able" AOEs
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 9)    discipline check instead of fort save
//::                                    added light sources to be extinguished by wind
//::                                    loop: separated targets by object_type

#include "70_inc_spells"
#include "x2_inc_spellhook"

#include "_inc_util"   // creature and skill functions
#include "_inc_spells"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();
    string sAOETag;
    int nCasterLvl = spell.Level;
    int nDamage;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_WIND);
   // effect eDam;

    //Apply the fireball explosion at the location captured above.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);


    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_AREA_OF_EFFECT);
    object oLeft;
    int nObjType;
    object oArea    = GetArea(oTarget);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        // break it down by object type
        nObjType    = GetObjectType(oTarget);
        if (nObjType == OBJECT_TYPE_AREA_OF_EFFECT)
        {
            // Gust of wind should only destroy "cloud/fog like" area of effect spells.
            sAOETag = GetTag(oTarget);
            if ( sAOETag == "VFX_PER_FOGACID" ||
                 sAOETag == "VFX_PER_FOGKILL" ||
                 sAOETag == "VFX_PER_FOGBEWILDERMENT" ||
                 sAOETag == "VFX_PER_FOGSTINK" ||
                 sAOETag == "VFX_PER_FOGFIRE" ||
                 sAOETag == "VFX_PER_FOGMIND" ||
                 sAOETag == "VFX_PER_STONEHOLD" ||
                 sAOETag == "VFX_PER_CREEPING_DOOM")
            {
                DestroyObject(oTarget);
            }
        }
        else if(        oTarget!=spell.Caster
                &&  GetMaster(oTarget)!=spell.Caster
               )
        {
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //Get the distance between the explosion and the target to calculate delay
                fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;

                // * lit candles will be destroyed
                if( nObjType == OBJECT_TYPE_PLACEABLE )
                {
                    if(     GetLocalInt(oTarget, "LIGHTABLE")
                        &&  !GetLocalInt(oLeft,"CONTINUAL_FLAME")
                      )
                    {
                        string sLightType   = GetLocalString(oTarget,"LIGHTABLE_TYPE");
                        if( sLightType=="candle" )
                        {
                            DestroyObject(oTarget, fDelay);
                            DelayCommand(fDelay+0.5, RecomputeStaticLighting(oArea) );
                        }
                    }
                }
                // * unlocked doors will reverse their open state
                else if ( nObjType == OBJECT_TYPE_DOOR )
                {
                    if (GetLocked(oTarget) == FALSE)
                    {
                        if (GetIsOpen(oTarget) == FALSE)
                        {
                            AssignCommand(oTarget, ActionOpenDoor(oTarget));
                        }
                        else
                            AssignCommand(oTarget, ActionCloseDoor(oTarget));
                    }
                }
                else if( nObjType == OBJECT_TYPE_CREATURE )
                {
                    oLeft = GetItemInSlot( INVENTORY_SLOT_LEFTHAND, oTarget);
                    if(     GetLocalInt(oLeft,"LIGHTABLE")
                        &&  !GetLocalInt(oLeft,"CONTINUAL_FLAME")
                      )
                    {
                        DelayCommand(fDelay, AssignCommand(oTarget,ActionUnequipItem(oLeft)) );
                    }

//                  if( !MyResistSpell(spell.Caster, oTarget, fDelay)
//                      &&
//                      !MySavingThrow(SAVING_THROW_FORT, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster, fDelay)
//                    )

                    if(GetHasSpellEffect(SPELL_GASEOUS_FORM,oTarget))
                    {
                        DelayCommand(fDelay, FloatingTextStringOnCreature(RED+"The gust of wind shreds your gaseous form.",oTarget,FALSE));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nCasterLvl*d4()), oTarget));

                    }
                    else if(    GetHasSpellEffect(SPELL_FEATHER_FALL,oTarget)
                            ||  !GetIsSkillSuccessful(oTarget, SKILL_DISCIPLINE,
                                                    spell.DC+(GetCreatureSizeModifier(oTarget)*3)
                                                 )
                           )
                    {
                        effect eKnockdown = EffectKnockdown();
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oTarget, RoundsToSeconds(3));
                    // Apply effects to the currently selected target.
                 //   DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    //This visual effect is applied to the target object not the location as above.  This visual effect
                    //represents the flame that erupts on the target not on the ground.
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    }
                }
            }
        }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE |OBJECT_TYPE_AREA_OF_EFFECT);
    }
}
