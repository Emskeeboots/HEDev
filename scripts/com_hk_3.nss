// get tight with nearest person, PC's back against target's front.

// the #include below is for the MoveToNewLocation command
#include "x0_i0_position"

void main()
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);

    object oPC = OBJECT_SELF ;
    object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oPC) ;

    // get facing of oTarget, set oPC's facing to match
    float fTargetface = GetFacing(oTarget);
    float fPCFace = fTargetface ;

    // Tweaking oTarget's facing vector angle to line up PCs better
    // fTargetface = GetNormalizedDirection(fTargetface - 60.0);

    // figure out location we want to move to
    // this is oTarget's position displaced by 0.0*(oTarget's's facing vector)
    object oArea = GetArea(oPC);
    vector posDest = GetPosition(oTarget) + AngleToVector(fTargetface)*0.30;
    location lDest = Location(oArea, posDest, fPCFace);
    MoveToNewLocation ( lDest, oPC);

}
