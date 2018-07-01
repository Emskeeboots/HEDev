//::///////////////////////////////////////////////
//:: dmfi_unact_nam05
//:://////////////////////////////////////////////
/*
    completely rewritten to use arnheim's chat event

    sets creature name
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 apr 5)
//:: Modified:
//:://////////////////////////////////////////////


void main()
{
    object oPC = GetPCSpeaker(); // user of dmfi wand
    object oTarget = GetLocalObject(oPC, "dmfi_univ_target");

    SetName(oTarget, GetLocalString(oPC, "CHAT_RECORDED"));
    DeleteLocalInt(oPC, "RECORD_CHAT"); // sets record mode so that each line of chat of this PC is recorded on the PC
    DeleteLocalString(oPC, "CHAT_RECORDED");
}
