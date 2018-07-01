// _vfx_do_op.nss
// Operations script for VFX system

// Execute as PC (usually). Set vfx_tmp_op tp  
// 0 (unset)  Restore VFX of caller

#include "_inc_vfx"

void main() {
	object oPC = OBJECT_SELF;
	int nOp = GetLocalInt(oPC, "vfx_tmp_op");
	DeleteLocalInt(oPC, "vfx_tmp_op");

	if (nOp == 0) {
		RestorePersonalVFX(oPC);
		return;
	}

}
