//::///////////////////////////////////////////////
//:: dmfi_unact_nam02
//:://////////////////////////////////////////////
/*
    completely rewritten to use arnheim's chat event
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 apr 5)
//:: Modified:
//:://////////////////////////////////////////////


void main()
{
    object oPC = GetPCSpeaker(); // user of dmfi wand

    SetLocalInt(oPC, "RECORD_CHAT", TRUE); // sets record mode so that each line of chat of this PC is recorded on the PC
}
