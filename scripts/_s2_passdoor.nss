//::///////////////////////////////////////////////
//:: _s2_passdoor
//:://////////////////////////////////////////////
/*
    Spell Script for Pass Door

    Transports caster to the door's destination or the otherside of the door

    While obviously mice and some oozes have this ability,
    incorporeal creatures also use this ability instead of opening a door.

    Thanks to LightFoot8 for providing the function: RunRatUnderDoor
    http://forum.bioware.com/topic/251021-get-location-on-opposite-side-of-door/#9063589
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2013 jan 5)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"

#include "_inc_color"
#include "_inc_util"

void RunRatUnderDoor(object oDoor)
{
   // Get the posistion for the rat.
   vector vRat = GetPosition(OBJECT_SELF);

   // Get the position for the door
   vector vDoor = GetPosition(oDoor);

   // Subtract the position of the rat from the position of the door.
   // To get the vector representing the position of the rat from the door.
   // basicly what we are doing is both the rat and the door have (X,Y) positions
   // (Rx,Ry) and (Dx,Dy)
   // if we subtract the position of the rat from both of them in effect moving
   // the line segment to where the rat is at cords (0,0) the
   // (Rx,Ry) - (Rx,Ry) =  (0,0)
   // (Dx,Dy) - (Rx-Ry) =  (Dx-Rx,Dy-Ry)
   // in effect moving the line segment to where the rat is at cords (0,0) the
   // the (Dx-Rx,Dy-Ry) Is in effect the vector showing both distance and
   //Direction that the door is from the rat.
   vector vDoorFromRat = vDoor-vRat;

   //To get the position 1 unit beyond the door in a stright line from where
   // the rat currently is, all we have to do is normilize the vector and add
   // it to the position of the door.
   vector vPastDoor1M = vDoor + VectorNormalize(vDoorFromRat);

   //Build a location with the new vector and have the rat face in the same
   //Direction that the door was from him. .
   location lPastDoor = Location(
                                   GetArea(OBJECT_SELF),
                                   vPastDoor1M,
                                   VectorToAngle(vDoorFromRat)
                                 );

   // Clear rats action que
   ClearAllActions(TRUE);

   //Run to the door
   ActionMoveToObject(oDoor,TRUE);

   //Lay flat
   ActionPlayAnimation( ANIMATION_LOOPING_GET_LOW,1.0,2.0);

   // Squeeze under.
   ActionJumpToLocation(lPastDoor);
}


void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    // End of Spell Cast Hook

    object oDoor    = GetSpellTargetObject();
    int nObjectType = GetObjectType(oDoor);
    if ( !GetIsObjectValid(OBJECT_SELF))
        return;
    else if(nObjectType!=OBJECT_TYPE_DOOR)
    {
        // opportunity to handle secret doors and trap doors
        return;
    }

    if(GetIsOpen(oDoor))
    {
        if(GetIsPC(OBJECT_SELF))
            SendMessageToPC(OBJECT_SELF, RED+"The door is open. Try walking through it instead.");
        return;
    }
    else if(    GetLocalInt(oDoor,"DOOR_NO_PASS")
                    ||
                ( GetLockKeyRequired(oDoor) && !CreatureGetIsIncorporeal() )
            )
    {
        if(GetIsPC(OBJECT_SELF))
            SendMessageToPC(OBJECT_SELF, DMBLUE+"You are unable to find an opening to pass through.");
        return;
    }

    object oDest    = GetTransitionTarget(oDoor);

    SetFacingPoint(GetPosition(oDoor));

    if(GetIsObjectValid(oDest))
    {
        AssignCommand(OBJECT_SELF, ClearAllActions(TRUE) );
        AssignCommand(OBJECT_SELF, ActionPlayAnimation( ANIMATION_LOOPING_GET_LOW,1.0,2.0) );

        if(GetObjectType(oDest)== OBJECT_TYPE_DOOR)
        {
            vector vNewPos;
            float fFace = GetFacing(oDest);

            if (fFace<180.0)
                fFace=fFace+179.9;
            else
                fFace=fFace-179.9;

        //AngleToVector(fFace) will give you the a vector that is already normilized with a length of 1.
        // From there all you need to do is add it to the position of the door.
            vNewPos = GetPosition(oDest) +  AngleToVector(fFace);
            location lPastDoor = Location(
                                    GetArea(oDest),
                                    vNewPos,
                                    fFace
                                );
            AssignCommand(OBJECT_SELF, ActionJumpToLocation(lPastDoor) );
        }
        else
            AssignCommand(OBJECT_SELF, ActionJumpToObject(oDest) );

    }
    else
    {
        RunRatUnderDoor(oDoor);
    }
}
