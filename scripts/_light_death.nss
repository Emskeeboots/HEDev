//::///////////////////////////////////////////////
//:: _light_death
//:://////////////////////////////////////////////
/*
    Death Event for a light placeable

*/
//:://////////////////////////////////////////////
//:: Created: henesua (2016 jan 1)
//:://////////////////////////////////////////////

void main()
{
    object oArea    = GetArea(OBJECT_SELF);
    AssignCommand(oArea, DelayCommand(2.4, RecomputeStaticLighting(oArea)) );
    object oPair    = GetLocalObject(OBJECT_SELF, "PAIRED");
    object oSource  = GetLocalObject(OBJECT_SELF, "LIGHT_OBJECT");
    SetLocalInt(oSource, "NW_L_AMION", 0);
    if(GetIsObjectValid(oPair))
        DestroyObject(oPair);
    DestroyObject(OBJECT_SELF);
}
