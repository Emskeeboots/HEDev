//::///////////////////////////////////////////////
//:: _s1_dimdo_dest
//:://////////////////////////////////////////////
/*
    Destroy Script for Dimensional Door

    Destroys both dimensional doors

*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2011 oct 16)
//:: Modified:
//:://////////////////////////////////////////////

void main()
{
    object oDest    = GetLocalObject(OBJECT_SELF,"DESTINATION");

    // Garbage Collection
    object oCaster  = GetLocalObject(OBJECT_SELF,"CREATOR");
    object oGarbage = GetLocalObject(oCaster, "CONCENTRATION");
    if(oGarbage == OBJECT_SELF || oGarbage == oDest)
        DeleteLocalObject(oCaster, "CONCENTRATION");
                                                 // VFX_FNF_MYSTICAL_EXPLOSION
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL), GetLocation(OBJECT_SELF));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL), GetLocation(oDest));

    SetLocalInt(OBJECT_SELF,"bDESTROY", TRUE);
    SetLocalInt(oDest,"bDESTROY", TRUE);

    DestroyObject(oDest, 1.0);
    DestroyObject(OBJECT_SELF, 1.1);
}
