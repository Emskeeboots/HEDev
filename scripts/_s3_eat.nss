//::///////////////////////////////////////////////
//:: _s3_eat
//:://////////////////////////////////////////////
/*
    item based spell script for eating something
*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2016 jan 8)
//:: Modified:
//:://////////////////////////////////////////////

#include "food_include"


void main()
{
    object oEater   = GetSpellTargetObject();
    object oFood    = GetSpellCastItem();

    CreatureEatsFood(oFood, oEater);
}
