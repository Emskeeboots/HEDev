void main()
{

object oPC = GetLastUsedBy();
if (!GetIsPC(oPC)) return;

if (GetLocalInt(OBJECT_SELF, "tt_door_tintank")== 1)
   {
        object oTarget;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_tintank_in");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }

else if (GetLocalInt(OBJECT_SELF, "tt_door_barn_out")== 1)
   {
        object oTarget;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_barn_in");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }

else if (GetLocalInt(OBJECT_SELF, "tt_door_barn_in")== 1)
   {
        object oTarget;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_barn_out");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }

else if (GetLocalInt(OBJECT_SELF, "tt_door_wh_in")== 1)
   {
        object oTarget;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_wh_out");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }

else if (GetLocalInt(OBJECT_SELF, "tt_door_wh_out")== 1)
   {
        object oTarget;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_wh_in");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }

else if (GetLocalInt(OBJECT_SELF, "tt_door_hoe_out")== 1)
   {
        object oTarget;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_hoe_in");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }

else if (GetLocalInt(OBJECT_SELF, "tt_door_hoe_in")== 1)
   {
        object oTarget;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_hoe_out");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }

else if (GetLocalInt(OBJECT_SELF, "tt_door_mill_down")== 1)
   {
        object oTarget;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_mill_up");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }

else if (GetLocalInt(OBJECT_SELF, "tt_stairmill")== 1)
   {
        object oTarget;
        object oSecret;
        location lTarget;
        oTarget = GetWaypointByTag("tt_wp_stairmill");
        lTarget = GetLocation(oTarget);
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionJumpToLocation(lTarget));
   }


}







