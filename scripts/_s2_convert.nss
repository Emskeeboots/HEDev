//::///////////////////////////////////////////////
//:: _s2_convert
//:://////////////////////////////////////////////
/*
    Spell Script for Feat Convert


*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 17)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_deity"

#include "zdlg_include_i"

void main()
{
    if(!GetHasFeat(2010, OBJECT_SELF))
        return;

    object oConvert = GetSpellTargetObject();
    if(!GetIsObjectValid(oConvert) || GetObjectType(oConvert)!= OBJECT_TYPE_CREATURE)
        return;

    int nDeity      = GetDeityIndex(OBJECT_SELF);
    if(GetIsPC(oConvert) && nDeity!=0)
    {
        SetLocalObject(oConvert, "CONVERSION_PRIEST", OBJECT_SELF);

        // Initialize Conversation
        string sDialog  = "_dlg_convert";
        int nGreet      = FALSE;
        int nPrivate    = FALSE;
        int nZoom       = TRUE;

        StartDlg( OBJECT_SELF, OBJECT_SELF, sDialog, nPrivate, nGreet, nZoom);

        // old conversation - replaced with z-dialog
        //AssignCommand(oConvert, ActionStartConversation(oConvert, "aa_convert", TRUE, FALSE));
    }
}
