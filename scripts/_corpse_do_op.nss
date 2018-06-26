// _corpse_do_op.nss
// Operations script for corpse system

// Execute as PC (usually). Set corpse_tmp_op to 
// 0 (unset)  - Do login check for PC  (run as PC)

#include "_inc_corpse"

void main() {
	object oPC = OBJECT_SELF;
	int nOp = GetLocalInt(oPC, "corpse_tmp_op");
	DeleteLocalInt(oPC, "corpse_tmp_op");

	if (nOp == 0) {
		PCLoginCorpseCheck();
		return;
	}



}
