#include "com_source"
///////////////////////////////////////////////////////////////////////////////
/////////////////////Mad Rabbit's Player Chat Commands/////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////Declarations////////////////////////////////////

//Temporarily saves the description of oPC
void MRPCCommandSaveDesc(object oPC);

//Loads the saved description for oPC
void MRPCCommandLoadDesc(object oPC);

//Adds a substring from sCommand to the description of oPC
void MRPCCommandAddDesc(object oPC, string sCommand);

//Deletes the description of oPC
void MRPCCommandDeleteDesc(object oPC);

//Adds a carriage line to the end of oPC's description
void MRPCCommandAddCarriage(object oPC);

//Clears the saved description of oPC
void MRPCCommandClearDesc(object oPC);

//Resets the description of oPC to the orginal one
void MRPCCommandResetDesc(object oPC);

//Shows oPC their description
void MRPCCommandViewDescription(object oPC);

//Displays a list of commands
void MRHelp(object oPC);

///////////////////////////////Definition//////////////////////////////////////

void MRPCCommandSaveDesc(object oPC)
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    string sDesc = GetDescription(oPC);
    SetLocalString(oPC, "PC_COMM_DESC_SAVE", sDesc);
    SendMessageToPC(oPC, "Description Saved");
}

void MRPCCommandLoadDesc(object oPC)
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    string sDesc = GetLocalString(oPC, "PC_COMM_DESC_SAVE");

    if (sDesc == "") {
        SendMessageToPC(oPC, "No Saved Description To Load");
        return;  }

    SetDescription(oPC, sDesc);
    SendMessageToPC(oPC, "Description Loaded");
}

void MRPCCommandAddDesc(object oPC, string sCommand)
{
    int nLength = GetStringLength(sCommand);
    string sAddDesc = GetSubString(sCommand, 9, nLength);
    string sOrgDesc = GetDescription(oPC);
    string sDesc = sOrgDesc + sAddDesc;

    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    if (sOrgDesc == "\n") sDesc = sAddDesc;
    SetDescription(oPC, sDesc);
    SendMessageToPC(oPC, "Description Modified");
}

void MRPCCommandDeleteDesc(object oPC)
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    SetDescription(oPC, "\n");
    SendMessageToPC(oPC, "Description Deleted");
}

void MRPCCommandAddCarriage(object oPC)
{
    string sOrgDesc = GetDescription(oPC);
    string sAddDesc = "\n";
    string sDesc = sOrgDesc + sAddDesc;


    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    SetDescription(oPC, sDesc);
    SendMessageToPC(oPC, "Carriage Line Added To Description");
}

void MRPCCommandClearDesc(object oPC)
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    DeleteLocalString(oPC, "PC_COMM_DESC_SAVE");
    SendMessageToPC(oPC, "Saved Description Cleared");
}

void MRPCCommandResetDesc(object oPC)
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    SetDescription(oPC, "");
    SendMessageToPC(oPC, "Description Reset");
}

void MRPCCommandViewDescription(object oPC)
{
    string sDesc = GetDescription(oPC);

    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    SendMessageToPC(oPC, sDesc);
}

void MRHelp(object oPC)
{
    SendMessageToPC(oPC, "\n");
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    SendMessageToPC(oPC, "DESCRIPTION MODIFICATION COMMANDS");
    SendMessageToPC(oPC, "/dsc sve = Temporarily saves your current description");
    SendMessageToPC(oPC, "/dsc lod = Loads your temporarily saved description");
    SendMessageToPC(oPC, "/dsc clr = Clears your temporarily saved description");
    SendMessageToPC(oPC, "/dsc add DESCRIPTION = Adds DESCRIPTION to the end of your current description.");
    SendMessageToPC(oPC, "/dsc car = Adds a carriage line to the end of your description.");
    SendMessageToPC(oPC, "/dsc del = Deletes your current description");
    SendMessageToPC(oPC, "/dsc rst = Resets your description to the orginal one from character creation");
    SendMessageToPC(oPC, "/dsc pvw = Shows player their description");
    SendMessageToPC(oPC, "\n");
}

////////////////////////////////Main Code//////////////////////////////////////

void main()
{
    object oPC = OBJECT_SELF;
    string sMessage = GetPCChatMessage();
    string sSecondaryCommand = GetSubString(sMessage, 5, 3);

    if (sSecondaryCommand == "sve")
        MRPCCommandSaveDesc(oPC);
    else if (sSecondaryCommand == "lod")
        MRPCCommandLoadDesc(oPC);
    else if (sSecondaryCommand == "clr")
        MRPCCommandClearDesc(oPC);
    else if (sSecondaryCommand == "add")
        MRPCCommandAddDesc(oPC, sMessage);
    else if (sSecondaryCommand == "car")
        MRPCCommandAddCarriage(oPC);
    else if (sSecondaryCommand == "del")
        MRPCCommandDeleteDesc(oPC);
    else if (sSecondaryCommand == "rst")
        MRPCCommandResetDesc(oPC);
    else if (sSecondaryCommand == "pvw")
        MRPCCommandViewDescription(oPC);
    else if (sSecondaryCommand == "hlp")
        MRHelp(oPC);
}
