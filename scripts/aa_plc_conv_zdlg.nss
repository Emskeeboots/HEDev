//::///////////////////////////////////////////////
//:: aa_plc_conv_zdlg
//:://////////////////////////////////////////////
/*
    OnUsed event of a useable placeable, not static

    Cause a placeable object to start a private
    conversation with the PC - using ZDLG

    ZDLG conversations are defined by script
    Dialog script set as a Local String on the placeable
        "dialog"        string  <name of dialog script>

    Settings - using local vars
        "dialog_public" int     1   // if you want the conversation to public/hearable
        "dialog_greet"  int     1   // if you want the greeting animation to play
        "dialog_paired" int     1   // if you want the conversation to happen with the "PAIRED" object
*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2012 feb 14)
//:: Modified:  The Magus (2012 oct 24) added ability to converse with "PAIRED" object
//:://////////////////////////////////////////////

#include "zdlg_include_i"

void main()
{
  if(GetHasInventory(OBJECT_SELF) && GetLocalInt(OBJECT_SELF, "CONVERSATION_SUPRESSED"))
  {
    DeleteLocalInt(OBJECT_SELF, "CONVERSATION_SUPRESSED");
  }
  else
  {
    object oPlayer  = GetLastUsedBy();
    string sDialog  = GetLocalString(OBJECT_SELF, "dialog");
    int nGreet      = GetLocalInt(OBJECT_SELF, "dialog_greet");
    int nPublic     = GetLocalInt(OBJECT_SELF, "dialog_public");
    int nZoom       = GetLocalInt(OBJECT_SELF, "dialog_zoom");

    int nPrivate    = TRUE;
    if(nPublic)
        nPrivate    = FALSE;

    if(!GetLocalInt(OBJECT_SELF, "dialog_paired"))
    {
        StartDlg( oPlayer, OBJECT_SELF, sDialog, nPrivate, nGreet, nZoom);
    }
    else
    {
        int nActive    = GetLocalInt(OBJECT_SELF, "NW_L_AMION");
        SendMessageToPC(oPlayer, GetName(OBJECT_SELF)+" active("+IntToString(nActive)+")");
        StartDlg( oPlayer, GetLocalObject(OBJECT_SELF,"PAIRED"), sDialog, nPrivate, nGreet, nZoom);
        if(nActive)
            PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
    }
  }
}
