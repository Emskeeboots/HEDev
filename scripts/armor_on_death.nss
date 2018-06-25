/*
    Merricksdad's Gem Container OnDeath Script

    This script causes the linked invisible container to destroy
    itself, preventing duplication of items.
*/

void main()
{

    //This part from Kinarr Graycloak's scripts

    // Keep merchants and other armor stands from going hostile
    object oPC = GetLastAttacker();
    SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oPC);

    // Don't fade
    SetIsDestroyable(FALSE,FALSE,TRUE);

    //end Kinarr's


    //destroy my child container and its contents
    object myChild = GetLocalObject(OBJECT_SELF,"md_gemchild");
    if (GetIsObjectValid(myChild)){
        DestroyObject(myChild);
        DeleteLocalObject(OBJECT_SELF,"md_gemchild");
    }


}
