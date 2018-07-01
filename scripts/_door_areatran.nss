#include "x3_inc_horse"
#include "x0_inc_henai"


void main()
{
    object oClicker=GetClickingObject();
    object oTarget=GetTransitionTarget(OBJECT_SELF);
    location lPreJump=HORSE_SupportGetMountLocation(oClicker,oClicker,0.0); // location before jump
    int bAnim=!GetLocalInt(OBJECT_SELF,"bDismountFast"); // negation is the only difference from NW_G0_Transition (= animated dismount for transitions if variable is not set)
    int nN=1;
    object oOb;
    object oAreaHere=GetArea(oClicker);
    object oAreaTarget=GetArea(oTarget);
    object oHitch;
    int bDelayedJump=FALSE;
    int bNoMounts=FALSE;
    float fX3_MOUNT_MULTIPLE=GetLocalFloat(GetArea(oClicker),"fX3_MOUNT_MULTIPLE");
    float fX3_DISMOUNT_MULTIPLE=GetLocalFloat(GetArea(oClicker),"fX3_DISMOUNT_MULTIPLE");
    if (GetLocalFloat(oClicker,"fX3_MOUNT_MULTIPLE")>fX3_MOUNT_MULTIPLE) fX3_MOUNT_MULTIPLE=GetLocalFloat(oClicker,"fX3_MOUNT_MULTIPLE");
    if (fX3_MOUNT_MULTIPLE<=0.0) fX3_MOUNT_MULTIPLE=1.0;
    if (GetLocalFloat(oClicker,"fX3_DISMOUNT_MULTIPLE")>0.0) fX3_DISMOUNT_MULTIPLE=GetLocalFloat(oClicker,"fX3_DISMOUNT_MULTIPLE");
    if (fX3_DISMOUNT_MULTIPLE>0.0) fX3_MOUNT_MULTIPLE=fX3_DISMOUNT_MULTIPLE; // use dismount multiple instead of mount multiple
    float fDelay=0.1*fX3_MOUNT_MULTIPLE;
    //SendMessageToPC(oClicker,"nw_g0_transition");
    if (!GetLocalInt(oAreaTarget,"X3_MOUNT_OK_EXCEPTION"))
    { // check for global restrictions
        if (GetLocalInt(GetModule(),"X3_MOUNTS_EXTERNAL_ONLY")&&GetIsAreaInterior(oAreaTarget)) bNoMounts=TRUE;
        else if (GetLocalInt(GetModule(),"X3_MOUNTS_NO_UNDERGROUND")&&!GetIsAreaAboveGround(oAreaTarget)) bNoMounts=TRUE;
    } // check for global restrictions
    if (GetLocalInt(oAreaTarget,"X3_NO_MOUNTING")||GetLocalInt(oAreaTarget,"X3_NO_HORSES")||bNoMounts)
    { // make sure all transitioning are not mounted
       //SendMessageToPC(oClicker,"nw_g0_transition:No Mounting");
        if (HorseGetIsMounted(oClicker))
        { // dismount clicker
            bDelayedJump=TRUE;
            AssignCommand(oClicker,HORSE_SupportDismountWrapper(bAnim,TRUE));
            fDelay=fDelay+0.2*fX3_MOUNT_MULTIPLE;
        } // dismount clicker
        oOb=GetAssociate(ASSOCIATE_TYPE_HENCHMAN,oClicker,nN);
        while(GetIsObjectValid(oOb))
        { // check each associate to see if mounted
            if (HorseGetIsMounted(oOb))
            { // dismount associate
                bDelayedJump=TRUE;
                DelayCommand(fDelay,AssignCommand(oOb,HORSE_SupportDismountWrapper(bAnim,TRUE)));
                fDelay=fDelay+0.2*fX3_MOUNT_MULTIPLE;
            } // dismount associate
            nN++;
            oOb=GetAssociate(ASSOCIATE_TYPE_HENCHMAN,oClicker,nN);
        } // check each associate to see if mounted
        if (fDelay>0.1) SendMessageToPCByStrRef(oClicker,111989);
        if (bDelayedJump)
        { // some of the party has/have been mounted, so delay the time to hitch
            fDelay=fDelay+2.0*fX3_MOUNT_MULTIPLE; // non-animated dismount lasts 1.0+1.0=2.0 by default, so wait at least that!
            if (bAnim) fDelay=fDelay+2.8*fX3_MOUNT_MULTIPLE; // animated dismount lasts (X3_ACTION_DELAY+HORSE_DISMOUNT_DURATION+1.0)*fX3_MOUNT_MULTIPLE=4.8 by default, so wait at least that!
        } // some of the party has/have been mounted, so delay the time to hitch
    } // make sure all transitioning are not mounted
    if (GetLocalInt(oAreaTarget,"X3_NO_HORSES")||bNoMounts)
    { // make sure no horses/mounts follow the clicker to this area
        //SendMessageToPC(oClicker,"nw_g0_transition:No Horses");
        bDelayedJump=TRUE;
        oHitch=GetNearestObjectByTag("X3_HITCHING_POST",oClicker);
        DelayCommand(fDelay,HorseHitchHorses(oHitch,oClicker,lPreJump));
       if (bAnim) fDelay=fDelay+1.8*fX3_MOUNT_MULTIPLE;
        //fDelay=fDelay+0.5*fX3_MOUNT_MULTIPLE; // delays jump to transition, makes you stay longer before jump
    } // make sure no horses/mounts follow the clicker to this area

    //SendMessageToPC(oClicker,"nw_g0_transition:Jump  fDelay="+FloatToString(fDelay));
    SetAreaTransitionBMP(AREA_TRANSITION_RANDOM);

    //if (GetArea(oTarget)!=GetArea(oClicker)) DelayCommand(fDelay,AssignCommand(oClicker,ForceJump(oClicker,oTarget,5.0)));
    //else { DelayCommand(fDelay,AssignCommand(oClicker,ForceJump(oClicker,oTarget,5.0))); }
    if (bDelayedJump)
    { // delayed jump
        DelayCommand(fDelay,AssignCommand(oClicker,ClearAllActions()));
        //DelayCommand(fDelay+0.05*fX3_MOUNT_MULTIPLE,AssignCommand(oClicker,ActionWait(X3_ACTION_DELAY/2*fX3_MOUNT_MULTIPLE)));
        DelayCommand(fDelay+0.1*fX3_MOUNT_MULTIPLE,AssignCommand(oClicker,JumpToObject(oTarget)));
    } // delayed jump
    else
    { // quick jump
        AssignCommand(oClicker,JumpToObject(oTarget));
    } // quick jump
    DelayCommand(fDelay+4.0*fX3_MOUNT_MULTIPLE,HorseMoveAssociates(oClicker));
}



