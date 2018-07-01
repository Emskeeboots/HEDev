//::///////////////////////////////////////////////
//:: _trg_portal_ex
//:://////////////////////////////////////////////
/*
    intended for use in Trigger Exit

    may destroy a portal - shadow portal being the default

*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 apr 8)
//:://////////////////////////////////////////////


void main()
{
    object oSelf    = OBJECT_SELF;
    int nCount      = GetLocalInt(oSelf, "ENTER_COUNT")-1;
    if(nCount<0){nCount=0;}
    SetLocalInt(oSelf, "ENTER_COUNT", nCount);

    if(!GetLocalInt(oSelf, "STATE_OPEN")) // if already closed exit
        return;

    object oPortal  = GetLocalObject(oSelf, "PORTAL_OBJECT");
    string sKey     = GetLocalString(oSelf, "PORTAL_KEY");
    object oPC      = GetExitingObject();
    int bClose      = FALSE;
    if(!nCount)
        bClose      = TRUE;
    // Key -- portals with a "key" only open and close when the key is in the trigger
    else if(sKey!="")
    {
        if( GetIsObjectValid(GetItemPossessedBy(oPC, sKey)) )
            bClose  = TRUE;
    }

    if(bClose)
    {
        DeleteLocalInt(oSelf, "STATE_OPEN");
        DeleteLocalObject(oSelf, "PORTAL_OBJECT");
        DestroyObject(oPortal, 1.0);
    }
}
