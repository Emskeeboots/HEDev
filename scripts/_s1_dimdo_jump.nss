//::///////////////////////////////////////////////
//:: _s1_dimdo_jump
//:://////////////////////////////////////////////
/*
    Execute for teleport

    Jumps User from one location to another

*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2011 oct 16)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_color"

void JumpSelf(location lDest)
{
    location lStart = GetLocation(OBJECT_SELF);

    int nVFX    = 1665; // VFX_IMP_DIMENSION_DOOR  -- was VFX_FNF_SUMMON_UNDEAD

    effect eDimensionDoor = EffectVisualEffect( nVFX, FALSE );
    effect eInvisible = EffectVisualEffect( VFX_DUR_CUTSCENE_INVISIBILITY, FALSE );
    ClearAllActions();
    ActionWait( 0.1f );
    ActionDoCommand( ApplyEffectAtLocation( DURATION_TYPE_INSTANT, eDimensionDoor, lStart, 0.0 ) );
    ActionWait( 0.3f );
    ActionDoCommand( ApplyEffectToObject( DURATION_TYPE_TEMPORARY, eInvisible, OBJECT_SELF, 2.1f ) );
    ActionWait( 0.3f );
    ActionJumpToLocation( lDest );
    ActionWait( 0.3f );
    ActionDoCommand( ApplyEffectAtLocation( DURATION_TYPE_INSTANT, eDimensionDoor, lDest, 0.0 ) );
}

void JumpAssociates(location lDest, object oPortal, int bFamiliar=FALSE)
{
    int nType;
    // loop through every type of associate
    for(nType = 1; nType < 6; nType++)
    {
        int nCount;

        // use pre-increment as associates are 1-based
        object oAssociate = GetAssociate(nType, OBJECT_SELF, ++nCount);
        while(GetIsObjectValid(oAssociate))
        {
            if(GetDistanceBetween(oPortal,oAssociate)<10.0)
            {
                // jump the associate AND the associate's associates
                AssignCommand(oAssociate, JumpSelf(lDest));
                AssignCommand(oAssociate, JumpAssociates(lDest, oPortal));
            }

            // next associate of THIS type
            oAssociate = GetAssociate(nType, OBJECT_SELF, ++nCount);
        }
    }
}

void main()
{
    location lDest  = GetLocalLocation(OBJECT_SELF,"DESTINATION");
    object oPortal  = GetLocalObject(OBJECT_SELF,"PORTAL");
    int bFamiliar   = (oPortal==OBJECT_SELF);
    DeleteLocalLocation(OBJECT_SELF,"DESTINATION");
    DeleteLocalObject(OBJECT_SELF,"PORTAL");

    if(!bFamiliar)
        JumpAssociates(lDest,oPortal);
    JumpSelf(lDest);
    if(bFamiliar)
    {
        object oAssociate = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);
        if(GetDistanceBetween(oPortal,oAssociate)<10.0)
        {
            AssignCommand(oAssociate, JumpSelf(lDest));
        }
    }
}
