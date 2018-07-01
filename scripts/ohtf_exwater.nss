///////////////////////////////////////////////////////
//  Olander's Realistic Systems - HTF System - Water Source Trigger
//  ohtf_exwater
//  By Don Anderson
//  dandersonru@msn.com
//
//  Place this script in the Trigger On Exit Event
//
///////////////////////////////////////////////////////

void main() {
        object oPC = GetExitingObject();

        if (GetIsPC(oPC)) {
                DeleteLocalInt(oPC,"WSOURCE");
                DeleteLocalString(oPC,"WSOURCE");
                DeleteLocalString(oPC,"WATERBODY");
		DeleteLocalObject(oPC,"WATERTRIGGER");
                DeleteLocalInt(oPC,"WFISHING");

        }
}
