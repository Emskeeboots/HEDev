//::///////////////////////////////////////////////
//:: _s3_shoe
//:://////////////////////////////////////////////
/*
    Shoe "grenade" Spell

    Throw a shoe at a target and knock them out if you hit and they fail a save

*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2013 jan 30) modified thunderstone grenade script to work for a thrown shoe
//:://////////////////////////////////////////////

#include "X0_I0_SPELLS"

void main()
{
    // modify as you see fit
    int nDuration   = 2;
    int nDC         = 12;

    object oTarget = GetSpellTargetObject();

    if (oTarget!=OBJECT_INVALID)
    {
        // perform ranged touch atack
        int nTouch  = TouchAttackRanged(oTarget, TRUE);
        // signal event - hostile if touch hits, non-hostile if missed
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), nTouch));

        if(nTouch)
        {
            float fShake    = 1.0;
            // if this is a critical hit, it is a DOOZIE
            // add 10 to the DC, and double the duration of the sleep and screen shake
            if(nTouch==2)
            {
                nDC         += 10;
                nDuration   *= 2;
                fShake      *= 2;
            }

            // shake the targets screen
            effect eShake   = EffectVisualEffect(VFX_FNF_SCREEN_BUMP);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShake, oTarget, fShake);

            if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC))
            {

                switch(d4())
                {
                    case 0:AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK));break;
                    case 1:AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_SPASM));break;
                    case 2:AssignCommand(oTarget, PlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, RoundsToSeconds(nDuration)));break;
                    case 3:AssignCommand(oTarget, PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, RoundsToSeconds(nDuration)));break;
                    default:AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_TAUNT));break;
                }

                effect eVis     = EffectVisualEffect(VFX_COM_HIT_SONIC);
                effect eStruck  = ExtraordinaryEffect(
                                                        EffectLinkEffects(
                                                                            EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED),
                                                                            EffectStunned()
                                                                         )
                                                     );


                // Apply effects to the currently selected target.
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStruck, oTarget, RoundsToSeconds(nDuration));
                //This visual effect is applied to the target object not the location as above.
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
            else
            {
                AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_TAUNT));
            }
        }
        else
        {
            switch(d3())
            {
                case 0:AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK));break;
                case 1:AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_DODGE_SIDE));break;
                case 2:AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_TAUNT));break;
                default:AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK));break;
            }

        }
    }
}
