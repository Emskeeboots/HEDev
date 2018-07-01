//::///////////////////////////////////////////////
//:: _s2_teach
//:://////////////////////////////////////////////
/*
    Spell Script for Feat Teach Character

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 15)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_color"
#include "zdlg_include_i"
#include "_dlg_teach"

void main()
{
    object oStudent = GetSpellTargetObject();
    if(!GetIsObjectValid(oStudent) || GetObjectType(oStudent)!= OBJECT_TYPE_CREATURE)
        return;
    if(oStudent==OBJECT_SELF)
    {
        SendMessageToPC(OBJECT_SELF, DMBLUE+"While you may still have a great deal to learn about yourself,"
                    +" this is not the way to go about it.");
        return;
    }

    if(     GetIsPC(oStudent)
        &&  !GetIsDM(oStudent)
        &&  !GetIsDMPossessed(oStudent)
        &&  !GetIsPossessedFamiliar(oStudent)
      )
    {
        if(     GetLocalInt(oStudent, "IN_CONV")
            ||  IsInConversation(oStudent)
           )
        {
            SendMessageToPC(OBJECT_SELF, " ");
            SendMessageToPC(OBJECT_SELF, PINK+GetName(oStudent)+" is presently occupied. Try later.");
            return;
        }

        SetLocalObject(OBJECT_SELF, "TEACHING_STUDENT", oStudent);
        SetLocalObject(oStudent, "TEACHER", OBJECT_SELF);

        // Initialize Conversation
        string sDialog  = "_dlg_teach";
        int nGreet      = FALSE;
        int nPrivate    = TRUE;
        int nZoom       = FALSE;

        StartDlg( OBJECT_SELF, OBJECT_SELF, sDialog, nPrivate, nGreet, nZoom);
    }
    else
    {
        SendMessageToPC(OBJECT_SELF, " ");
        SendMessageToPC(OBJECT_SELF, RED+"FAILED: Only player characters may receive lessons.");
    }
}
