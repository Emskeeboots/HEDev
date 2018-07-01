// nwnx_do_op.nss
// wrapper for executing nwnx routines

// nwnx_tmp_op must be set on calling object
// 1 = dump variables of nwn_tmp_obj to caller
// 2 = dump variables of nwn_tmp_obj to caller with values - could be verbose...
// 3 = clear variables of nwn_tmp_obj ... dangerous. use with caution. Mostly for testing to allow clearing persisted state on PC skin.
// 4 = set creature HP.  Run as creature whose HP to set.

#include "_inc_nwnx"

void main () {

	object oSelf = OBJECT_SELF;

        int nOp = GetLocalInt(oSelf, "nwnx_tmp_op");
        DeleteLocalInt(oSelf, "nwnx_tmp_op");

	//SendMessageToPC(GetFirstPC(), "nwnx_do_op called : op = " + IntToString(nOp));
	if (nOp == 1 || nOp == 2) {
		object oTmp = GetLocalObject(oSelf, "nwnx_tmp_obj"); 
		DeleteLocalObject(oSelf, "nwnx_tmp_obj");
                if (GetIsObjectValid(oTmp)) nwnxDumpVariables(oTmp, oSelf, (nOp == 2));
		return;
	}

        if (nOp == 3) {
                object oTmp = GetLocalObject(oSelf, "nwnx_tmp_obj"); 
                DeleteLocalObject(oSelf, "nwnx_tmp_obj");
                if (GetIsObjectValid(oTmp)) nwnxDeleteAllVariables(oTmp);
                return;
        }
	if (nOp == 4) {
		int nVal = GetLocalInt(oSelf, "nwnx_tmp_val");
		DeleteLocalInt(oSelf, "nwnx_tmp_val");

		NWNX_SetCurrentHitPoints(oSelf, nVal);
		return;

	}

}
