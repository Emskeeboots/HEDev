/*   Script generated by
Lilac Soul's NWN Script Generator, v. 2.3

For download info, please visit:
http://nwvault.ign.com/View.php?view=Other.Detail&id=4683&id=625    */

//Put this on action taken in the conversation editor
void main()
{

object oPC = GetPCSpeaker();


if (GetGold(oPC) >= 500)
    {
        AssignCommand(oPC, TakeGoldFromCreature(500, oPC, TRUE));
        CreateItemOnObject("tt_libcard", oPC);
    }
    else
     {
          AssignCommand(GetObjectByTag("tt_librarian"), ActionSpeakString("No gold, no certificate! Don't try and fool me!"));
     }

}






