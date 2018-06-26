
#include "_inc_data"

void main() {
        object oPC = GetExitingObject();

	// Save whole PC on exit. This assumes pcid is set as local variable because the PC does not register as a PC here.
	// This does not save location because area is already invalid. But allows for saving of anything else needed (added to Data_SavePC.
	//WriteTimestampedLogEntry("Client exit - calling save PC");
        Data_SavePC(oPC);

	
	DeleteLocalObject(OBJECT_SELF, "PC_" + GetPCID(oPC));
        
        //Debug
        //string msg = "Client exit : PCID = " + GetPCID(oPC) + " stored HP = " + IntToString(Data_GetPCHitPoints(oPC));
        //WriteTimestampedLogEntry(msg);
        //Debug End

        WriteTimestampedLogEntry("PLAYER EXIT : " + GetLocalString(oPC, "player_name") 
                + "(key " + GetLocalString(oPC, "player_cdkey") + " IP " + GetLocalString(oPC, "player_ip")
                        + ") as " + GetName(oPC) + " ID number " + GetPCID(oPC));
}
