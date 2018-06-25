// the #include below is for the MoveToNewLocationcommand
#include "x0_i0_position"

void main()
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);

    object oPC = OBJECT_SELF ;
    object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oPC) ;

    // get facing of oTarget, set oPC facing to 180 from that
    float fTargetface = GetFacing(oTarget);
    float fPCFace = GetOppositeDirection(fTargetface);

    // Tweaking to line up PCs better
    fTargetface = GetNormalizedDirection(fTargetface - 5.0);
    //fPCFace = GetNormalizedDirection(fPCFace + 10.0);

    // figure out location we want to move to
    // this is oTarget's position displaced by 0.0*(oTarget's's facing vector)
    object oArea = GetArea(oPC);
    vector posDest = GetPosition(oTarget) + AngleToVector(fTargetface)*0.5;
    location lDest = Location(oArea, posDest, fPCFace);
    MoveToNewLocation ( lDest, oPC);

    // perform animation
    DelayCommand( 2.0, AssignCommand( oPC, ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM11, 1.0, 60000.0)));


}
