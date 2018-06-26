// pets_do_op.nss
// ops script for pets system, run as the PC.
// pets_tmp_op = 
// 0 (unset) do module enter for calling PC.
// 1   Run master rest event on calling PC.
// 2   Level up for master on calling PC.

#include "_inc_pets"

void main () {
	if (!GetIsPC(OBJECT_SELF)) return;
	
	object oPC = OBJECT_SELF;
	int nOp = GetLocalInt(oPC, "pets_tmp_op");
	DeleteLocalInt(oPC, "pets_tmp_op");

	if (nOp == 0) {
		MasterInitializePets();
		return;
	}

	if (nOp == 1) {
		MasterRestEvent();
		return;
	}

	if (nOp == 1) {
		MasterLevelUpEvent();
		return;
	}

}
