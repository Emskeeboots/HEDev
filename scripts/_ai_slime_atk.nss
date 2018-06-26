//::///////////////////////////////////////////////
//:: _ai_slime_atk
//:://////////////////////////////////////////////
/*
    SLIMES onPhysicallyAttacked - User Defined Event script

    Local Strings on creature
    USERDEF_ATTACKED    = _ai_slime_atk     // this will run on each attack if set on creature

    When physically attacked the slime will divide in half.
    Slimes divide in two until they are too small to divide further.

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2014 feb 9)
//:://////////////////////////////////////////////

void main()
{
    object oAttacker    = GetLocalObject(OBJECT_SELF, "ATTACKED");

    int nAltAppearance  = StringToInt(Get2DAString("appearance_x","ALT_SMALLER",GetAppearanceType(OBJECT_SELF)));
    if(nAltAppearance)
    {
        int nSplit          = GetLocalInt(OBJECT_SELF, "SLIME_SPLIT_MULTIPLIER");
        if(nSplit<2)
            nSplit = 2;

        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(), OBJECT_SELF);

        effect ePoof1 = EffectVisualEffect(VFX_COM_CHUNK_GREEN_MEDIUM);
        effect ePoof2 = EffectVisualEffect(VFX_COM_CHUNK_GREEN_SMALL);

        string sRef     = GetResRef(OBJECT_SELF);
        location lLoc   = GetLocation(OBJECT_SELF);
        int nMaxHP      = GetMaxHitPoints();
        int nDamage     = nMaxHP-(GetCurrentHitPoints()/nSplit);
        if(nDamage>=nMaxHP)
            nDamage     = nMaxHP-1;
        effect eDam     = EffectDamage(nDamage);

        int nHD         = GetHitDice(OBJECT_SELF);
        int nLvlDamage  = GetLocalInt(OBJECT_SELF,"LEVEL_DAMAGE");
            nLvlDamage  = nLvlDamage + ((nHD-nLvlDamage)/nSplit);
        if(nLvlDamage>=nHD)
            nLvlDamage  = nHD-1;
        effect eLvlDam  = EffectNegativeLevel(nLvlDamage);


        // VFX
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, ePoof1, lLoc);

        object oSplit;
        int nSplitHalf  = nSplit/2;
        if(nSplitHalf<2)
            nSplitHalf=2;

        int nIt;

        while(nIt<nSplit)
        {
            oSplit  = CreateObject(OBJECT_TYPE_CREATURE, sRef, lLoc, TRUE);
            SetCreatureAppearanceType(oSplit, nAltAppearance);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDam, oSplit);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLvlDam, oSplit);
            SetLocalInt(oSplit,"LEVEL_DAMAGE",nLvlDamage);
            SetLocalInt(oSplit, "SLIME_SPLIT_MULTIPLIER", nSplitHalf);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, ePoof2, GetLocation(oSplit));

            nIt++;
        }


        ClearAllActions(TRUE);
        DestroyObject(OBJECT_SELF,0.1);
    }
}
