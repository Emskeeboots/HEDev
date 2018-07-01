//::///////////////////////////////////////////////
//:: NW_S3_Alcohol.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Makes beverages fun.
  May 2002: Removed fortitude saves. Just instant intelligence loss
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   February 2002
//:://////////////////////////////////////////////

#include "food_include"

void DrinkIt(object oTarget)
{
   // AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_FIREFORGET_DRINK));
   AssignCommand(oTarget,ActionSpeakStringByStrRef(10499));
}

void MakeDrunk(object oTarget, int nPoints)
{
    if (Random(100) + 1 < 40)
        AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING));
    else
        AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK));

    effect eDumb = EffectAbilityDecrease(ABILITY_INTELLIGENCE, nPoints);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDumb, oTarget, 60.0);
 //   AssignCommand(oTarget, SpeakString(IntToString(GetAbilityScore(oTarget,ABILITY_INTELLIGENCE))));
}
void main()
{
    object oTarget  = GetSpellTargetObject();
    object oItem    = GetSpellCastItem();
    int nSpellId    = GetSpellId();

    CreatureEatsFood(oItem, oTarget);

    int nDC         = GetLocalInt(oItem,"FOOD_INTOXICATE_DC");
    if(!nDC)
        nDC         = d20()+5;

   // SpeakString("here");
    // * Beer
    if( nSpellId== 406)
    {
        DrinkIt(oTarget);
        if(FortitudeSave(oTarget, nDC, SAVING_THROW_TYPE_POISON))
        {
            MakeDrunk(oTarget, 1);
        }
    }
    else
    // *Wine
    if(nSpellId == 407)
    {
        DrinkIt(oTarget);
        if(FortitudeSave(oTarget, nDC, SAVING_THROW_TYPE_POISON))
        {
            MakeDrunk(oTarget, 2);
        }
    }
    else
    // * Spirits
    if(nSpellId == 408)
    {
        DrinkIt(oTarget);
        if(FortitudeSave(oTarget, nDC, SAVING_THROW_TYPE_POISON))
        {
            MakeDrunk(oTarget, 3);
        }
     }

}
