void main()
{

object oPC = GetEnteringObject();
object oNPC = GetObjectByTag("tt_librarian");

if (!GetIsPC(oPC)) return;

if ((GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC)==0)||
    (GetLevelByClass(CLASS_TYPE_FIGHTER, oPC)==0)||
    (GetLevelByClass(CLASS_TYPE_MONK, oPC)==0))
   {
   AssignCommand(oNPC, SpeakString("Don't ya break anything!"));
   }
else if ((GetLevelByClass(CLASS_TYPE_ROGUE, oPC)>0))
   {
   AssignCommand(oNPC, SpeakString("Don't ya steal anything!"));

   }
else if ((GetLevelByClass(CLASS_TYPE_CLERIC, oPC)>0)||
    (GetLevelByClass(CLASS_TYPE_DRUID, oPC)>0)||
    (GetLevelByClass(CLASS_TYPE_PALADIN, oPC)>0)||
    (GetLevelByClass(CLASS_TYPE_RANGER, oPC)>0))
   {
   AssignCommand(oNPC, SpeakString("*The Librarian keeps a close eye on you*"));

   }
else if ((GetLevelByClass(CLASS_TYPE_SORCERER, oPC)>0))
   {
   AssignCommand(oNPC, SpeakString("Don't put anything on fire!"));

   }
else if ((GetLevelByClass(CLASS_TYPE_BARD, oPC)>0)||
         (GetLevelByClass(CLASS_TYPE_WIZARD, oPC)>0)||
         (GetLevelByClass(CLASS_TYPE_HARPER, oPC)>0))
   {
   AssignCommand(oNPC, SpeakString("Ah, finally some decent people!"));
   }

else
   {
   }
}


