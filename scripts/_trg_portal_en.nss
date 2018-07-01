//::///////////////////////////////////////////////
//:: _trg_portal_en
//:://////////////////////////////////////////////
/*
    intended for use in Trigger Enter

    creates a portal - shadow portal being the default

*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 apr 8)
//:://////////////////////////////////////////////


void main()
{
    object oSelf    = OBJECT_SELF;
    int nCount      = GetLocalInt(oSelf, "ENTER_COUNT")+1;
    SetLocalInt(oSelf, "ENTER_COUNT", nCount);
    if(GetLocalInt(oSelf, "STATE_OPEN")) // if already open exit
        return;

    string sRef     = GetLocalString(oSelf, "PORTAL_REF");
    if(sRef=="")
        sRef        = "portal_shadow";
    effect eVFX     = EffectVisualEffect(VFX_FNF_IMPLOSION);
    int nVFX        = VFX_FNF_SUMMON_UNDEAD; //(set on portal. plays on PC when entering portal)
    // shadow portals open only at night
    if(sRef=="portal_shadow")
    {
        if(GetIsDay()&&!GetLocalInt(oSelf,"PORTAL_DAY_OVERRIDE"))
            return;
        eVFX    = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_GREASE);
        nVFX    = VFX_FNF_GAS_EXPLOSION_GREASE; //(set on portal)
    }

    int bOpen       = TRUE; // default is to open the portal
    string sKey     = GetLocalString(oSelf, "PORTAL_KEY");
    object oPC      = GetEnteringObject();
    // Key -- portals with a "key" only open and stay open when the key is in the trigger
    if(sKey!="")
    {
        bOpen       = FALSE;
        if( GetIsObjectValid(GetItemPossessedBy(oPC, sKey)) )
            bOpen   = TRUE;
        else if(GetLocalInt(oPC, sKey))
            bOpen   = TRUE;
    }

    string sTag     = GetTag(oSelf);
    if(bOpen)
    {
        SetLocalInt(oSelf, "STATE_OPEN", TRUE);
        location lLoc   = GetLocation(GetWaypointByTag("LOC_"+sTag));
        object oPortal  = CreateObject(OBJECT_TYPE_PLACEABLE, sRef, lLoc, TRUE, sTag);
        SetLocalObject(oSelf, "PORTAL_OBJECT", oPortal);
        SetLocalObject(oPortal, "TRIGGER_OBJECT", oSelf);
        SetLocalInt(oPortal, "VFX", nVFX);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lLoc);
    }
}
