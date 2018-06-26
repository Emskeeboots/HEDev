void main()
{
   // NPC is teleported to a waypoint
   object oNPC = OBJECT_SELF;
   object oWaypoint1 = GetLocalObject(OBJECT_SELF, "AWW_CURWP");
   object oWaypoint2 = GetObjectByTag(GetLocalString(oWaypoint1, "TELEPORT"));

   if (GetIsObjectValid(oWaypoint2)) ActionJumpToObject(oWaypoint2);
}
