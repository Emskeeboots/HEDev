//::///////////////////////////////////////////////
//:: dmfi_unact_nam04
//:://////////////////////////////////////////////
/*
    completely rewritten to use arnheim's chat event

    Cancels recording of chat
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 apr 5)
//:: Modified:
//:://////////////////////////////////////////////


void main()
{
    object oPC = GetPCSpeaker(); // user of dmfi wand

    DeleteLocalInt(oPC, "RECORD_CHAT"); // sets record mode so that each line of chat of this PC is recorded on the PC
    DeleteLocalString(oPC, "CHAT_RECORDED");
}
