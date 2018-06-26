//Opens the door with the tag determined by the "door_open_tag" string on OBJECT_SELF
//Written by Ave

void main()
{
    string sTag=GetLocalString(OBJECT_SELF,"LEVER_SPAWN_WAYPOINT");
    object oDoor=GetObjectByTag(sTag);
    AssignCommand(oDoor,ActionUnlockObject(oDoor));
    AssignCommand(oDoor,ActionPlayAnimation(ANIMATION_DOOR_OPEN1));

    string sTag2=GetLocalString(OBJECT_SELF,"door_close_tag_2");
    object oDoor2=GetObjectByTag(sTag2);
    AssignCommand(oDoor2,ActionUnlockObject(oDoor2));
    AssignCommand(oDoor2,ActionPlayAnimation(ANIMATION_DOOR_OPEN1));

}
