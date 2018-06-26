void main()
{

object oPC = GetEnteringObject();

if (!GetIsPC(oPC)) return;

if (GetLocalInt(oPC, "CutsceneViewed")> 0)
   return;

SetCutsceneMode(oPC, TRUE);

FadeFromBlack(oPC, FADE_SPEED_SLOW);

DelayCommand(2.0, AssignCommand(GetObjectByTag("Brc_ogre2"), ActionSpeakString("INTRUDERS! BEGONE OR BE ANNIHILATED!")));

DelayCommand(3.0, SetCutsceneMode(oPC, FALSE));

DelayCommand(4.0, FadeFromBlack(oPC));

SetLocalInt(oPC, "CutsceneViewed", 1);

}
