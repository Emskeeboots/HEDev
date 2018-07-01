//Closes the door with the tag determined by the "door_close_tag" string on OBJECT_SELF
//Written by Ave

void main()
{
    string sTag=GetLocalString(OBJECT_SELF,"LEVER_SPAWN_WAYPOINT");
    object oDoor=GetObjectByTag(sTag);
    AssignCommand(oDoor,ActionPlayAnimation(ANIMATION_DOOR_CLOSE));
    AssignCommand(oDoor,ActionLockObject(oDoor));

    string sTag2=GetLocalString(OBJECT_SELF,"door_close_tag_2");
    object oDoor2=GetObjectByTag(sTag2);
    AssignCommand(oDoor2,ActionPlayAnimation(ANIMATION_DOOR_CLOSE));
    AssignCommand(oDoor2,ActionLockObject(oDoor2));
}