//::///////////////////////////////////////////////
//:: _door_areatran
//:://////////////////////////////////////////////
/*
    Modified: X3_G0_Transition.nss
    intended for use in a doors onAreaTransitionClick event

// Description: This is the default script that is called
//              if no OnClick script is specified for an
//              Area Transition Trigger or
//              if no OnAreaTransitionClick script is
//              specified for a Door that has a LinkedTo
//              Destination Type other than None.

*/
//:://////////////////////////////////////////////
//:: Created: Sydney Tang (2001-10-26)
//:: Modified: Deva Winblood (Apr 12th, 2008) Added Support for Keeping mounts out of no mount areas
//:: Modified: Sunjammer (28 Aug 2006) rewritten
//:: Modified: Sunjammer (25 Sep 2006) fixed issue caused by using JumpToLocation with door transitions
//:: Modified: The Magus (2012 may 6) limit associates to those nearer than 10m OR fliers outdoors
//:://////////////////////////////////////////////

//#include "x3_inc_horse"
//#include "x0_inc_henai"
/*
#include "_inc_util"

// -----------------------------------------------------------------------------
//  GLOBALS
// -----------------------------------------------------------------------------

// number of associate types (including ASSOCIATE_TYPE_NONE)
const int NUM_ASSOCIATE_TYPES = 6;
int bOutdoors   = FALSE;

// -----------------------------------------------------------------------------
//  PROTOTYPES
// -----------------------------------------------------------------------------

// Jumps all of the caller's associates to the location of an object. The action
// is added to the top of the action queue.
//  - oDestination:     object to jump to
void JumpAssociatesToObject(object oDestination, object oTransition);


// -----------------------------------------------------------------------------
//  FUNCTIONS
// -----------------------------------------------------------------------------

void JumpAssociatesToObject(object oDestination, object oTransition)
{
    object oClicker = OBJECT_SELF;
    int nType;

    // loop through every type of associate
    for(nType = 1; nType < NUM_ASSOCIATE_TYPES; nType++)
    {
        int nCount;

        // use pre-increment as associates are 1-based
        object oAssociate = GetAssociate(nType, oClicker, ++nCount);
        while(GetIsObjectValid(oAssociate))
        {
            if((GetDistanceBetween(oTransition,oAssociate)<10.0)
                ||
               (bOutdoors && CreatureGetIsFlier(oAssociate))
              )
            {
                // jump the associate AND the associate's associates
                AssignCommand(oAssociate, JumpToObject(oDestination));
                AssignCommand(oAssociate, JumpAssociatesToObject(oDestination, oTransition));
            }

            // next associate of THIS type
            oAssociate = GetAssociate(nType, oClicker, ++nCount);
        }
    }
}

void main()
{
    object oClicker = GetClickingObject();
    object oDest    = GetTransitionTarget(OBJECT_SELF);
    object oArea1   = GetArea(oClicker);
    object oArea2   = GetArea(oDest);

    // Enable pursuit - by providing transition to go to
    SetLocalObject(oClicker, "TRANSITION_LAST", OBJECT_SELF);
    SetLocalLocation(oClicker,"TRANSITION_LAST", GetLocation(OBJECT_SELF));

    // bOutdoors is a global accessed by JumpAssociatesToObject
    if(!GetIsAreaInterior(oArea1)&&!GetIsAreaInterior(oArea2))
        bOutdoors = TRUE;
    else
        bOutdoors = GetLocalInt(OBJECT_SELF,"FLIERS_FOLLOW");

    if(GetIsObjectValid(oDest))
    {
        SetAreaTransitionBMP(AREA_TRANSITION_RANDOM);

        // jump the clicker and all their associates
        // NOTE: will not effect another PC nor their associates
        AssignCommand(oClicker, JumpToObject(oDest));
        AssignCommand(oClicker, JumpAssociatesToObject(oDest, OBJECT_SELF));
    }

    /*
    object oMod     = GetModule();
    int bDelayedJump= FALSE;
    location lPreJump= HORSE_SupportGetMountLocation(oClicker,oClicker,0.0); // location before jump
    int bAnim       = !GetLocalInt(OBJECT_SELF,"bDismountFast"); // negation is the only difference from NW_G0_Transition (= animated dismount for transitions if variable is not set)
    int nN          = 1;
    object oOb;

    object oHitch;
    int bNoMounts   = FALSE;
    float fX3_MOUNT_MULTIPLE= GetLocalFloat(oArea1,"fX3_MOUNT_MULTIPLE");
    float fX3_DISMOUNT_MULTIPLE= GetLocalFloat(oArea1,"fX3_DISMOUNT_MULTIPLE");
    if (GetLocalFloat(oClicker,"fX3_MOUNT_MULTIPLE") > fX3_MOUNT_MULTIPLE)
        fX3_MOUNT_MULTIPLE = GetLocalFloat(oClicker,"fX3_MOUNT_MULTIPLE");
    if (fX3_MOUNT_MULTIPLE<=0.0)
        fX3_MOUNT_MULTIPLE = 1.0;
    if (GetLocalFloat(oClicker,"fX3_DISMOUNT_MULTIPLE")>0.0)
        fX3_DISMOUNT_MULTIPLE = GetLocalFloat(oClicker,"fX3_DISMOUNT_MULTIPLE");
    if (fX3_DISMOUNT_MULTIPLE>0.0)
        fX3_MOUNT_MULTIPLE=fX3_DISMOUNT_MULTIPLE; // use dismount multiple instead of mount multiple
    float fDelay=0.1*fX3_MOUNT_MULTIPLE;
    if (!GetLocalInt(oArea2,"X3_MOUNT_OK_EXCEPTION"))
    { // check for global restrictions
        if (GetLocalInt(oMod,"X3_MOUNTS_EXTERNAL_ONLY") && GetIsAreaInterior(oArea2))
            bNoMounts = TRUE;
        else if (GetLocalInt(oMod,"X3_MOUNTS_NO_UNDERGROUND") && !GetIsAreaAboveGround(oArea2))
            bNoMounts=TRUE;
    } // check for global restrictions
    if (GetLocalInt(oArea2,"X3_NO_MOUNTING")||GetLocalInt(oArea2,"X3_NO_HORSES")||bNoMounts)
    { // make sure all transitioning are not mounted
       //SendMessageToPC(oClicker,"nw_g0_transition:No Mounting");
        if (HorseGetIsMounted(oClicker))
        { // dismount clicker
            bDelayedJump=TRUE;
            AssignCommand(oClicker,HORSE_SupportDismountWrapper(bAnim,TRUE));
            fDelay=fDelay+0.2*fX3_MOUNT_MULTIPLE;
        } // dismount clicker
        oOb=GetAssociate(ASSOCIATE_TYPE_HENCHMAN,oClicker,nN);
        while(GetIsObjectValid(oOb))
        { // check each associate to see if mounted
            if (HorseGetIsMounted(oOb))
            { // dismount associate
                bDelayedJump=TRUE;
                DelayCommand(fDelay,AssignCommand(oOb,HORSE_SupportDismountWrapper(bAnim,TRUE)));
                fDelay=fDelay+0.2*fX3_MOUNT_MULTIPLE;
            } // dismount associate
            nN++;
            oOb=GetAssociate(ASSOCIATE_TYPE_HENCHMAN,oClicker,nN);
        } // check each associate to see if mounted
        if (fDelay>0.1) SendMessageToPCByStrRef(oClicker,111989);
        if (bDelayedJump)
        { // some of the party has/have been mounted, so delay the time to hitch
            fDelay=fDelay+2.0*fX3_MOUNT_MULTIPLE; // non-animated dismount lasts 1.0+1.0=2.0 by default, so wait at least that!
            if (bAnim) fDelay=fDelay+2.8*fX3_MOUNT_MULTIPLE; // animated dismount lasts (X3_ACTION_DELAY+HORSE_DISMOUNT_DURATION+1.0)*fX3_MOUNT_MULTIPLE=4.8 by default, so wait at least that!
        } // some of the party has/have been mounted, so delay the time to hitch
    } // make sure all transitioning are not mounted
    if (GetLocalInt(oArea2,"X3_NO_HORSES")||bNoMounts)
    { // make sure no horses/mounts follow the clicker to this area
        bDelayedJump=TRUE;
        oHitch=GetNearestObjectByTag("X3_HITCHING_POST",oClicker);
        DelayCommand(fDelay,HorseHitchHorses(oHitch,oClicker,lPreJump));
       if (bAnim) fDelay=fDelay+1.8*fX3_MOUNT_MULTIPLE;
    } // make sure no horses/mounts follow the clicker to this area

    SetAreaTransitionBMP(AREA_TRANSITION_RANDOM);

    if (bDelayedJump)
    { // delayed jump
        DelayCommand(fDelay,AssignCommand(oClicker,ClearAllActions()));
        DelayCommand(fDelay+0.1*fX3_MOUNT_MULTIPLE,AssignCommand(oClicker,JumpToObject(oDest)));
    } // delayed jump
    else
    { // quick jump
        AssignCommand(oClicker,JumpToObject(oDest));
    } // quick jump
    DelayCommand(fDelay+4.0*fX3_MOUNT_MULTIPLE,HorseMoveAssociates(oClicker));

}
 */
