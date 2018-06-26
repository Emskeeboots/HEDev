void StopFadingMadness(object oPC)
{
    SetCutsceneMode(oPC, FALSE);
    SetCameraMode(oPC, CAMERA_MODE_TOP_DOWN);
    StopFade(oPC);
}

void DMJump(location lTarget)
{
    ClearAllActions(TRUE);
    ActionJumpToLocation(lTarget);

}


void main()
{

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

object oTarget;
location lTarget;
oTarget = GetWaypointByTag("tt_lobbyarrive");

lTarget = GetLocation(oTarget);
  if(!GetIsDM(oPC))
  {
    SetCutsceneMode(oPC, TRUE);
    SetCameraMode(oPC, CAMERA_MODE_CHASE_CAMERA);

    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM8));
    DelayCommand(4.0, FadeToBlack(oPC, FADE_SPEED_SLOW));


    DelayCommand(7.0, AssignCommand(oPC, ActionJumpToLocation(lTarget)));
    DelayCommand(8.0, StopFadingMadness(oPC));
  }
  else
  {
    AssignCommand(oPC, DMJump(lTarget));
  }
}
