// tb_pc_daily
// Called as the PC every day - first HB of new day.

void main() {
	object oPC = OBJECT_SELF;

	ExecuteScript("calendar_motd", oPC);

        SetLocalInt(oPC, "deity_tmp_op", 2);
        ExecuteScript("deity_do_op", oPC);
}
