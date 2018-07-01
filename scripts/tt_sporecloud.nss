
void main()
{

object oPC = GetEnteringObject();

        if (!GetIsPC(oPC)) return;

        if (GetLocalInt(OBJECT_SELF, "sporecount")== 0)
        {
            //int i = 0;
            int i;
            object oTarget = GetObjectByTag("tt_spore", i);
            location lTarget;
            lTarget = GetLocation(oTarget);


            //while (GetIsObjectValid(oTarget))
            while (i < 40)
                {


                            location lTarget;
                            lTarget = GetLocation(oTarget);
                            CreateTrapAtLocation(TRAP_BASE_TYPE_AVERAGE_GAS, lTarget, 2.0);
                                SetTrapDetectable(oTarget, FALSE);
                                SetTrapDisarmable(oTarget, FALSE);
                                SetTrapOneShot(oTarget, TRUE);
                                SetTrapRecoverable(oTarget, FALSE);



                            i++;
                            oTarget = GetObjectByTag("tt_spore", i);

                }
             SetLocalInt(OBJECT_SELF, "sporecount", 1);
             DelayCommand(1800.0, SetLocalInt(OBJECT_SELF, "sporecount", 0));

         }



}


