//::///////////////////////////////////////////////
//:: _plc_mgck_cast
//:://////////////////////////////////////////////
/*
    OnSpellCastAt for magically created placeables
*/
//:://////////////////////////////////////////////
//:: Created:  The Magus (2011 oct 18)
//:: Modified: The Magus (2012 oct 14)
//:://////////////////////////////////////////////

#include "_inc_spells"

void main()
{
    object oCreator = GetLocalObject(OBJECT_SELF, "CREATOR");
    object oCaster  = GetLastSpellCaster();
    int nSpell      = GetLastSpell();
    int nLevel      = GetCasterLevel(oCaster);
    int nDC         = GetLocalInt(OBJECT_SELF,"LEVEL")+11;

    // handle dispel magic spells
    if(DispelObject(nSpell, nLevel, nDC, oCreator==oCaster))
    {
        string sDestroy = GetLocalString(OBJECT_SELF, "DESTROY_SCRIPT");
        if(sDestroy!="")
            ExecuteScript(sDestroy,OBJECT_SELF);
        else
            DestroyObject(OBJECT_SELF, 1.0);
    }
}
