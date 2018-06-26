//::///////////////////////////////////////////////
//:: v2_ex_restorehp
//:://////////////////////////////////////////////
/*
    restores hp to a returning player

    Custom Script Systems incorporated:
    Natural Bioware Database Extension (NBDE) by Knat

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2015 dec 20)

//:://////////////////////////////////////////////

#include "_inc_util"
#include "_inc_data"

void main()
{
    if (!GetIsPC(OBJECT_SELF)) return;

    //SendMessageToPC(OBJECT_SELF, "_ex_restorehp: called for " + GetName(OBJECT_SELF) + " isOOC() == " + IntToString(IsOOC()));

    if ( GetArea(OBJECT_SELF)==OBJECT_INVALID || IsOOC() )
    {
        SetLocalInt(OBJECT_SELF, "RESTORE_HP", TRUE);
        DelayCommand(3.0, ExecuteScript("_ex_restorehp", OBJECT_SELF));
    }
    else
    {
        DeleteLocalInt(OBJECT_SELF, "RESTORE_HP");

        // retrieve HP from the DB
        int iDBHP   = Data_GetPCHitPoints(OBJECT_SELF);

        if(MODULE_DEBUG_MODE) {
		string sMsg =  "_ex_restorehp: HP Data("+IntToString(iDBHP)+") Current("+IntToString(GetCurrentHitPoints(OBJECT_SELF))+")";
		//SendMessageToPC(OBJECT_SELF, sMsg);
		WriteTimestampedLogEntry(sMsg);
	}

        // if the character has logged in as dead, flag it so we dont record a dirtnap
        // or reset the actual time that the character died
        if (iDBHP < -9)
        {

            
        //    SetLocalInt(OBJECT_SELF, LOGIN_DEATH, TRUE);
            int iLengthOfDeath = GetTimeCumulative() - StringToInt(Data_GetCampaignString("DEAD", OBJECT_SELF));
            string sReport = GetPCPlayerName(OBJECT_SELF) + " (" + GetName(OBJECT_SELF) + ") logged in dead, and has been dead for " + IntToString(iLengthOfDeath) + " game minutes.";
            WriteTimestampedLogEntry(sReport);
        }


        // ------------ RESTORE THE PC's HP ----------
        SetHitPoints(OBJECT_SELF, iDBHP);
	//WriteTimestampedLogEntry("_ex_restorehp: " + GetName(OBJECT_SELF) + " HP now = " 
	//			 + IntToString(GetCurrentHitPoints(OBJECT_SELF)));
        SetLocalInt(OBJECT_SELF, "RESTORE_HP_INIT", TRUE); // flag to track that we did this
    }
}
