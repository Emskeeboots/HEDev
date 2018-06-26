// placable onused to start conversation with the PC
// Put this in onUsed and create a conversation file
// named "<this tag>". Or use z-dialog and set
// the dialog string variable to that.

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetIsPC(oPC)) return;

    // check if this is a zdialog user
    string sConv = "zdlg_converse";
    string sDlg = GetLocalString(OBJECT_SELF, "dialog");

    // otherwise look for a dialog named for the tag
    if (sDlg == "")
        sConv = GetTag(OBJECT_SELF); // + "_conv";

    ActionStartConversation(oPC, sConv, TRUE, FALSE);
}
