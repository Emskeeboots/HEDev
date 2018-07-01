// pw_data_test.nss
// Test script for new persistence model

//  set operation on calling PC in  pw_data_op
//  and run with ExecuteScript("pw_data_test", oPC);
//  0   store data test
//  1   recall data test

#include "_inc_data"
 
void pw_data_test_write(object oPC) {

        SendMessageToPC(oPC, "Starting data write test... ");

        // Write persistent data on PC - skin
        SetPersistentString(oPC, "PW_TEST_DATA", "testing123");
        SetPersistentInt(oPC, "PW_TEST_DATA", 123);
        SetPersistentFloat(oPC, "PW_TEST_DATA", 3.1415);

        // Write persistent data on PC - db
        SetPersistentString(oPC, "PW_TEST_DATA", "testing456", SQL_DATA_TABLE, FALSE);
        SetPersistentInt(oPC, "PW_TEST_DATA", 456,SQL_DATA_TABLE, FALSE);
        SetPersistentFloat(oPC, "PW_TEST_DATA", 2.718, SQL_DATA_TABLE, FALSE);
    
        // Write persistent data on module - db
        object oMod = GetModule();
        SetPersistentString(oMod, "PW_TEST_DATA", "testing789");
        SetPersistentInt(oMod, "PW_TEST_DATA", 789);
        SetPersistentFloat(oMod, "PW_TEST_DATA", 1.618);

        location lLoc = GetLocation(oPC);
        SetPersistentLocation(oPC, "PW_TEST_LOC", lLoc);

        vector v = Vector(1.0, 2.0, 3.0);
        SetPersistentVector(oPC, "PW_TEST_VEC", v);

        // TODO object
	object oTest = GetNearestObject(OBJECT_TYPE_CREATURE, oPC, 1);
	if (oTest != oPC) {
		SendMessageToPC(oPC, "Found NPC " + GetName(oTest));
		SetPersistentObject(oPC, "PW_TEST_OBJ", oTest);
	}

        SendMessageToPC(oPC, "Done saving test data.  Move PC to a new location so you can tell the difference. "
               + "Wait for a save and then restart the server. Log back in and run the write test: '#dbg pwtest 1'");

}

void pw_data_test_read(object oPC) {

        SendMessageToPC(oPC, "Starting data read test... ");
        int nCount = 0;
        
        // read persistent data on PC - skin
        string s = GetPersistentString(oPC, "PW_TEST_DATA");
        if (s != "testing123") {
                SendMessageToPC(oPC, "Error skin string- expected 'testing123' got '" + s + "'");
                nCount ++;
        }
        int i = GetPersistentInt(oPC, "PW_TEST_DATA");
        if (i != 123) {
               SendMessageToPC(oPC, "Error skin int- expected 123 got " + IntToString(i)); 
               nCount ++;
        }
        float f = GetPersistentFloat(oPC, "PW_TEST_DATA");
        if (f != 3.1415) {
                SendMessageToPC(oPC, "Error skin float- expected 3.1415 got " + FloatToString(f)); 
                nCount ++;
        }

        // Write persistent data on PC - db
        s = GetPersistentString(oPC, "PW_TEST_DATA", SQL_DATA_TABLE, FALSE);
        if (s != "testing456") {
                SendMessageToPC(oPC, "Error db string- expected 'testing456' got '" + s + "'");
                nCount ++;
        }
        i = GetPersistentInt(oPC, "PW_TEST_DATA",SQL_DATA_TABLE, FALSE);
        if (i != 456) {
               SendMessageToPC(oPC, "Error db int- expected 456 got " + IntToString(i)); 
               nCount ++;
        }
        f = GetPersistentFloat(oPC, "PW_TEST_DATA", SQL_DATA_TABLE, FALSE);
        if (f != 2.718) {
                SendMessageToPC(oPC, "Error db float- expected 2.718 got " + FloatToString(f)); 
                nCount ++;
        }

        // read persistent data on module - db
        object oMod = GetModule();
        s = GetPersistentString(oMod, "PW_TEST_DATA");
        if (s != "testing789") {
                SendMessageToPC(oPC, "Error db string- expected 'testing789' got '" + s + "'");
                nCount ++;
        }
        i = GetPersistentInt(oMod, "PW_TEST_DATA");
        if (i != 789) {
               SendMessageToPC(oPC, "Error db int- expected 789 got " + IntToString(i)); 
               nCount ++;
        }
        f = GetPersistentFloat(oMod, "PW_TEST_DATA");
        if (f != 1.618) {
                SendMessageToPC(oPC, "Error db float- expected 1.618 got " + FloatToString(f)); 
                nCount ++;
        }

        location lLoc = GetPersistentLocation(oPC, "PW_TEST_LOC");
        SendMessageToPC(oPC, "Jumping PC to save location...");
        AssignCommand(oPC, ActionJumpToLocation(lLoc));

        vector v = Vector(1.0, 2.0, 3.0);
        vector v2 = GetPersistentVector(oPC, "PW_TEST_VEC");
        if (v2 != v) {
                SendMessageToPC(oPC, "Error db vector : expected " + VectorToString(v) + " got " + VectorToString(v2));
                nCount ++;
        }

        // TODO object
	object oTest = 	GetPersistentObject(oPC, "PW_TEST_OBJ");
	if (!GetIsObjectValid(oTest)) {
		SendMessageToPC(oPC, "Retrieve object failed.");
		nCount ++;
	}

        SendMessageToPC(oPC, "Done test saved data.");
        if (nCount > 0) {
                SendMessageToPC(oPC, "Failed " + IntToString(nCount) + " tests!");
        } else {
                SendMessageToPC(oPC, "All tests passed");
        }

}
void main() {
        object oPC = OBJECT_SELF;
        int nOp = GetLocalInt(oPC, "pw_data_op");
        DeleteLocalInt(oPC, "pw_data_op");

        SendMessageToPC(oPC, "PW_DATA_TEST got op = " + IntToString(nOp));
        if (nOp == 0) {
                pw_data_test_write(oPC);
                return;
        }

        if (nOp == 1) {
                pw_data_test_read(oPC);
                return;
        }

        SendMessageToPC(oPC, "pw_data_test: Unknown operation :" +  IntToString(nOp));
}
