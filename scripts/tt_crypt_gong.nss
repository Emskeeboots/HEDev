void main()
{

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

object oTarget;
oTarget = GetObjectByTag("tt_cryptdoorsopen");
AssignCommand(oTarget, ActionOpenDoor(oTarget));
DelayCommand(58.0, AssignCommand(oTarget, ActionCloseDoor(oTarget)));

oTarget = GetObjectByTag("tt_cryptdoorsopen2");
AssignCommand(oTarget, ActionOpenDoor(oTarget));
DelayCommand(59.0, AssignCommand(oTarget, ActionCloseDoor(oTarget)));

oTarget = GetObjectByTag("tt_cryptdoorsopen3");
AssignCommand(oTarget, ActionOpenDoor(oTarget));
DelayCommand(60.0, AssignCommand(oTarget, ActionCloseDoor(oTarget)));

oTarget = GetObjectByTag("GongRings");

SoundObjectPlay(oTarget);
DelayCommand(1.0, SoundObjectStop(oTarget));

}




