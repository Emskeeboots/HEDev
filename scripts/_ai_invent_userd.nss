//::///////////////////////////////////////////////
//:: _ai_invent_userd
//:://////////////////////////////////////////////
/*
    Userdef AI for the persistent inventory

 */
//:://////////////////////////////////////////////////
//:: Created: henesua (2016 july 11)
//:://////////////////////////////////////////////////

#include "_inc_constants"
//#include "_inc_util"
#include "_inc_data"

#include "nw_i0_generic"
// Bioware
//const int EVENT_USER_DEFINED_PRESPAWN       = 1510;
//const int EVENT_USER_DEFINED_POSTSPAWN      = 1511;

void CommitSelfToDB()
{
    if(GetLocalInt(OBJECT_SELF, "INVENTORY_COMMIT")) {
	    DeleteLocalInt(OBJECT_SELF, "INVENTORY_COMMIT");
	    //Data_SaveCampaignObject(OBJECT_SELF);
	    SetPersistentObject(GetModule(), "inventory", OBJECT_SELF,  GetLocalString(OBJECT_SELF,"OWNER_PCID"));
    }
}

void CleanUp()
{
    if(GetLocalInt(OBJECT_SELF, "CANCEL_CLEANUP")) {
	    DeleteLocalInt(OBJECT_SELF,"CANCEL_CLEANUP");
	    return;
    }

    if(!GetLocalInt(OBJECT_SELF, "INVENTORY_COMMIT")) {
	    DestroyObject(OBJECT_SELF);
	    // Here we should remove self from DB if PERMANENT_DELETION is set?
    } else {
	    DelayCommand(5.5, CleanUp());
    }
}

void main()
{
    if(GetIsDMPossessed(OBJECT_SELF))
        return;

    int nUser = GetUserDefinedEventNumber();

    if(nUser==EVENT_COMMIT_OBJECT_TO_DB) {
	    db("INVENTORY: Got COMMIT_OBJECT_TO_DB owner = " + GetLocalString(OBJECT_SELF,"OWNER_PCID") 
	       + " COMMIT = " + IntToString(GetLocalInt(OBJECT_SELF, "INVENTORY_COMMIT")));
	    if(GetLocalInt(OBJECT_SELF,"STORE_IN_DB") &&  !GetLocalInt(OBJECT_SELF, "INVENTORY_COMMIT")) {
		    SetLocalInt(OBJECT_SELF,"INVENTORY_COMMIT",TRUE);
		    DelayCommand(1.0, CommitSelfToDB()); 
		    //DelayCommand(29.0, CommitSelfToDB());  // ???
	    }
    } else if(nUser==EVENT_GARBAGE_COLLECTION) {
	    db("INVENTORY: Got GARBAGE_COLLECTION owner = " + GetLocalString(OBJECT_SELF,"OWNER_PCID"));
	    DeleteLocalInt(OBJECT_SELF,"CANCEL_CLEANUP");
	    if(GetLocalInt(OBJECT_SELF,"STORE_IN_DB") ||  GetLocalInt(OBJECT_SELF,"PERMANENT_DELETION")) {
		    CleanUp();
	    }
    }
}
