//::///////////////////////////////////////////////
//:: _s3_drink
//:://////////////////////////////////////////////
//::original:
//:: NW_S3_Alcohol.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Makes beverages fun.
  May 2002: Removed fortitude saves. Just instant intelligence loss

*/
//:://////////////////////////////////////////////
//:: Created:   Brent (February 2002)
//:: Modified:  henesua (2016 jan 8)
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
    object oDrink   = GetSpellCastItem();
    int nSpellId    = GetSpellId();

    CreatureEatsFood(oDrink, oTarget);

    int nDC         = GetLocalInt(oDrink,"FOOD_INTOXICATE_DC");
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
     else
     // * Non-alcoholic drinks
     if(nSpellId==997)
     {


     }
}
