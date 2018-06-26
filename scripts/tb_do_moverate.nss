// tb_do_moverate
// 
// Called with ExecuteScript() as the PC.
// move_tmp_op set to operation to perform
// 0 (unset - apply racial move rate)
// 1 Re-apply armor enc penalty on the PC.
//

#include "x2_inc_switches"
#include "tb_inc_movement"

void main() {

        object oPC = OBJECT_SELF;
        int nOp = GetLocalInt(oPC, "move_tmp_op");
        DeleteLocalInt(oPC, "move_tmp_op");

        if (nOp <= 0) {
                if (!TB_RACIAL_MOVERATES) return;

                SetRacialMovementRate(oPC);
                return;
        }

        if (nOp == 1) {
                tbArmorCheckPenalty(oPC);
                return;
        }
	
}
